## @file bdi_gui_gestion_source.tcl
#  @brief     GUI de gestion des sources dans les images
#  @author    Frederic Vachier
#  @date      2016
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_gestion_source.tcl]
#  @endcode
#  @version   2.0

# $Id: bdi_gui_gestion_source.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_gestion_source
# @brief GUI de gestion des sources dans les images
# @warning Outil en d&eacute;veloppement
# @todo Faire en sorte que PSF s'appelle depuis la recherche
#
namespace eval ::bdi_gui_gestion_source {

   variable gui_catalogues_data
   variable fen
   variable butcata
   variable gui_catalogues
   variable id_img
   variable dateimg
   variable visucrop
   variable bufcrop

}


proc ::bdi_gui_gestion_source::free_memory { } {

   catch {unset ::bdi_gui_gestion_source::new_names                    }
   catch {unset ::bdi_gui_gestion_source::work_id                      }
   catch {unset ::bdi_gui_gestion_source::nb_img_list                  }
   catch {unset ::bdi_gui_gestion_source::work_nb_list                 }
   catch {unset ::bdi_gui_gestion_source::work_list                    }
   catch {unset ::bdi_gui_gestion_source::dateimg                      }
   catch {unset ::bdi_gui_gestion_source::id_img                       }
   catch {unset ::bdi_gui_gestion_source::gui_catalogues_data          }
   catch {unset ::bdi_gui_gestion_source::new_mobile                   }
   catch {unset ::bdi_gui_gestion_source::fennew                       }
   catch {unset ::bdi_gui_gestion_source::visucrop                     }
   catch {unset ::bdi_gui_gestion_source::bufcrop                      }
   catch {unset ::bdi_gui_gestion_source::fen                          }
   catch {unset ::bdi_gui_gestion_source::gui_catalogues               }
   catch {array unset ::bdi_gui_gestion_source::idd2gui_list           }
   catch {array unset ::bdi_gui_gestion_source::current2idd_list       }
   catch {array unset ::bdi_gui_gestion_source::butcata                }

}

#----------------------------------------------------------------------------
## Initialisation des variables de namespace pour la Fenetre
# de traitement des psf des sources.
#  @details   le passage en argument de la variable worklist
#             permet de traiter une liste de sources independamment d'une
#             liste d'images. Dans la GUI les boutons Next et Prev, passe
#             de sources en sources pouvant etre sur les memes images ou non.
#  @sa        bdi_gui_gestion_source::run
#  @param     work_list liste valeur d'identifiant de source et ou d images.
#  @return    void
proc ::bdi_gui_gestion_source::init { work_list } {

   ::bdi_gui_psf::inittoconf
   ::bdi_gui_gestion_source::free_memory

   set ::bdi_gui_gestion_source::new_names ""

   #gren_erreur "work_list = $work_list\n"
   gren_erreur "idd2gui_list = [array get ::bdi_gui_gestion_source::idd2gui_list]\n"


   # RAZ des valeurs de psf de la gui
   if {[info exists ::bdi_gui_cata::current_psf]} {unset ::bdi_gui_cata::current_psf}
   foreach key [list xsm ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta] {
      set ::bdi_gui_cata::current_psf($key) ""
   }


   if { $work_list == "current" } {
      set work_list ""
      for {set cpt 1} {$cpt <= [llength $::tools_cata::img_list] } { incr cpt } {
            set ::bdi_gui_gestion_source::idd2gui_list($cpt) $cpt
            set ::bdi_gui_gestion_source::current2idd_list($cpt) $cpt
            lappend work_list [ list $cpt ]
      }
      incr cpt -1
      gren_info  "id_current_image $::tools_cata::id_current_image \n"
      set ::bdi_gui_gestion_source::work_id [expr $::tools_cata::id_current_image -1]
   }  else {

      if { $work_list == "" } {
         set work_list ""
         for {set cpt 1} {$cpt <= [llength $::tools_cata::img_list] } { incr cpt } {
               set ::bdi_gui_gestion_source::idd2gui_list($cpt) $cpt
               set ::bdi_gui_gestion_source::current2idd_list($cpt) $cpt
               lappend work_list [ list $cpt ]
         }
         incr cpt -1
         set ::bdi_gui_gestion_source::work_id 0

      } else {

         set iddl ""
         set cpt 0
         foreach work $work_list {
            set nb [llength $work]
            if {$nb == 0} {
               # @todo gerer le cas nb = 0
               gren_erreur "Erreur : Cas non pris en charge dans ::bdi_gui_gestion_source::init : nb = 0\n"
               return -code 1 "Rien a Faire"
            }
            gren_info "nb=$nb\n"

            if {$nb >= 1} {
               set idd [lindex $work 0]
               gren_info "idd=$idd\n"
               incr cpt
               gren_info "cpt=$cpt\n"
               set ::bdi_gui_gestion_source::idd2gui_list($idd) $cpt
               set ::bdi_gui_gestion_source::current2idd_list($cpt) $idd
            }
         }
         set ::bdi_gui_gestion_source::work_id 0
      }
   }

   #gren_info  "work_id $::bdi_gui_gestion_source::work_id \n"

   set ::bdi_gui_gestion_source::nb_img_list $cpt
   set ::bdi_gui_gestion_source::work_nb_list [llength $work_list]
   set ::bdi_gui_gestion_source::work_list $work_list
   set ::tools_cata::id_current_image -1

   return
}



proc ::bdi_gui_gestion_source::fermer { } {

   # Sauvegarde des parametres de mesure de psf
   ::audace::psf_close_to_conf $::audace(visuNo)

   # Fermeture des graphe
   if { [winfo exists .audace.plotxy1] } {
      destroy .audace.plotxy1
   }

   # Fermeture de la fenetre pricipale
   if { [info exists ::bdi_gui_gestion_source::fen] } {
      if { [winfo exists $::bdi_gui_gestion_source::fen] } {
         destroy $::bdi_gui_gestion_source::fen
      }
   }

   # Fermeture de la fenetre gestion
   #if { [winfo exists $::bdi_gui_cata_gestion::fen] } {
   #   destroy $::bdi_gui_cata_gestion::fen
   #}

   set ::bdi_gui_gestion_source::variable_cloture 0

}



#----------------------------------------------------------------------------
## Procedure de chargement de la prochaine source dans la fenetre de
# traitement des psf des sources.
#  @sa        bdi_gui_gestion_source::prev
#  @sa        bdi_gui_gestion_source::next
#  @sa        bdi_gui_gestion_source::focus_source
#  @param     forceids optionnel identifiant de source pour un affichage force.
#  @return    void
proc ::bdi_gui_gestion_source::work_charge { {forceids ""} } {

   set work [lindex $::bdi_gui_gestion_source::work_list $::bdi_gui_gestion_source::work_id]
#gren_erreur "work = $work \n"
   set nb [llength $work]
   # test si il y a quelque chose a traiter
   if {$nb == 0} {
      # @todo gerer le cas nb = 0
      gren_erreur "Erreur : Cas non pris en charge dans ::bdi_gui_gestion_source::work_charge : nb = 0\n"
      return -code 1 "Rien a Faire"
   }
   # chargement d une date
   if {$nb >= 1} {
      set idd [lindex $work 0]
      if {$::tools_cata::id_current_image == $idd} {
         # L image est deja affichee
      } else {
         # L image affichee n est pas la bonne
         set ::tools_cata::id_current_image $idd
         set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image - 1]]
         set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set ::bdi_gui_gestion_source::dateimg [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
         set ::bdi_gui_gestion_source::id_img $::bdi_gui_gestion_source::idd2gui_list($idd)
         set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
         ::bdi_gui_cata::affiche_current_image
      }
   }
   # chargement d une source ?
   if {$nb == 2} {
      set ids [lindex $work 1]
   } else {
      set ids -1
   }

   # des/activation des boutons prev next
   if {$::bdi_gui_gestion_source::work_id == 0} {
      $::bdi_gui_gestion_source::fen.appli.actions2.prev configure -state disabled

   }
   if {$::bdi_gui_gestion_source::work_id == [expr $::bdi_gui_gestion_source::work_nb_list - 1]} {
      $::bdi_gui_gestion_source::fen.appli.actions2.next configure -state disabled
   }
   if {$::bdi_gui_gestion_source::work_id > 0} {
      $::bdi_gui_gestion_source::fen.appli.actions2.prev configure -state normal
   }
   if {$::bdi_gui_gestion_source::work_id < [expr $::bdi_gui_gestion_source::work_nb_list - 1]} {
      $::bdi_gui_gestion_source::fen.appli.actions2.next configure -state normal
   }

   if {$forceids > -1} {
      set ids $forceids
   }


   if {$ids > -1} {
      # centre l objet demande dans la visu
      set s [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ]
      set r [::bdi_gui_gestion_source::grab_sources_getsource $ids $s ]
      set err   [lindex $r 0]
      set aff   [lindex $r 1]
      set id    [lindex $r 2]
      set xpass [lindex $r 3]
      set ypass [lindex $r 4]
      ::confVisu::setPos $::audace(visuNo) [list $xpass $ypass]
      # charge par un grab l objet dans la visu
      ::bdi_gui_gestion_source::gestion_mode_manuel_grab $ids
   }

   #gren_info "work_id = $::bdi_gui_gestion_source::work_id\n"
   #gren_info "work_nb_list = $::bdi_gui_gestion_source::work_nb_list\n"
   return

}




#----------------------------------------------------------------------------
## Passe a la source suivante dans la worklist
#  @sa        bdi_gui_gestion_source::next
#  @return    void
proc ::bdi_gui_gestion_source::prev { } {

   if {$::bdi_gui_gestion_source::work_id > 0 } {
      incr ::bdi_gui_gestion_source::work_id -1
      ::bdi_gui_gestion_source::work_charge
   } else {
      gren_erreur "au bout\n"
   }
   return
}

#----------------------------------------------------------------------------
## Revient a la source precedente dans la worklist
#  @sa        bdi_gui_gestion_source::prev
#  @return    void
proc ::bdi_gui_gestion_source::next { } {

   if {$::bdi_gui_gestion_source::work_id < [expr $::bdi_gui_gestion_source::work_nb_list-1]} {
      incr ::bdi_gui_gestion_source::work_id
      ::bdi_gui_gestion_source::work_charge
   } else {
      gren_erreur "au bout\n"
   }
   return
}





#----------------------------------------------------------------------------
## Action du bouton PSF de la GUI de traitement des sources.
# Effectue une mesure du profil stellaire sur la source identifiee auparavent.
#  @details   la source doit imperativement etre identifiee puisque la mesure
#             de psf s'effectue sur une variable de type "source" :
#             s = { { IMG {commonfields} {otherfields} } { ASTROID ... } }
#  @details   Cette procedure agit directement sur tools_cata::current_listsources
#  @sa        bdi_tools_psf::get_psf_source
#  @return    void
proc ::bdi_gui_gestion_source::psf { } {

   set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect==""} {
      set getbox "no"
   } else {
      set getbox "yes"
      set ::bdi_tools_psf::psf_rect $rect
   }

   gren_info "Source : $::bdi_gui_cata::psf_name_source  \n"
   gren_info "getbox : $getbox  \n"

   switch $::bdi_gui_cata::psf_name_source {
      "-" -
      "Unknown" {
         # source inconnue du cata ou nouvelle source
      }
      "Ambigue" {
         # Il y a plusieurs sources a mesurer on decide de ne rien faire
         tk_messageBox -message "Veuillez selectionner une seule source" -type ok
         return
      }
      default  {
         gren_info "id source : $::bdi_gui_cata::psf_id_source  \n"
         set s [lindex [lindex $::tools_cata::current_listsources 1] [expr $::bdi_gui_cata::psf_id_source - 1] ]
         set err_psf [::bdi_tools_psf::get_psf_source s "no" "yes"]
      }
   }

   #::bdi_gui_gestion_source::affich_cata

   set lf [lindex $::tools_cata::current_listsources 0]
   set ls [lindex $::tools_cata::current_listsources 1]
   set i  [expr $::bdi_gui_cata::psf_id_source - 1]
   set ls [lreplace $ls $i $i $s]
   set ::tools_cata::current_listsources [list $lf $ls]

   ::bdi_gui_psf::init_current_psf [::bdi_tools_psf::get_astroid_othf_from_source $s]
   if {$err_psf!=""} {
      set ::bdi_gui_cata::current_psf(err_psf) $err_psf
   } else {
      ::bdi_tools_psf::set_fields_astroid ::tools_cata::current_listsources
      cleanmark
      set xy [::bdi_tools_psf::get_xy_astroid s]
      if {$xy != -1} {
         affich_un_rond_xy [lindex $xy 0] [lindex $xy 1] green $::bdi_gui_cata::current_psf(radius) 2
      }
      #gren_info "s = $s \n"
   }

   ::bdi_gui_gestion_source::maj_catalogues

   #set onglets $::bdi_gui_gestion_source::fen.appli.onglets
   #$onglets.nb select $onglets.nb.f1


   #if { [winfo exists .audace.plotxy1] } {
   #   ::bdi_gui_psf::graph $::bdi_gui_psf::graph_current_key
   #}

   return

}





#----------------------------------------------------------------------------
## Affiche la liste des catalogues d'une ou plusieurs sources dans l'onglet
# "Catalogues" ainsi que les boutons de selection pour l'affichage des catalogues
# pour une seule source selectionne
#  @details   Cette procedure utilise la liste  bdi_gui_gestion_source::gui_catalogues_data
#  @return    void
proc ::bdi_gui_gestion_source::maj_catalogues {  } {

   # recupere la liste des sources de l image courante
   set sources [lindex $::tools_cata::current_listsources 1]

   # Recupere la liste des id des sources du catalogue selectionne
   set idlist ""
   foreach line $::bdi_gui_gestion_source::gui_catalogues_data {
      lappend idlist [lindex $line 2]
   }
   set idlist [lsort -unique $idlist]


   # reconstruit pour chaque source la variable catalogue
   set ::bdi_gui_gestion_source::gui_catalogues_data ""
   foreach id $idlist {
      incr id -1
      set s [lindex $sources $id]
      set pos 0
      foreach cata $s {

         if {[lindex $cata 0] == "ASTROID"} {
            # TODO
            set othf [lindex $cata 2]
            set x [::bdi_tools_psf::get_val othf "xsm"]
            set y [::bdi_tools_psf::get_val othf "ysm"]
            lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] [expr $id + 1] $x $y ]
            incr pos

         } else {

            set ra0  [lindex [lindex $cata 1] 0]
            set dec0 [lindex [lindex $cata 1] 1]
            if {$ra0!=""&&$dec0!=""} {
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] [expr $id + 1] $x $y ]
               incr pos
            }
         }
      }
   }

   $::bdi_gui_gestion_source::gui_catalogues.tbl delete 0 end
   foreach line $::bdi_gui_gestion_source::gui_catalogues_data {
      $::bdi_gui_gestion_source::gui_catalogues.tbl insert end $line
   }


   # Effacement des boutons des catalogues
   if {[info exists ::bdi_gui_cata::nb_butcata]} {
      for { set i 0 } { $i <= 10} {incr i} {
         set ex [winfo exists $::bdi_gui_gestion_source::fen.appli.info_cata.c$i]
         if {$ex == 0} {break}
         destroy $::bdi_gui_gestion_source::fen.appli.info_cata.c$i
      }
   }

   # Affichage des boutons des catalogues si il n y a qu une seule source concernee
   if {[llength $idlist]==1} {
      array unset ::bdi_gui_gestion_source::butcata
      set i 0
      foreach mycata $s {
         set a [lindex $mycata 0]
         button $::bdi_gui_gestion_source::fen.appli.info_cata.c$i  -state normal \
            -text $a -relief "sunken" -command "::bdi_gui_gestion_source::butcata_action $i"
         pack   $::bdi_gui_gestion_source::fen.appli.info_cata.c$i -in $::bdi_gui_gestion_source::fen.appli.info_cata -side left -padx 0
         set ::bdi_gui_gestion_source::butcata($i,cata) $a
         set ::bdi_gui_gestion_source::butcata($i,state) "Ok"
         incr i
      }
      set ::bdi_gui_cata::nb_butcata $i
   }

}





#----------------------------------------------------------------------------
## Affiche la liste des catalogues d'une source dans l'onglet "Catalogues"
#  @details   Cette procedure remplit la liste  bdi_gui_gestion_source::gui_catalogues_data
#  @sa        bdi_gui_gestion_source::grab_sources_getbox
#  @param     ids   position de la source dans la "listsource"
#  @param     s     variable de type "source"
#  @return    liste dont les elements contiennent la position x et y de la source dans l image
proc ::bdi_gui_gestion_source::grab_sources_getsource { ids s } {

   set color red
   set width 2
   cleanmark

   set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
   #::bdi_tools_psf::gren_astroid othf

   set ::bdi_gui_gestion_source::gui_catalogues_data ""

   # Nom de la source
   set namable [::manage_source::namable $s]
   if {$namable==""} {
      set name ""
   } else {
      set name [::manage_source::naming $s $namable]
   }

   # source trouv裊      gren_info "SOURCE FOUND : ID = $ids NAME = $name CATAS = "
   set pos 0
   foreach cata $s {
      if {[lindex $cata 0] == "ASTROID"} {
         # TODO
         set xpos [::bdi_tools_psf::get_id_astroid "xsm"]
         set x [lindex $cata [list 2 $xpos]]
         set ypos [::bdi_tools_psf::get_id_astroid "ysm"]
         set y [lindex $cata [list 2 $ypos]]
         lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] $ids $x $y ]
         incr pos

      } else {

         set ra0  [lindex [lindex $cata 1] 0]
         set dec0 [lindex [lindex $cata 1] 1]
         gren_info "[lindex $cata 0] $ra0 $dec0 "
         if {$ra0!=""&&$dec0!=""} {
            set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] $ids $x $y ]
            incr pos
         }
      }
   }
   gren_info "\n"

   return [list 0 "" $ids $x $y $s]

}




#----------------------------------------------------------------------------
## Affiche la liste des catalogues d'une (ou des) source dans l'onglet "Catalogues"
#  Les sources pouvant etre contenue dans une getbox c est a dire a l issue du tracer
#  d'un carre dans la visu
#  @details   Cette procedure remplit la liste  bdi_gui_gestion_source::gui_catalogues_data
#  @sa        bdi_gui_gestion_source::grab_sources_getbox
#  @return    liste dont les elements contiennent la position x et y de la source dans l image
proc ::bdi_gui_gestion_source::grab_sources_getbox {  } {

   set color red
   set width 2
   cleanmark

   set ambigue "no"

   set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect==""} {
      tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
      return
   }
   set ::bdi_gui_gestion_source::gui_catalogues_data ""

   set sources [lindex $::tools_cata::current_listsources 1]

   set id 1
   set cpt_grab 0
   foreach s $sources {

      foreach cata $s {

         set namable [::manage_source::namable $s]
         if {$namable==""} {
            set name ""
         } else {
            #gren_erreur "name = $namable\n"
            set name [::manage_source::naming $s $namable]
         }

         set pass "no"

         set ra  [lindex [lindex $cata 1] 0]
         set dec [lindex [lindex $cata 1] 1]

         if {$ra!="" && $dec!="" && $ra!="-" && $dec!="-"  } {
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
               if {$ra0!="" && $dec0!="" && $ra0!="-" && $dec0!="-"  } {
                  set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
                  set x [lindex $xy 0]
                  set y [lindex $xy 1]
                  lappend ::bdi_gui_gestion_source::gui_catalogues_data [list $pos [lindex $cata 0] $id $x $y ]
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




#----------------------------------------------------------------------------
## Recentre la source identifiee par la variable \::bdi_gui_cata::psf_name_source
#  @return    void
proc ::bdi_gui_gestion_source::focus_source {  } {
   if {$::bdi_gui_cata::psf_id_source != ""} {
      catch {
         set id [::manage_source::name2ids $::bdi_gui_cata::psf_name_source ::tools_cata::current_listsources]
         ::bdi_gui_gestion_source::select_source $::bdi_gui_cata::psf_id_source
         ::bdi_gui_gestion_source::work_charge $::bdi_gui_cata::psf_id_source
      }
   }
   return
}




proc ::bdi_gui_gestion_source::select_source { ids } {

   set r [::bdi_gui_gestion_source::grab_sources_getsource $ids [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ] ]
   set err   [lindex $r 0]
   set aff   [lindex $r 1]
   set id    [lindex $r 2]
   set xpass [lindex $r 3]
   set ypass [lindex $r 4]
   set s     [lindex $r 5]

      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      ::bdi_tools_psf::gren_astroid othf


   if {[info exists ::bdi_gui_cata::psf_best_sol]} { unset ::bdi_gui_cata::psf_best_sol }

   if {$err!=0} {
      set ::bdi_gui_cata::psf_name_source "Erreur"
      if { $aff=="Unknown" || $aff=="Ambigue" } {
         set ::bdi_gui_cata::psf_name_source $aff
      }
      if { $aff=="Ambigue" } {
         set ::bdi_gui_cata::psf_name_source $aff
      }
   } else {

      set ::bdi_gui_cata::psf_best_sol [list $xpass $ypass]

      set d [::manage_source::namable $s]
      if {$d==""} {
         gren_info "s=$s\n"
         set ::bdi_gui_cata::psf_name_source "Unnamable"
         return
      }
      set ::bdi_gui_cata::psf_source $s
      set ::bdi_gui_cata::psf_name_source [::manage_source::naming $s $d]
      set ::bdi_gui_cata::psf_name_cata $d
      set ::bdi_gui_cata::psf_id_source $id

   }

}




# Anciennement ::bdi_gui_cata::psf_grab
# Grab des sources dans l image
# appele depuis l analyse des psf en mode manuel


proc ::bdi_gui_gestion_source::gestion_mode_manuel_grab { {ids ""} } {

   $::bdi_gui_gestion_source::fen.appli.actions1.save configure -state normal
   #$::bdi_gui_gestion_source::fen.appli.actions1.new  configure -state disabled
   set ::bdi_gui_cata::nb_butcata 0

   set ::bdi_gui_cata::psf_id_source ""
   set ::bdi_gui_cata::list_of_cata ""

   if { $ids == "" } {
      set r [::bdi_gui_gestion_source::grab_sources_getbox]
   } else {
      set r [::bdi_gui_gestion_source::grab_sources_getsource $ids [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ] ]
   }

   #gren_info "r=$r\n"
   set err   [lindex $r 0]
   set aff   [lindex $r 1]
   set id    [lindex $r 2]
   set xpass [lindex $r 3]
   set ypass [lindex $r 4]
   set s     [lindex $r 5]

   set ::bdi_gui_cata::psf_best_sol [list $xpass $ypass]

   if {$err!=0} {
      set ::bdi_gui_cata::psf_name_source "Erreur"
      if { $aff=="Unknown" || $aff=="Ambigue" } {
         set ::bdi_gui_cata::psf_name_source $aff
         if {[info exists ::bdi_gui_cata::psf_best_sol]} { unset ::bdi_gui_cata::psf_best_sol }
      }
      if { $aff=="Ambigue" } {
         set ::bdi_gui_cata::psf_name_source $aff
         if {[info exists ::bdi_gui_cata::psf_best_sol]} { unset ::bdi_gui_cata::psf_best_sol }
      }
   } else {


      #::psf_tools::result_photom_methode "err"
      #::psf_tools::result_fitgauss "err"

      set d [::manage_source::namable $s]
      if {$d==""} {
         gren_info "s=$s\n"
         set ::bdi_gui_cata::psf_name_source "Unnamable"
         return
      }
      set ::bdi_gui_cata::psf_source $s
      set ::bdi_gui_cata::psf_name_source [::manage_source::naming $s $d]
      set ::bdi_gui_cata::psf_name_cata $d
      set ::bdi_gui_cata::psf_id_source $id
   }


   # Effacement des boutons des catalogues
   if {[info exists ::bdi_gui_cata::nb_butcata]} {
      for { set i 0 } { $i <= 10} {incr i} {
         set ex [winfo exists $::bdi_gui_gestion_source::fen.appli.info_cata.c$i]
         if {$ex == 0} {break}
         destroy $::bdi_gui_gestion_source::fen.appli.info_cata.c$i
      }
   }


   # Affichage des boutons des catalogues
   if { $aff!="Ambigue" } {
      # bouton et list des cata des sources grabees
      array unset ::bdi_gui_gestion_source::butcata
      set i 0
      foreach mycata $s {
         set a [lindex $mycata 0]
         button $::bdi_gui_gestion_source::fen.appli.info_cata.c$i  -state normal \
            -text $a -relief "sunken" -command "::bdi_gui_gestion_source::butcata_action $i"
         pack   $::bdi_gui_gestion_source::fen.appli.info_cata.c$i -in $::bdi_gui_gestion_source::fen.appli.info_cata -side left -padx 0
         set ::bdi_gui_gestion_source::butcata($i,cata) $a
         set ::bdi_gui_gestion_source::butcata($i,state) "Ok"
         incr i
      }
      set ::bdi_gui_cata::nb_butcata $i

   }


   # affichage des infos dans la GUI
   ::bdi_gui_gestion_source::affich_cata


   # Selection dans la liste des sources
   ::bdi_gui_gestion_source::selectall $::bdi_gui_gestion_source::gui_catalogues.tbl


   # onglets direct en cas d ambiguite
   if { $aff=="Ambigue" } {
      set onglets $::bdi_gui_gestion_source::fen.appli.onglets
      $onglets.nb select $onglets.nb.f6
   }

}





proc ::bdi_gui_gestion_source::affich_cata { } {

   global bddconf

   set bufno $::bddconf(bufno)
   cleanmark


   for { set i 0 } { $i < $::bdi_gui_cata::nb_butcata} {incr i} {


      if { $::bdi_gui_gestion_source::butcata($i,state) == "Ok" } {
         set pos [lsearch -index 0 $::bdi_gui_cata::psf_source $::bdi_gui_gestion_source::butcata($i,cata)]
         if {$pos != -1} {
            set ra  [lindex $::bdi_gui_cata::psf_source [list $pos 1 0] ]
            set dec [lindex $::bdi_gui_cata::psf_source [list $pos 1 1] ]
         }
         set width [expr 7 + $i * 2]

         if {$ra!="" && $dec!="" && $ra!="-" && $dec!="-"  } {
            # Affiche un rond vert
            set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
            set x [lindex $img_xy 0]
            set y [lindex $img_xy 1]
            affich_un_rond_xy $x $y green  $width 1
         }
      }
   }

   $::bdi_gui_gestion_source::gui_catalogues.tbl delete 0 end
   foreach line $::bdi_gui_gestion_source::gui_catalogues_data {
      $::bdi_gui_gestion_source::gui_catalogues.tbl insert end $line
   }


}




proc ::bdi_gui_gestion_source::butcata_action { i } {

   if { $::bdi_gui_gestion_source::butcata($i,state) == "Ok" } {
      set ::bdi_gui_gestion_source::butcata($i,state) ""
      $::bdi_gui_gestion_source::fen.appli.info_cata.c$i configure -relief "raised"
   } else {
      set ::bdi_gui_gestion_source::butcata($i,state) "Ok"
      $::bdi_gui_gestion_source::fen.appli.info_cata.c$i configure -relief "sunken"
   }

   ::bdi_gui_gestion_source::affich_cata

}





#------------------------------------------------------------
## Analyse de photocentre d'une source
# Permet la recombinaison des catalogue pour une source.
# fonction appelee par l'outil recherche
#  \sa bdi_gui_gestion_source::run
proc ::bdi_gui_gestion_source::charge_list { img_list } {

   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

   set ::tools_cata::id_current_image 0
   foreach ::tools_cata::current_image $::tools_cata::img_list {
      incr ::tools_cata::id_current_image
      ::bdi_gui_cata::load_cata
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   }

   set ::tools_cata::id_current_image 0
   set ::bdi_gui_gestion_source::id_img 1
   set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]
   ::bdi_gui_cata::affiche_current_image

   set ::bdi_gui_cata::psf_name_source "-"
   set ::bdi_gui_cata::list_of_cata "-"

   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set ::bdi_gui_gestion_source::dateimg [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]

}




#------------------------------------------------------------
## Analyse de photocentre d'une source
# Permet la recombinaison des catalogue pour une source.
# fonction appelee par l'outil recherche
#  \sa bdi_gui_gestion_source::run
proc ::bdi_gui_gestion_source::run_recherche { img_list } {
   set ::bdi_gui_cata::use_uncosmic 0
   ::bdi_gui_gestion_source::charge_list $img_list
   ::bdi_gui_gestion_source::run
}




proc ::bdi_gui_gestion_source::getpos { s cata x y } {

   set p -1

   set p [lsearch -index 0 $s $cata]
   if {$p!=-1} {
      set mycata [lindex $s $p]
      set ra  [lindex $mycata {1 0}]
      set dec [lindex $mycata {1 1}]
      set img_xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
      set xc [lindex $img_xy 0]
      set yc [lindex $img_xy 1]
      #gren_info " $xc $x\n"
      #gren_info " $yc $y\n"
      #gren_info "a [expr abs($xc - $x)]\n"
      #gren_info "b [expr abs($yc - $y)]\n"
      if { [expr abs($xc - $x)] < 0.001 && [expr abs($yc - $y)] < 0.001} {
         return $p
      }
   }
   return $p
}




proc ::bdi_gui_gestion_source::console { tbl } {

   set l ""
   foreach select [$tbl curselection] {
      set pos  [lindex [$tbl get $select] 0]
      set cata [lindex [$tbl get $select] 1]
      set ids  [lindex [$tbl get $select] 2]
      set x    [lindex [$tbl get $select] 3]
      set y    [lindex [$tbl get $select] 4]
      lappend l [list $pos $cata $ids $x $y]
   }
   set l [lsort -decreasing -integer -index 2 $l]
   foreach c $l {
      set pos  [lindex $c 0]
      set cata [lindex $c 1]
      set ids  [lindex $c 2]
      set x    [lindex $c 3]
      set y    [lindex $c 4]
      #gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
      gren_info [format "%-7s %5s %5s %.3f %.3f\n" $cata $ids $pos $x $y]
   }
}




proc ::bdi_gui_gestion_source::select { tbl } {

   set l ""
   set idsel ""
   foreach select [$tbl curselection] {
      set pos  [lindex [$tbl get $select] 0]
      set cata [lindex [$tbl get $select] 1]
      set ids  [lindex [$tbl get $select] 2]
      set x    [lindex [$tbl get $select] 3]
      set y    [lindex [$tbl get $select] 4]
      lappend l [list $pos $cata $ids $x $y]
      if {$idsel == ""} { set idsel $ids}
      if {$idsel != $ids} {
         tk_messageBox -message "Veuillez selectionner une seule source" -type ok
         return
      }
   }
   gren_info "Source selectionnee : $idsel\n"

   set l [lsort -decreasing -integer -index 2 $l]
   foreach c $l {
      set pos  [lindex $c 0]
      set cata [lindex $c 1]
      set ids  [lindex $c 2]
      set x    [lindex $c 3]
      set y    [lindex $c 4]
      #gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
      gren_info [format "%-7s %5s %5s %.3f %.3f\n" $cata $ids $pos $x $y]
   }

   ::bdi_gui_gestion_source::gestion_mode_manuel_grab $idsel
}




proc ::bdi_gui_gestion_source::aff_catas { s } {

   set line "AFF_CATAS ="
   foreach c $s {
      append line " [lindex $c 0]"
   }
   return $line
}




proc ::bdi_gui_gestion_source::mode_manuel_save { } {

   global bddconf

   gren_info "Maj id = $::tools_cata::id_current_image \n"

   # Tabkey
   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set date   [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set id $::tools_cata::date2id($date)
   set ::bdi_gui_cata::cata_list($id) $::tools_cata::current_listsources

   # Noms du fichier cata
   set imgfilename    [::bddimages_liste::lget $::tools_cata::current_image filename]
   set imgdirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
   set cataxml "${f}_cata.xml"

   ::tools_cata::save_cata $::tools_cata::current_listsources $tabkey $cataxml

   if { [winfo exists ::bdi_gui_cata_gestion::fen] } {
      gren_info "Fenetre gestion des catalogues existe\n"
      ::tools_cata::current_listsources_to_tklist
      set ::bdi_gui_cata::tk_list($id,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
      set ::bdi_gui_cata::tk_list($id,tklist)          [array get ::bdi_gui_cata::tklist]
      set ::bdi_gui_cata::tk_list($id,cataname)        [array get ::bdi_gui_cata::cataname]
   }

}



proc ::bdi_gui_gestion_source::newsource { tbl } {

# ouvrir bouton save
   $::bdi_gui_gestion_source::fen.appli.actions1.save configure -state normal

   set l ""
   foreach select [$tbl curselection] {
      set pos  [lindex [$tbl get $select] 0]
      set cata [lindex [$tbl get $select] 1]
      set ids  [lindex [$tbl get $select] 2]
      set x    [lindex [$tbl get $select] 3]
      set y    [lindex [$tbl get $select] 4]
      gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
      lappend l [list $pos $cata $ids $x $y]
   }
   set l [lsort -decreasing -integer -index 2 $l]


   set fields  [lindex $::tools_cata::current_listsources 0]
   set sources [lindex $::tools_cata::current_listsources 1]

   set newsource ""
   foreach c $l {
      set pos  [lindex $c 0]
      set cata [lindex $c 1]
      set ids  [lindex $c 2]
      set x    [lindex $c 3]
      set y    [lindex $c 4]

      gren_info "catat = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"
      incr ids -1
      set s [lindex $sources $ids]
      set pos [::bdi_gui_gestion_source::getpos $s $cata $x $y]
      if {$pos==-1} {
         gren_erreur "pos = $pos\n"
      }


      gren_info "s $ids : [::bdi_gui_gestion_source::aff_catas $s]\n"
      gren_info "pos $ids : $pos\n"
      gren_info "ns $ids : [lindex $s [list $pos 0]]\n"


      lappend newsource [lindex $s $pos]
      set s [lreplace $s $pos $pos]
      if {[llength $s ]==0} {
         set sources [lreplace $sources $ids $ids]
         gren_info "old s $ids : SUPPRIMEE\n"
      } else {
         set sources [lreplace $sources $ids $ids $s]
         gren_info "old s $ids : [::bdi_gui_gestion_source::aff_catas $s]\n"
         set s [lindex $sources $ids]

      }
   }

   gren_info "New source : [::bdi_gui_gestion_source::aff_catas $newsource]\n"

   lappend sources $newsource

   set s [lindex $sources $ids]

   set ::tools_cata::current_listsources [list $fields $sources]

   ::bdi_gui_gestion_source::gestion_mode_manuel_grab

   # effectue tri croissant sur la colonne x
   set sens [tablelist::sortByColumn $tbl 3]
   if {$sens == "decreasing"} {
      tablelist::sortByColumn $tbl 3
   }

}




proc ::bdi_gui_gestion_source::popup_psf_on_list { tbl } {

   set l ""
   foreach select [$tbl curselection] {
      set ids  [lindex [$tbl get $select] 2]
      lappend l $ids
   }
   set l [lsort -increasing -integer -unique $l]
   gren_info "l=$l\n"

   foreach ids $l {
      ::bdi_gui_gestion_source::select_source $ids
      ::bdi_gui_gestion_source::psf
   }
}



proc ::bdi_gui_gestion_source::savenextpsf_img {  } {
   ::bdi_gui_gestion_source::mode_manuel_save
   ::bdi_gui_gestion_source::next
   ::bdi_gui_gestion_source::psf
}
proc ::bdi_gui_gestion_source::nextpsf_img {  } {
   ::bdi_gui_gestion_source::next
   ::bdi_gui_gestion_source::psf
}

proc ::bdi_gui_gestion_source::set_new_name {  } {
   #$gui_name configure -text $myname
   gren_info "name = $::bdi_gui_gestion_source::new_name \n"
}

proc ::bdi_gui_gestion_source::apply_new_name {  } {

   if {$::bdi_gui_gestion_source::new_name == ""} {
      gren_erreur "name = $::bdi_gui_gestion_source::new_name \n"
      gren_erreur "mobile = $::bdi_gui_gestion_source::new_mobile \n"
      tk_messageBox -message "Veuillez entrer une nom valide" -type ok
      return
   }

   #$gui_name configure -text $myname
   gren_info "name = $::bdi_gui_gestion_source::new_name \n"
   gren_info "mobile = $::bdi_gui_gestion_source::new_mobile \n"

   set pos [lsearch $::bdi_gui_gestion_source::new_names $::bdi_gui_gestion_source::new_name]
   if { $pos == -1 } {
      lappend ::bdi_gui_gestion_source::new_names $::bdi_gui_gestion_source::new_name
   }

   # creation d'une nouvelle source { {"USER" {common} {mobile name} } }
   set s [list [::bdi_tools_cata_user::new $::bdi_gui_gestion_source::new_mobile $::bdi_gui_gestion_source::new_name] ]

   # recupere la getbox
   set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect==""} {
      gren_erreur "erreur get box\n"
   }

   set othf [::bdi_tools_methodes_psf::fitgauss $rect $::audace(bufNo)]

   set ra  [::bdi_tools_psf::get_val othf "ra"]
   set dec [::bdi_tools_psf::get_val othf "dec"]
   set xsm [::bdi_tools_psf::get_val othf "xsm"]
   set ysm [::bdi_tools_psf::get_val othf "ysm"]
   affich_un_rond_xy $xsm $ysm green 10 2

   ::bdi_tools_psf::set_astroid_in_source s othf
   ::bdi_tools_cata_user::set_common_fields_on_source s

   set lf [lindex $::tools_cata::current_listsources 0]
   set ls [lindex $::tools_cata::current_listsources 1]
   lappend ls $s
   set ::tools_cata::current_listsources [list $lf $ls]
   ::bdi_tools_cata_user::set_fields ::tools_cata::current_listsources

   gren_info "field current_listsources =[lindex  $::tools_cata::current_listsources 0] \n"

   # mise a jour des donnees dans les variable de namespace
   set $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   ::tools_cata::current_listsources_to_tklist

   # mise a jour des donnees dans la gui tklist
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::bdi_gui_cata::tklist]
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::bdi_gui_cata::cataname]


   set ids [llength $ls]
   ::bdi_gui_gestion_source::gestion_mode_manuel_grab $ids



   destroy $::bdi_gui_gestion_source::fennew
   return


   set name_cata [::manage_source::namable $s]
   gren_info
   set name_source [::manage_source::naming $s $name_cata]

}




proc ::bdi_gui_gestion_source::gestion_mode_manuel_new {  } {

   #set ::bdi_gui_gestion_source::new_names ""
   set ::bdi_gui_gestion_source::new_mobile 0

   set ::bdi_gui_gestion_source::fennew .newsource
   if { [winfo exists $::bdi_gui_gestion_source::fennew] } {
      wm withdraw $::bdi_gui_gestion_source::fennew
      wm deiconify $::bdi_gui_gestion_source::fennew
      focus $::bdi_gui_gestion_source::fennew
      return
   }
   toplevel $::bdi_gui_gestion_source::fennew -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_gestion_source::fennew ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_gestion_source::fennew ] "+" ] 2 ]
   wm geometry $::bdi_gui_gestion_source::fennew +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_gestion_source::fennew 1 1
   wm title $::bdi_gui_gestion_source::fennew "New Source"
   wm protocol $::bdi_gui_gestion_source::fennew WM_DELETE_WINDOW "destroy $::bdi_gui_gestion_source::fennew"

   set frm $::bdi_gui_gestion_source::fennew.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_gestion_source::fennew -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      set block  [frame $frm.nom_source -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          label $block.lab1 -text "Nom de la source : "
          pack  $block.lab1 -side left -padx 2 -pady 0

          set gui_name [entry $block.nom -relief sunken -width 11 \
                           -textvariable ::bdi_gui_gestion_source::new_name \
                           -validate all \
                           -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 } \
                       ]
          pack  $block.nom -side left -padx 2 -pady 0

      set block  [frame $frm.mobile_source -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          checkbutton $block.mobile -highlightthickness 0 -text "  Objet mobile" -variable ::bdi_gui_gestion_source::new_mobile
          pack  $block.mobile -side top -padx 2 -pady 0

      set block  [frame $frm.ancien_nom -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          menubutton $block.menu -relief raised -borderwidth 2 -textvariable ::bdi_gui_gestion_source::new_name \
                -menu $block.menu.list
          pack $block.menu -in $block -side left -anchor w -padx 3 -pady 3

          set menuconfig [menu $block.menu.list -tearoff 0]
          foreach myconf $::bdi_gui_gestion_source::new_names {
             $menuconfig add radiobutton -label $myconf -value $myconf -variable ::bdi_gui_gestion_source::new_name \
                -command "::bdi_gui_gestion_source::set_new_name"
          }

      set block  [frame $frm.action -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         button $block.ok -state active -text "Appliquer" -relief "raised" \
            -command "::bdi_gui_gestion_source::apply_new_name"
         pack   $block.ok -in $block -side right -anchor w -padx 0
         button $block.fermer -state active -text "Fermer" -relief "raised" \
            -command "destroy $::bdi_gui_gestion_source::fennew"
         pack   $block.fermer -in $block -side right -anchor w -padx 0
}



proc ::bdi_gui_gestion_source::get_id_from_gui_catalogues_data { c } {

   set cpt -1
   foreach x $::bdi_gui_gestion_source::gui_catalogues_data {
      incr cpt
      if {[lindex $x 0] != [lindex $c 0] } {continue}
      if {[lindex $x 1] != [lindex $c 1] } {continue}
      if {[lindex $x 2] != [lindex $c 2] } {continue}
      if {[lindex $x 3] != [lindex $c 3] } {continue}
      if {[lindex $x 4] != [lindex $c 4] } {continue}
      return $cpt
   }
   return -1
}



proc ::bdi_gui_gestion_source::deletesource { tbl } {

   set l ""
   foreach select [$tbl curselection] {
      set pos  [lindex [$tbl get $select] 0]
      set cata [lindex [$tbl get $select] 1]
      set ids  [lindex [$tbl get $select] 2]
      set x    [lindex [$tbl get $select] 3]
      set y    [lindex [$tbl get $select] 4]
      lappend l [list $pos $cata $ids $x $y]
   }

   set l [lsort -decreasing -integer -index 2 $l]
   foreach c $l {
      set pos  [lindex $c 0]
      set cata [lindex $c 1]
      set ids  [lindex $c 2]
      set x    [lindex $c 3]
      set y    [lindex $c 4]
      gren_info "cata = $cata ; ids = $ids ; pos = $pos ; x = $x ; y = $y\n"

      set id [expr $ids - 1]
      set ls [lindex $::tools_cata::current_listsources 1]
      set s  [lindex $ls $id]

      ::manage_source::delete_catalog_in_source s $cata
      set ls [lreplace $ls $id $id $s]
      set ::tools_cata::current_listsources [lreplace $::tools_cata::current_listsources 1 1 $ls]

      set posc [::bdi_gui_gestion_source::get_id_from_gui_catalogues_data $c]
      if {$posc == -1} {
         gren_erreur "$c n est pas dans la liste des catalogues"
         return
      } else {
         set ::bdi_gui_gestion_source::gui_catalogues_data [lreplace $::bdi_gui_gestion_source::gui_catalogues_data $posc $posc]
      }

   }

   ::bdi_gui_gestion_source::affich_cata

   # effectue tri croissant sur la colonne x
   set sens [tablelist::sortByColumn $tbl 3]
   if {$sens == "decreasing"} {
      tablelist::sortByColumn $tbl 3
   }
}




proc ::bdi_gui_gestion_source::selectall { tbl  } {
   $tbl selection set 0 end
   set nb [llength [$tbl curselection] ]
   gren_info "Nb selected : $nb\n"
   set i 0
   foreach select [$tbl curselection] {
      set pos  [lindex [$tbl get $select] 0]
      set cata [lindex [$tbl get $select] 1]
      set ids  [lindex [$tbl get $select] 2]
      set x    [lindex [$tbl get $select] 3]
      set y    [lindex [$tbl get $select] 4]

      set width [expr 7 + $i * 2]
      affich_un_rond_xy $x $y green  $width 1
      #gren_info "cata = $cata ; ids = $ids \n"
      incr i
   }
}




proc ::bdi_gui_gestion_source::cmdButton1Click { tbl  args } {

   cleanmark
   set nb [llength [$tbl curselection] ]
   gren_info "Nb selected : $nb\n"
   set i 0
   foreach select [$tbl curselection] {
      set pos  [lindex [$tbl get $select] 0]
      set cata [lindex [$tbl get $select] 1]
      set ids  [lindex [$tbl get $select] 2]
      set x    [lindex [$tbl get $select] 3]
      set y    [lindex [$tbl get $select] 4]

      set width [expr 7 + $i * 2]
      affich_un_rond_xy $x $y green  $width 1
      #gren_info "cata = $cata ; ids = $ids \n"
      incr i
   }


}



proc ::bdi_gui_gestion_source::create_Tbl_sources { frmtable name_of_columns} {

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

     # popups
     $popupTbl add command -label "Console" -command "::bdi_gui_gestion_source::console $tbl"
     $popupTbl add command -label "Select" -command "::bdi_gui_gestion_source::select $tbl"
     $popupTbl add command -label "(n) Nouvelle source" -command "::bdi_gui_gestion_source::newsource $tbl"
     $popupTbl add command -label "(d) Supprimer" -command "::bdi_gui_gestion_source::deletesource $tbl"
     $popupTbl add command -label "(p) PSF sur la liste" -command "::bdi_gui_gestion_source::popup_psf_on_list $tbl"


   #--- Gestion des evenements
   bind [$tbl bodypath] <Control-Key-a> [ list ::bdi_gui_gestion_source::selectall $tbl ]
   bind [$tbl bodypath] <Key-d> [ list ::bdi_gui_gestion_source::deletesource $tbl ]
   bind [$tbl bodypath] <Key-n> [ list ::bdi_gui_gestion_source::newsource $tbl ]
   bind [$tbl bodypath] <Key-p> [ list ::bdi_gui_gestion_source::popup_psf_on_list $tbl ]
   bind $tbl <<ListboxSelect>>          [ list ::bdi_gui_gestion_source::cmdButton1Click %W ]
   bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

   pack  $tbl -in  $frmtable -expand yes -fill both

}




#------------------------------------------------------------
## Analyse de photocentre d'une source
# Permet de recombiner des catalogues pour une source,
# de mesurer la psf d'une source, de rappeler les
# conesearch dans une zone de l'image
# @param worklist list des indices des sources dont on veut se focaliser.
#  \sa bdi_gui_gestion_source::gestion_mode_manuel_init
proc ::bdi_gui_gestion_source::run { { worklist "" } } {

   global private

   ::audace::psf_init $::audace(visuNo)
   ::bdi_gui_gestion_source::init $worklist

#   gren_info "worklist = $worklist\n"

   set spinlist ""
   for {set i 1} {$i<$::bdi_tools_psf::psf_limitradius_max} {incr i} {lappend spinlist $i}
   set ::bdi_gui_gestion_source::visucrop ""
   set ::bdi_gui_gestion_source::bufcrop  ""


   set spinlist ""
   for {set i 1} {$i<$::bdi_tools_psf::psf_limitradius_max} {incr i} {lappend spinlist $i}

   set ::bdi_gui_gestion_source::fen .psf
   if { [winfo exists $::bdi_gui_gestion_source::fen] } {
      wm withdraw $::bdi_gui_gestion_source::fen
      wm deiconify $::bdi_gui_gestion_source::fen
      focus $::bdi_gui_gestion_source::fen
      return
   }
   toplevel $::bdi_gui_gestion_source::fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_gestion_source::fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_gestion_source::fen ] "+" ] 2 ]
   wm geometry $::bdi_gui_gestion_source::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_gestion_source::fen 1 1
   wm title $::bdi_gui_gestion_source::fen "PSF"
   wm protocol $::bdi_gui_gestion_source::fen WM_DELETE_WINDOW "::bdi_gui_gestion_source::fermer"

   set frm $::bdi_gui_gestion_source::fen.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_gestion_source::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5


      set info_source  [frame $frm.info_source -borderwidth 0 -cursor arrow -relief groove]
      pack $info_source -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          label $info_source.lab1 -text "Source : "
          pack  $info_source.lab1 -side left -padx 2 -pady 0

          label $info_source.labv -textvariable ::bdi_gui_cata::psf_name_source
          pack  $info_source.labv -side left -padx 2 -pady 0

      set info_cata  [frame $frm.info_cata -borderwidth 0 -cursor arrow -relief groove]
      pack $info_cata -in $frm -anchor s -side top -expand 1 -fill x -padx 10 -pady 5


      set info_img  [frame $frm.info_img -borderwidth 0 -cursor arrow -relief groove]
      pack $info_img -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

          label $info_img.title -text "Image : "
          pack  $info_img.title -side left -padx 2 -pady 0
          label $info_img.id -textvariable ::bdi_gui_gestion_source::id_img
          pack  $info_img.id -side left -padx 2 -pady 0
          label $info_img.lab -text "/"
          pack  $info_img.lab -side left -padx 2 -pady 0
          label $info_img.lab2 -text $::bdi_gui_gestion_source::nb_img_list
          pack  $info_img.lab2 -side left -padx 2 -pady 0

      set info_date [frame $frm.info_date -borderwidth 0 -cursor arrow ]
      pack $info_date -in $frm -anchor c -side top -expand 1

          label $info_date.id -textvariable ::bdi_gui_gestion_source::dateimg
          pack  $info_date.id -side left -padx 2 -pady 0

      set actions [frame $frm.actions1 -borderwidth 1 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top -expand 1

              button $actions.grab -state active -text "Grab" -relief "raised" \
               -command "::bdi_gui_gestion_source::gestion_mode_manuel_grab"
              pack   $actions.grab -side left -padx 0

              button $actions.foc -state active -text "Focus" -relief "raised" \
               -command "::bdi_gui_gestion_source::focus_source"
              pack   $actions.foc -side left -padx 0

              button $actions.new -state active -text "New" -relief "raised" \
               -command "::bdi_gui_gestion_source::gestion_mode_manuel_new"
              pack   $actions.new -side left -padx 0

              button $actions.save -state normal -text "Save" -relief "raised" \
               -command "::bdi_gui_gestion_source::mode_manuel_save"
              pack   $actions.save -side left -padx 0

      set actions [frame $frm.actions2 -borderwidth 1 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top -expand 1

              button $actions.prev -state disabled -text "Prev" -relief "raised" \
               -command "::bdi_gui_gestion_source::prev"
              pack   $actions.prev -side left -padx 0

              button $actions.next -state active -text "Next" -relief "raised" \
               -command "::bdi_gui_gestion_source::next"
              pack   $actions.next -side left -padx 0

              button $actions.nextauto -state active -text "Next & PSF" -relief "raised" \
               -command "::bdi_gui_gestion_source::nextpsf_img"
              pack   $actions.nextauto -side left -padx 0

              button $actions.savenextauto -state active -text "Save & Next & PSF" -relief "raised" \
               -command "::bdi_gui_gestion_source::savenextpsf_img"
              pack   $actions.savenextauto -side left -padx 0

      set actions [frame $frm.actions3 -borderwidth 1 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top

          label $actions.lab1 -text "Methode pour PSF : "
          label $actions.b -textvar private(psf_toolbox,$::audace(visuNo),methode) -width 13 -relief groove
          button $actions.psfc -state active -text "PSF" -relief "raised" \
               -command "::bdi_gui_gestion_source::psf"

          grid $actions.lab1 $actions.b $actions.psfc -sticky nsw -pady 3

      set actions [frame $frm.actions4 -borderwidth 1 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top

          button $actions.clean -state active -text "Clean" -relief "raised" \
               -command "cleanmark"

          grid $actions.clean -sticky nsw -pady 3


      # onglets : mesures, methode, rafale, conesearch, identification, cata

      set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5

      pack [ttk::notebook $onglets.nb] -expand yes -fill both
      set f1 [frame $onglets.nb.f1]
      set f2 [frame $onglets.nb.f2]
      set f3 [frame $onglets.nb.f3]
      set f4 [frame $onglets.nb.f4]
      set f5 [frame $onglets.nb.f5]
      set f6 [frame $onglets.nb.f6]

      $onglets.nb add $f1 -text "Mesures"
      $onglets.nb add $f2 -text "Methode"
      $onglets.nb add $f3 -text "Rafale"
      $onglets.nb add $f4 -text "Conesearch"
      $onglets.nb add $f5 -text "Identification"
      $onglets.nb add $f6 -text "Catalogues"

     $onglets.nb select $f1
     ttk::notebook::enableTraversal $onglets.nb


      # onglets : mesures
      set nbp [llength [::bdi_tools_psf::get_fields_current_psf] ]
      set cptmed [expr int($nbp/2)]


      set results [frame $f1.results -borderwidth 0 -cursor arrow -relief groove]
      pack $results -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      ::audace::psf_gui_graphes $::audace(visuNo) $results

      # onglets : methodes

      set methodes [frame $f2.methodes -borderwidth 0 -cursor arrow -relief groove]
      pack $methodes -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


           ::audace::psf_gui_methodes $::audace(visuNo) $methodes
#              ::bdi_gui_psf::gui_configuration $methodes


#              # configuration par onglets
#              set block [frame $methodes.conf -borderwidth 0 -cursor arrow -relief groove]
#              pack $block -in $methodes -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
#
#                   set meth_onglets [frame $block.meth_onglets -borderwidth 0 -cursor arrow -relief groove]
#                   pack $meth_onglets -in $block -side top -expand yes -fill both -padx 10 -pady 5
#
#                   pack [ttk::notebook $meth_onglets.nb] -expand yes -fill both
#                   set i 0
#                   foreach m [::bdi_tools_psf::get_methodes] {
#                      incr i
#                      set a [frame $meth_onglets.nb.g$i]
#                      set g$i $a
#                      $meth_onglets.nb add $a -text $m
#                   }
#
#              $meth_onglets.nb select $g1
#              ttk::notebook::enableTraversal $meth_onglets.nb
#
#
#              # configuration photombasic
#              set block [frame $g2.conf -borderwidth 0 -cursor arrow -relief groove]
#              pack $block -in $g2 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
#
#                     label $block.satl -text "Saturation (ADU): "
#                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5
#
#                     label $block.thrl -text "Threshold (arcsec): "
#                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5
#
#                     label $block.radl -text "Rayon : "
#                     spinbox $block.radiusc -values $spinlist -from 1 -to $::bdi_tools_psf::psf_limitradius_max \
#                         -textvariable ::bdi_tools_psf::psf_radius -width 3 \
#                         -command "::bdi_gui_gestion_source::psf"
#                     pack  $block.radiusc -side left
#                     $block.radiusc set 15
#
#                     grid $block.satl  $block.satv  -sticky nsw -pady 3
#                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
#                     grid $block.radl  $block.radiusc  -sticky nsw -pady 3
#
#              # configuration globale
#              set block [frame $g3.conf -borderwidth 0 -cursor arrow -relief groove]
#              pack $block -in $g3 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
#
#                     label $block.satl -text "Saturation (ADU): "
#                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5
#
#                     label $block.thrl -text "Threshold (arcsec): "
#                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5
#
#                     label $block.radl -text "Limite du Rayon : "
#                     entry $block.radv -textvariable ::bdi_tools_psf::psf_limitradius_max -relief sunken -width 5
#
#                     grid $block.satl  $block.satv  -sticky nsw -pady 3
#                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
#                     grid $block.radl  $block.radv  -sticky nsw -pady 3

      # onglets : conesearch

      set cataconf [frame $f4.conesearch -borderwidth 0 -cursor arrow -relief groove]
      pack $cataconf -in $f4 -anchor c -side top -expand 0 -padx 10 -pady 5

            checkbutton $cataconf.skybot_check -highlightthickness 0 -text "  SKYBOT" -variable ::tools_cata::use_skybot
               entry $cataconf.skybot_dir -relief flat -borderwidth 1 -textvariable ::tools_cata::catalog_skybot -width 30 -state disabled
            checkbutton $cataconf.usnoa2_check -highlightthickness 0 -text "  USNO-A2" -variable ::tools_cata::use_usnoa2 -state disabled
               entry $cataconf.usnoa2_dir -relief flat -textvariable ::tools_cata::catalog_usnoa2 -width 30 -state disabled
            checkbutton $cataconf.gaia1_check -highlightthickness 0 -text "  GAIA1" -variable ::tools_cata::use_gaia1
               entry $cataconf.gaia1_dir -relief flat -textvariable ::tools_cata::catalog_gaia1 -width 30 -state disabled
            checkbutton $cataconf.tycho2_check -highlightthickness 0 -text "  TYCHO-2" -variable ::tools_cata::use_tycho2
               entry $cataconf.tycho2_dir -relief flat -textvariable ::tools_cata::catalog_tycho2 -width 30 -state disabled
            checkbutton $cataconf.ucac2_check -highlightthickness 0 -text "  UCAC2" -variable ::tools_cata::use_ucac2
               entry $cataconf.ucac2_dir -relief flat -textvariable ::tools_cata::catalog_ucac2 -width 30 -state disabled
            checkbutton $cataconf.ucac3_check -highlightthickness 0 -text "  UCAC3" -variable ::tools_cata::use_ucac3
               entry $cataconf.ucac3_dir -relief flat -textvariable ::tools_cata::catalog_ucac3 -width 30 -state disabled
            checkbutton $cataconf.ucac4_check -highlightthickness 0 -text "  UCAC4" -variable ::tools_cata::use_ucac4
               entry $cataconf.ucac4_dir -relief flat -textvariable ::tools_cata::catalog_ucac4 -width 30 -state disabled
            checkbutton $cataconf.ppmx_check -highlightthickness 0 -text "  PPMX" -variable ::tools_cata::use_ppmx
               entry $cataconf.ppmx_dir -relief flat -textvariable ::tools_cata::catalog_ppmx -width 30 -state disabled
            checkbutton $cataconf.ppmxl_check -highlightthickness 0 -text "  PPMXL" -variable ::tools_cata::use_ppmxl
               entry $cataconf.ppmxl_dir -relief flat -textvariable ::tools_cata::catalog_ppmxl -width 30 -state disabled
            checkbutton $cataconf.nomad1_check -highlightthickness 0 -text "  NOMAD1" -variable ::tools_cata::use_nomad1
               entry $cataconf.nomad1_dir -relief flat -textvariable ::tools_cata::catalog_nomad1 -width 30 -state disabled
            checkbutton $cataconf.twomass_check -highlightthickness 0 -text "  2MASS" -variable ::tools_cata::use_2mass
               entry $cataconf.twomass_dir -relief flat -textvariable ::tools_cata::catalog_2mass -width 30 -state disabled
            checkbutton $cataconf.wfibc_check -highlightthickness 0 -text "  WFIBC" -variable ::tools_cata::use_wfibc
               entry $cataconf.wfibc_dir -relief flat -textvariable ::tools_cata::catalog_wfibc -width 30 -state disabled
            checkbutton $cataconf.sdss_check -highlightthickness 0 -text "  SDSS" -variable ::tools_cata::use_sdss
               entry $cataconf.sdss_dir -relief flat -textvariable ::tools_cata::catalog_sdss -width 30 -state disabled
            checkbutton $cataconf.panstarrs_check -highlightthickness 0 -text "  PANSTARRS" -variable ::tools_cata::use_panstarrs
               entry $cataconf.panstarrs_dir -relief flat -textvariable ::tools_cata::catalog_panstarrs -width 30 -state disabled
            frame $cataconf.blank -height 15

         grid $cataconf.skybot_check    $cataconf.skybot_dir    -sticky nsw -pady 3
         grid $cataconf.blank
         grid $cataconf.usnoa2_check    $cataconf.usnoa2_dir    -sticky nsw -pady 3
         grid $cataconf.gaia1_check     $cataconf.gaia1_dir     -sticky nsw -pady 3
         grid $cataconf.tycho2_check    $cataconf.tycho2_dir    -sticky nsw -pady 3
         grid $cataconf.ucac2_check     $cataconf.ucac2_dir     -sticky nsw -pady 3
         grid $cataconf.ucac3_check     $cataconf.ucac3_dir     -sticky nsw -pady 3
         grid $cataconf.ucac4_check     $cataconf.ucac4_dir     -sticky nsw -pady 3
         grid $cataconf.ppmx_check      $cataconf.ppmx_dir      -sticky nsw -pady 3
         grid $cataconf.ppmxl_check     $cataconf.ppmxl_dir     -sticky nsw -pady 3
         grid $cataconf.nomad1_check    $cataconf.nomad1_dir    -sticky nsw -pady 3
         grid $cataconf.twomass_check   $cataconf.twomass_dir   -sticky nsw -pady 3
         grid $cataconf.wfibc_check     $cataconf.wfibc_dir     -sticky nsw -pady 3
         grid $cataconf.sdss_check      $cataconf.sdss_dir      -sticky nsw -pady 3
         grid $cataconf.panstarrs_check $cataconf.panstarrs_dir -sticky nsw -pady 3

         button $f4.go -state active -text "Conesearch" -relief "raised" \
            -command ""
         pack $f4.go -in $f4 -anchor c


      # onglets : Catalogues

      set col_catalogues { 0 pos 0 Cata 0 IdS 0 x 0 y }

      set ::bdi_gui_gestion_source::gui_catalogues [frame $f6.catalogues -borderwidth 0 -cursor arrow -relief groove]
      pack $::bdi_gui_gestion_source::gui_catalogues -in $f6 -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
      ::bdi_gui_gestion_source::create_Tbl_sources $::bdi_gui_gestion_source::gui_catalogues $col_catalogues


      # Pied de page

      set actionspied [frame $frm.actionspied -borderwidth 0 -cursor arrow -relief groove]
      pack $actionspied -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $actionspied.fermer -state active -text "Fermer" -relief "raised" -command "::bdi_gui_gestion_source::fermer"
          pack   $actionspied.fermer -in $actionspied -side right -anchor w -padx 0


   ::bdi_gui_gestion_source::work_charge

   gren_info "TODO : Ecrire Ambigue , disable tous les boutons sauf grab"

#      bind $This <Key-F1> { ::console::GiveFocus }

}
