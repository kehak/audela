## @file bdi_gui_cata_creation.tcl
#  @brief     M&eacute;thodes d&eacute;di&eacute;es &agrave; la GUI de cr&eacute;ation des fichiers catalogues
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cata_creation.tcl]
#  @endcode

# $Id: bdi_gui_cata_creation.tcl 9215 2013-03-15 15:36:44Z jberthier $

##
# @namespace bdi_gui_cata_creation
# @brief M&eacute;thodes d&eacute;di&eacute;es &agrave; la GUI de cr&eacute;ation des fichiers catalogues
# @pre Requiert vo_tools 2.0
# @pre Requiert \c bdi_gui_cata .
# @pre Requiert \c tools_cata .
# @pre Requiert le fichier d'internationalisation \c gui_cata_creation.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cata_creation {

   package require vo_tools 2.0

   variable default_conf_sex [file join $audace(rep_plugin) tool bddimages config config.sex.template]
   variable user_conf_sex [file join $audace(rep_home) bddimages_config.sex]

   variable gui_sex_viewrejected

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_creation.cap ]\""

   #--- Init la variable de listenner pour le bouton Interop
   set ::vo_tools::interop($::audace(visuNo),interopListenner) ""

}

#------------------------------------------------------------
## Initialisation des parametres de la GUI creation du cata
# @return void
#
proc ::bdi_gui_cata_creation::inittoconf {  } {

   global conf

   # Initialisation au niveau GUI cata
   ::bdi_gui_cata::inittoconf
   ::bdi_gui_psf::inittoconf
   # Initialise la methode d'appariement
   ::bdi_tools_appariement::inittoconf

}



#------------------------------------------------------------
## Affectation des variables de conf en sortie de la GUI craetion cata
# @return void
#
proc ::bdi_gui_cata_creation::closetoconf { } {

   ::bdi_gui_cata::closetoconf
   ::bdi_gui_psf::closetoconf
   ::bdi_tools_appariement::closetoconf

}



#------------------------------------------------------------
## Actions a la sortie de la GUI creation cata
# @return void
#
proc ::bdi_gui_cata_creation::fermer { } {

   global conf action_label

   # Sauvegarde des parametres de mesure de psf
   ::audace::psf_close_to_conf $::audace(visuNo)

   # Fermeture de cette GUI
   ::bdi_gui_cata_creation::closetoconf

   # Destruction de la fenetre
   ::bdi_gui_cata_creation::recup_position
   destroy $::bdi_gui_cata_creation::fen

   # Rechargement des listes
   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
   cleanmark

}



#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_cata_creation::recup_position { } {

   global conf bddconf

   set bddconf(geometry_creation_cata) [wm geometry $::bdi_gui_cata_creation::fen]
   set conf(bddimages,geometry_creation_cata) $bddconf(geometry_creation_cata)

}



#------------------------------------------------------------
## Defini les coordonnees RA,DEC du centre de l'image
# @return void
#
proc ::bdi_gui_cata_creation::setval { } {

   set ::tools_cata::ra_save  $::tools_cata::ra
   set ::tools_cata::dec_save $::tools_cata::dec

   set err [ catch {set rect [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect ==""} {
      gren_info "Coordinates of image center: $::tools_cata::ra_save, $::tools_cata::dec_save\n"
      return
   }
   set xcent [format "%0.0f" [expr ([lindex $rect 0] + [lindex $rect 2])/2.]  ]
   set ycent [format "%0.0f" [expr ([lindex $rect 1] + [lindex $rect 1])/2.]  ]
   set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
   if {$err} {
      gren_erreur "Error gui_cata_creation::setval: $err -> $msg\n"
      return
   }
   set ::tools_cata::ra_save  [lindex $a 0]
   set ::tools_cata::dec_save [lindex $a 1]
   gren_info "Set new coordinates of image center to $::tools_cata::ra_save, $::tools_cata::dec_save\n"

}



#------------------------------------------------------------
## Reset les coordonnees du centre de l'image (a partir des valeurs initiales)
# @return void
#
proc ::bdi_gui_cata_creation::resetcenter { } {

   set ::tools_cata::ra  $::tools_cata::ra_save
   set ::tools_cata::dec $::tools_cata::dec_save
   gren_info "Reset coordinates of image center to $::tools_cata::ra $::tools_cata::dec\n"

}



#------------------------------------------------------------
## Identification des sources et affichage des catas
# @return void
#



proc ::bdi_gui_cata_creation::create_cata { } {

   set info [exec cat /proc/[pid]/status ]
   set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
   gren_info "memoire creation du cata demarrage pour 1 image : $mem\n"

   $::bdi_gui_cata::gui_create configure -state disabled
   $::bdi_gui_cata::gui_fermer configure -state disabled
   set next_state [$::bdi_gui_cata::gui_next cget -state]
   $::bdi_gui_cata::gui_next configure -state disabled
   set back_state [$::bdi_gui_cata::gui_back cget -state]
   $::bdi_gui_cata::gui_back configure -state disabled

   if { $::tools_cata::boucle == 1 } {

      ::bdi_gui_cata_creation::create_all_cata

   }  else {

      cleanmark

      set err [catch { ::bdi_gui_cata_creation::get_one_wcs } msg ]
      if {$err} {

         gren_erreur "create_cata: Pb with WCS\n"
         set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
         $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs
         cleanmark

      } else {

         set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good
         $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs

         set err [catch { ::tools_cata::get_cata 0 $::tools_cata::log } msg ]
         if {$err} {
            gren_erreur "create_cata: Error $err on CATA : $msg\n"
            set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_bad
            $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata
            #return false
         } else {
            set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_good
            $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata

            # Affiche le cata
            ::bdi_gui_cata::affiche_cata

            # Trace du repere E/N dans l'image
            set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
            set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
            set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
            ::bdi_gui_cata::trace_repere [list $cdelt1 $cdelt2]
            unset tabkey cdelt1 cdelt2
         }

      }

   }
   $::bdi_gui_cata::gui_create configure -state normal
   $::bdi_gui_cata::gui_fermer configure -state normal
   $::bdi_gui_cata::gui_next   configure -state $next_state
   $::bdi_gui_cata::gui_back   configure -state $back_state

   set info [exec cat /proc/[pid]/status ]
   set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
   gren_info "memoire fin creation du cata  : $mem\n"

}



#------------------------------------------------------------
## Identification des sources et affichage des catas en boucle continue
# @return void
#
proc ::bdi_gui_cata_creation::create_all_cata { } {

   cleanmark
   while {1==1} {

      if { $::tools_cata::boucle == 0 } {
         break
      }

   set info [exec cat /proc/[pid]/status ]
   set mem_deb [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ]


      set err [catch { ::bdi_gui_cata_creation::get_one_wcs } msg ]
      if {$err} {

         set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
         $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs
         cleanmark
         ::bdi_gui_cata::affiche_current_image
         break

      } else {

         set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good
         $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs

         if {$::tools_cata::create_cata == 1} {

            set err [catch { ::tools_cata::get_cata 0 $::tools_cata::log} msg ]
            if {$err} {
               # TODO ::bdi_gui_cata_creation::create_all_cata : gerer l'erreur le  cata a echou?
               gren_erreur "create_all_cata: Error on CATA : $msg\n"
               set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_bad
               $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata
               set ::tools_cata::boucle 0
               ::bdi_gui_cata::affiche_current_image
               break
            } else {
               # Ok ca se passe bien
               set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_good
               $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata
               update
               cleanmark
               ::bdi_gui_cata::affiche_current_image
               ::bdi_gui_cata::affiche_cata
               # Trace du repere E/N dans l'image
               set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
               set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
               set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
               ::bdi_gui_cata::trace_repere [list $cdelt1 $cdelt2]
               unset tabkey cdelt1 cdelt2
            }
         }
      }


   if {$::tools_cata::id_current_image == $::tools_cata::nb_img_list} { break }
   ::bdi_gui_cata_creation::next

   set info [exec cat /proc/[pid]/status ]
   set mem_fin [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ]
   set perte [format "%0.1f Mb" [expr $mem_fin - $mem_deb] ]
   gren_erreur "PERTE memoire : $perte\n"

   }

}



#------------------------------------------------------------
## Determination d'une solution astrometrique preliminaire de l'image sur la base des WCS
# @return void
#
proc ::bdi_gui_cata_creation::get_one_wcs { } {

      set tabkey        [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set date          [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs" ] 1] ]
      set bddimages_wcs [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]
      set idbddimg      [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set filename      [::bddimages_liste::lget $::tools_cata::current_image filename   ]
      set dirfilename   [::bddimages_liste::lget $::tools_cata::current_image dirfilename]

      set err [catch {::tools_cata::get_wcs 0 $::tools_cata::log} msg]

      if {$err == 0 } {

         set newimg [::bddimages_liste_gui::file_to_img $filename $dirfilename]

         set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] [expr $::tools_cata::id_current_image-1] $newimg]

         set idbddimg      [::bddimages_liste::lget $newimg idbddimg]
         set tabkey        [::bddimages_liste::lget $newimg "tabkey"]
         set bddimages_wcs [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1] ]

         set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good

         set ::tools_cata::ra       [lindex [::bddimages_liste::lget $tabkey RA      ] 1]
         set ::tools_cata::dec      [lindex [::bddimages_liste::lget $tabkey DEC     ] 1]
         set ::tools_cata::pixsize1 [lindex [::bddimages_liste::lget $tabkey PIXSIZE1] 1]
         set ::tools_cata::pixsize2 [lindex [::bddimages_liste::lget $tabkey PIXSIZE2] 1]
         set ::tools_cata::foclen   [lindex [::bddimages_liste::lget $tabkey FOCLEN  ] 1]
         set ::tools_cata::exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
         set ::tools_cata::crota1   [lindex [::bddimages_liste::lget $tabkey CROTA1  ] 1]
         set ::tools_cata::crota2   [lindex [::bddimages_liste::lget $tabkey CROTA2  ] 1]

         set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
         set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
         set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
         set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
         set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

         return true

      } else {

         gren_erreur "Error: ::bdi_gui_cata_creation::get_one_wcs: $msg\n (idbddimg : $idbddimg -> filename : $filename)\n"
         set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
         set ::tools_cata::boucle 0
         return -code 1 "Error: ::bdi_gui_cata_creation::get_one_wcs: $msg\n (idbddimg : $idbddimg -> filename : $filename)\n"

      }
}



#------------------------------------------------------------
## Chargement de l'image courante et de son cata
# @return void
#
proc ::bdi_gui_cata_creation::charge_current_image { } {

   global audace
   global bddconf

   gren_info "--------\n"

   set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image - 1] ]

   set err [catch {set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]} msg]
   if {$err} {
      gren_erreur "Erreur de lecture des infos du cata de l'image \n"
      gren_erreur "    err = $err\n"
      gren_erreur "    msg = $msg\n"
      gren_erreur "    idbddimg = $idbddimg\n"
      return
   }

   set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
   set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]
   set file        [file join $bddconf(dirbase) $dirfilename $filename]

   set ::tools_cata::current_image_name $filename
   set ::tools_cata::current_image_date $date

   set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey RA      ] 1]
   set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey DEC     ] 1]
   set ::tools_cata::crota1    [lindex [::bddimages_liste::lget $tabkey CROTA1  ] 1]
   set ::tools_cata::crota2    [lindex [::bddimages_liste::lget $tabkey CROTA2  ] 1]
   set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey PIXSIZE1] 1]
   set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey PIXSIZE2] 1]
   set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey FOCLEN  ] 1]
   set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
   set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs ] 1] ]

   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   if {$scale_x=="" || $scale_y == ""} {
      set ::tools_cata::radius 20
   } else {
      set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
   }

   set xcent [expr $naxis1/2.0]
   set ycent [expr $naxis2/2.0]

   gren_debug "---------------------------\n"
   gren_debug "IDBDDIMG = $idbddimg\n"
   gren_debug "FILENAME = $filename\n"
   gren_debug "DATE = $date\n"
   gren_debug "WCS = $::tools_cata::bddimages_wcs\n"
   gren_debug "CATAEXIST = $cataexist\n"
   gren_debug "ID_CURRENT_IMAGE = $::tools_cata::id_current_image\n"
   gren_debug "---------------------------\n"

   $::bdi_gui_cata::gui_dateimage configure -text $::tools_cata::current_image_date

   if {1==0} {
      set info [exec cat /proc/[pid]/status ]
      set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
      gren_info "memoire avant vidage du buffer : $mem\n"

      buf$::audace(bufNo) clear
   }

   set info [exec cat /proc/[pid]/status ]
   set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
   gren_info "memoire avant lecture du buffer : $mem\n"

   buf$::audace(bufNo) load $file
   gren_info "> Image chargee: [::bddimages_liste::lget $::tools_cata::current_image filename]\n"

   set info [exec cat /proc/[pid]/status ]
   set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
   gren_info "memoire apres lecture du buffer : $mem\n"

   ::confVisu::setFileName $::audace(visuNo) $file


   if { $::tools_cata::boucle == 0 } {

      set info [exec cat /proc/[pid]/status ]
      set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
      gren_info "memoire avant affiche_current_image : $mem\n"

      ::bdi_gui_cata::affiche_current_image

      set info [exec cat /proc/[pid]/status ]
      set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
      gren_info "memoire avant affiche_cata : $mem\n"

      set err [catch {::bdi_gui_cata::affiche_cata} msg ]
      if {$err} {
         gren_erreur "Erreur d'affichage du CATA\n"
         gren_erreur "err = $err\n"
         gren_erreur "msg = $msg\n"
         set cataexist 0
      }
   }

   #?Mise a jour GUI

   $::bdi_gui_cata::gui_back configure -state disabled

   $::bdi_gui_cata::gui_nomimage configure -text $::tools_cata::current_image_name
   $::bdi_gui_cata::gui_stimage  configure -text "$::tools_cata::id_current_image / $::tools_cata::nb_img_list"

   if {$::tools_cata::id_current_image == 1 && $::tools_cata::nb_img_list > 1 } {
      $::bdi_gui_cata::gui_back configure -state disabled
   }
   if {$::tools_cata::id_current_image == $::tools_cata::nb_img_list && $::tools_cata::nb_img_list > 1 } {
      $::bdi_gui_cata::gui_next configure -state disabled
   }
   if {$::tools_cata::id_current_image > 1 } {
      $::bdi_gui_cata::gui_back configure -state normal
   }
   if {$::tools_cata::id_current_image < $::tools_cata::nb_img_list } {
      $::bdi_gui_cata::gui_next configure -state normal
   }
   if {$::tools_cata::bddimages_wcs == "Y"} {
      set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good
      $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs
   } else {
      set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
      $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs
   }
   if {$cataexist == "1"} {
      set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_good
      $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata
   } else {
      set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_bad
      $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata
   }
   affich_un_rond_xy $xcent $ycent red 2 2
   $::bdi_gui_cata::gui_enrimg configure -state disabled

}



#------------------------------------------------------------
## Chargement de la liste des images, et affichage de la premiere image + cata
# @return void
#
proc ::bdi_gui_cata_creation::charge_list { img_list } {

   global audace
   global bddconf

   catch {
      if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
      if { [ info exists $::tools_cata::nb_img_list ] }        {unset ::tools_cata::nb_img_list}
      if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
      if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
   }

   set info [exec cat /proc/[pid]/status ]
   set mem [format "%0.1f Mb" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
   gren_info "Charge liste debut du programme : $mem\n"


   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

   foreach ::tools_cata::current_image $::tools_cata::img_list {
      set tabkey   [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set date     [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
      set idbddimg [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   }

   # Chargement premiere image sans GUI
   set ::tools_cata::id_current_image 1
   set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

   set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
   set file        [file join $bddconf(dirbase) $dirfilename $filename]

   set ::tools_cata::ra       [lindex [::bddimages_liste::lget $tabkey RA      ] 1]
   set ::tools_cata::dec      [lindex [::bddimages_liste::lget $tabkey DEC     ] 1]
   set ::tools_cata::crota1   [lindex [::bddimages_liste::lget $tabkey CROTA1  ] 1]
   set ::tools_cata::crota2   [lindex [::bddimages_liste::lget $tabkey CROTA2  ] 1]
   set ::tools_cata::pixsize1 [lindex [::bddimages_liste::lget $tabkey PIXSIZE1] 1]
   set ::tools_cata::pixsize2 [lindex [::bddimages_liste::lget $tabkey PIXSIZE2] 1]
   set ::tools_cata::foclen   [lindex [::bddimages_liste::lget $tabkey FOCLEN  ] 1]
   set ::tools_cata::exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
   set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]

   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   if {$scale_x == "" || $scale_y == ""} {
      set ::tools_cata::radius 20
   } else {
      set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
   }
   set xcent [expr $naxis1/2.0]
   set ycent [expr $naxis2/2.0]

   set ::tools_cata::current_image_name $filename
   set ::tools_cata::current_image_date $date

   #?Charge l image a l ecran
#      buf$::audace(bufNo) load $file

   set ::tools_cata::nb_img       0
   set ::tools_cata::nb_usnoa2    0
   set ::tools_cata::nb_tycho2    0
   set ::tools_cata::nb_ucac2     0
   set ::tools_cata::nb_ucac3     0
   set ::tools_cata::nb_ucac4     0
   set ::tools_cata::nb_ppmx      0
   set ::tools_cata::nb_ppmxl     0
   set ::tools_cata::nb_nomad1    0
   set ::tools_cata::nb_2mass     0
   set ::tools_cata::nb_wfibc     0
   set ::tools_cata::nb_sdss      0
   set ::tools_cata::nb_panstarrs 0
   set ::tools_cata::nb_gaia1     0
   set ::tools_cata::nb_skybot    0
   set ::tools_cata::nb_astroid   0

   cleanmark

   # Affiche l'image courante
   ::bdi_gui_cata::affiche_current_image
   # Affiche une marque au centre de l'image
   affich_un_rond_xy $xcent $ycent red 2 2
   # Affiche le cata s'il existe
   set err [catch {::bdi_gui_cata::affiche_cata} msg ]
   if {$err} {
      gren_erreur "Erreur d'affichage du CATA\n"
      gren_erreur "  err = $err\n"
      gren_erreur "  msg = $msg\n"
      set cataexist 0
   }

   # Etat des boutons et GUI
   set ::bdi_gui_cata::stateback disabled
   if {$::tools_cata::nb_img_list == 1} {
      set ::bdi_gui_cata::statenext disabled
   } else {
      set ::bdi_gui_cata::statenext normal
   }
   if {$::tools_cata::bddimages_wcs == "Y"} {
      set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good
   } else {
      set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
   }
   if {$cataexist == "1"} {
      set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_good
   } else {
      set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_bad
   }

}



#------------------------------------------------------------
## Charge la config Sextractor par defaut
# @return void
#
proc ::bdi_gui_cata_creation::get_default_confsex { } {

   global bddconf

   # Par defaut, affiche les sources rejetees par sextractor
   set ::bdi_gui_cata_creation::gui_sex_viewrejected 1

   # Verifie que le fichier utilisateur de la config sextractor existe
   # s'il n'existe pas, copie du template (config/config.sex.template) dans $HOME/.audela/bddimages_config.sex
   # et substitution des chemins pour pointer vers le dir TMP
   if { ! [file exists $::bdi_gui_cata_creation::user_conf_sex]} {
      set inf [open $::bdi_gui_cata_creation::default_conf_sex "r"]
      set ouf [open $::bdi_gui_cata_creation::user_conf_sex "w"]
      while {[gets $inf line] >= 0 } {
         regsub -- {TMP_DIR} $line $bddconf(dirtmp) line
         puts $ouf $line
      }
      close $inf
      close $ouf

      #set err [catch {file copy -force $::bdi_gui_cata_creation::default_conf_sex $::bdi_gui_cata_creation::user_conf_sex} msg ]
      #if {$err != 0} {
      #   gren_erreur "Error: gui_cata_creation::get_default_confsex: cannot copy $::bdi_gui_cata_creation::default_conf_sex to $::bdi_gui_cata_creation::user_conf_sex\n"
      #   return $err
      #}
   }

   # Lecture et affichage du fichier de config Sextractor
   set chan [open $::bdi_gui_cata_creation::user_conf_sex r]
   while {[gets $chan line] >= 0} {
      $::bdi_gui_cata_creation::fen.frm_creation_cata.onglets.nb.f5.confsex.file insert end "$line\n"
   }
   close $chan

}



#------------------------------------------------------------
## Charge la config Sextractor a partir de la zone de texte editable (onglet Sextractor)
# @return void
#
proc ::bdi_gui_cata_creation::set_user_confsex { } {

   global audace
   global bddconf

   set r [$::bdi_gui_cata_creation::fen.frm_creation_cata.onglets.nb.f5.confsex.file get 1.0 end]
   # Sauve la config Sextractor dans le fichier utilisateur
   set chan [open "$::bdi_gui_cata_creation::user_conf_sex" "w"]
   puts $chan $r
   close $chan
   # Copie la config dans le rep de travail
   ::bdi_tools_astrometry::copy_sextractor_config_file $::bdi_gui_cata_creation::user_conf_sex $bddconf(dirtmp)

}



#------------------------------------------------------------
## Test la config Sextractor a partir de la zone de texte editable (onglet Sextractor)
# @return void
#
proc ::bdi_gui_cata_creation::test_user_confsex { } {

   global bddconf

   gren_info "Test Sextractor ...\n"

   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   ::bdi_gui_cata::trace_repere [list $cdelt1 $cdelt2]
   if {1==1} {
      set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
      set mscale [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
      set radius [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]
      gren_info " ------------------------------------------\n"
      gren_info " naxis1  = $naxis1\n"
      gren_info " naxis2  = $naxis2\n"
      gren_info " ra      = [lindex [::bddimages_liste::lget $tabkey RA] 1]\n"
      gren_info " dec     = [lindex [::bddimages_liste::lget $tabkey DEC] 1]\n"
      gren_info " scale_x = $scale_x\n"
      gren_info " scale_y = $scale_y\n"
      gren_info " mscale  = $mscale\n"
      gren_info " radius  = $radius\n"
      gren_info " crota1  = [lindex [::bddimages_liste::lget $tabkey CROTA1] 1]\n"
      gren_info " crota2  = [lindex [::bddimages_liste::lget $tabkey CROTA2] 1]\n"
      gren_info " foclen  = [lindex [::bddimages_liste::lget $tabkey FOCLEN] 1]\n"
      gren_info " ------------------------------------------\n"
   }

   # Defini la config utilisateur de sextractor
   ::bdi_gui_cata_creation::set_user_confsex

   # Commande calibwcs a exectuer fourni par la methode d'appariement
   set ::bdi_tools_appariement::calibwcs_args "* * * * *"
   set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"
   gren_info "PASS1: $calibwcs_cmd\n"

   set err [catch {set nbstars [eval $calibwcs_cmd]} msg]

   if {$err} {
      gren_erreur "Error PASS1: #$err -> $msg\n"
      if {$::tools_cata::ra == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::ra_save]} {
         set ra $::tools_cata::ra_save
      } else {
         set ra $::tools_cata::ra
      }
      if {$::tools_cata::dec == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::dec_save]} {
         set dec $::tools_cata::dec_save
      } else {
         set dec $::tools_cata::dec
      }
      if {$::tools_cata::pixsize1 == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::pixsize1_save]} {
         gren_info "PIXSIZE1 not exist. affect save value = $::tools_cata::pixsize1_save\n"
         set pixsize1 $::tools_cata::pixsize1_save
         set ::tools_cata::pixsize1 $::tools_cata::pixsize1_save
      } else {
         set pixsize1 $::tools_cata::pixsize1
      }
      if {$::tools_cata::pixsize2 == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::pixsize2_save]} {
         gren_info "PIXSIZE2 not exist. affect save value = $::tools_cata::pixsize2_save\n"
         set pixsize2 $::tools_cata::pixsize2_save
         set ::tools_cata::pixsize2 $::tools_cata::pixsize2_save
      } else {
         set pixsize2 $::tools_cata::pixsize2
      }
      if {$::tools_cata::foclen == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::foclen_save]} {
         gren_info "FOCLEN not exist. affect save value = $::tools_cata::foclen_save\n"
         set foclen $::tools_cata::foclen_save
         set ::tools_cata::foclen $::tools_cata::foclen_save
      } else {
         set foclen $::tools_cata::foclen
      }
      set ::bdi_tools_appariement::calibwcs_args "$::tools_cata::ra $::tools_cata::dec $::tools_cata::pixsize1 $::tools_cata::pixsize2 $::tools_cata::foclen"
      set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"
      gren_info "PASS2: $calibwcs_cmd\n"
      set err [catch {set nbstars [eval $calibwcs_cmd]} msg]

      if {$err} {
         gren_erreur "Error PASS2: #$err -> $msg\n"
         return
      }

   }

   gren_info "  Nb stars detected = $nbstars\n"

   cleanmark
   set ::tools_cata::current_listsources [::bdi_tools_appariement::get_cata]
   affich_rond $::tools_cata::current_listsources IMG $::bdi_gui_cata::color_img $::bdi_gui_cata::size_img

   # Trace du repere E/N dans l'image
   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   ::bdi_gui_cata::trace_repere [list $cdelt1 $cdelt2]
   if {1==1} {
      set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
      set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
      set mscale [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
      set radius [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]
      gren_info " ------------------------------------------\n"
      gren_info " naxis1  = $naxis1\n"
      gren_info " naxis2  = $naxis2\n"
      gren_info " ra      = [lindex [::bddimages_liste::lget $tabkey RA] 1]\n"
      gren_info " dec     = [lindex [::bddimages_liste::lget $tabkey DEC] 1]\n"
      gren_info " scale_x = $scale_x\n"
      gren_info " scale_y = $scale_y\n"
      gren_info " mscale  = $mscale\n"
      gren_info " radius  = $radius\n"
      gren_info " crota1  = [lindex [::bddimages_liste::lget $tabkey CROTA1] 1]\n"
      gren_info " crota2  = [lindex [::bddimages_liste::lget $tabkey CROTA2] 1]\n"
      gren_info " foclen  = [lindex [::bddimages_liste::lget $tabkey FOCLEN] 1]\n"
      gren_info " ------------------------------------------\n"
   }
   unset tabkey cdelt1 cdelt2

}



#------------------------------------------------------------
## Grab une portion de la visu et une portion de la visu DSS pour
# selectionner une source et sa reference
# @return void
#
proc ::bdi_gui_cata_creation::grab { i } {

   set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect==""} {
      tk_messageBox -message "Veuillez selectionner une etoile en dessinant un carre dans l'image a reduire" -type ok
      return
   }
   set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
   set ::bdi_gui_cata::man_xy_star($i) "[format "%2.2f" [lindex $cent 0]] [format "%2.2f" [lindex $cent 1]]"
   set err [ catch {set rect  [ ::confVisu::getBox $::bdi_gui_cata::dssvisu ]} msg ]
   if {$err>0 || $rect==""} {
      tk_messageBox -message "Veuillez selectionner une etoile en dessinant un carre dans l'image DSS" -type ok
      return
   }
   set err [ catch {set cent [::tools_cdl::select_obj $rect $::bdi_gui_cata::dssbuf]} msg ]
   gren_info "DSS XY: $err : $rect : $msg\n"
   set err [ catch {set a [buf$::bdi_gui_cata::dssbuf xy2radec $cent]} msg ]
   if {$err} {
      gren_erreur "Error: gui_cata_creation::grab: $err -> $msg\n"
      return
   }
   set ::bdi_gui_cata::man_ad_star($i) "[lindex $a 0] [lindex $a 1]"

}



#------------------------------------------------------------
## Nettoie la table des sources et de leurs references dans
# le mode manuel de creation du cata
# @return void
#
proc ::bdi_gui_cata_creation::manual_clean {  } {

   for {set i 1} {$i<=7} {incr i} {
      set ::bdi_gui_cata::man_xy_star($i) ""
      set ::bdi_gui_cata::man_ad_star($i) ""
   }

}



#------------------------------------------------------------
## Affiche dans la visu les sources selectionnees pour
# le mode manuel de creation du cata
# @return void
#
proc ::bdi_gui_cata_creation::manual_view {  } {

   for {set i 1} {$i<=7} {incr i} {
      if {$::bdi_gui_cata::man_xy_star($i) != "" && $::bdi_gui_cata::man_ad_star($i) != ""} {
         set x [split $::bdi_gui_cata::man_xy_star($i) " "]
         set xsm [lindex $x 0]
         set ysm [lindex $x 1]
         affich_un_rond_xy  $xsm $ysm "blue" 10 2
      }
   }

}



#------------------------------------------------------------
## ???
#
# @return void
#
proc ::bdi_gui_cata_creation::manual_fit {  } {


   set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect==""} {
      tk_messageBox -message "Veuillez selectionner une etoile et une reference XY en dessinant un carre dans l'image a reduire" -type ok
      return
   }
   set x1 [lindex $rect 0]
   set y1 [lindex $rect 1]
   set x2 [lindex $rect 2]
   set y2 [lindex $rect 3]
   set xradius [expr $x2 - $x1]
   set yradius [expr $y2 - $y1]

   set id 0
   for {set i 1} {$i<=7} {incr i} {
      if {$::bdi_gui_cata::man_xy_star($i) != "" && $::bdi_gui_cata::man_ad_star($i) != ""} {
         set x [split $::bdi_gui_cata::man_xy_star($i) " "]
         set xsm [lindex $x 0]
         set ysm [lindex $x 1]
         if {$xsm>$x1 && $xsm<$x2 && $ysm > $y1 && $ysm < $y2 } {
            set id $i
            break
         }
      }
   }
   if {$id == 0} {
      tk_messageBox -message "Veuillez selectionner une etoile + une reference XY en dessinant un carre dans l'image a reduire" -type ok
      return
   }

   set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
   set xdiff [expr [lindex $cent 0] - $xsm]
   set ydiff [expr [lindex $cent 1] - $ysm]
   set rdiff [expr sqrt((pow($xdiff,2)+pow($ydiff,2))/2.0)]

   set err [catch {set ::bdi_gui_cata::man_xy_star($id) "[format "%2.2f" [lindex $cent 0]] [format "%2.2f" [lindex $cent 1]]"} msg ]
   if {$err} {
      gren_info "err: $err \n"
      gren_info "msg: $msg \n"
      gren_info "cnt 0: [lindex $cent 0] \n"
      gren_info "cnt 1: [lindex $cent 1] \n"
   }

   set rdiff ""
   for {set i 1} {$i<=7} {incr i} {
      if {$::bdi_gui_cata::man_xy_star($i) != "" && $::bdi_gui_cata::man_ad_star($i) != ""} {
         set x [split $::bdi_gui_cata::man_xy_star($i) " "]
         set xsm [expr [lindex $x 0] + $xdiff]
         set ysm [expr [lindex $x 1] + $ydiff]
         set x1 [expr $xsm - $xradius ]
         set y1 [expr $ysm - $yradius ]
         set x2 [expr $xsm + $xradius ]
         set y2 [expr $ysm + $yradius ]
         set rect [list $x1 $y1 $x2 $y2]
         set err [ catch {set cent [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
         set xdiff [expr [lindex $cent 0] - $xsm]
         set ydiff [expr [lindex $cent 1] - $ysm]
         lappend rdiff [expr sqrt((pow($xdiff,2)+pow($ydiff,2))/2.0)]
         set err [catch {set ::bdi_gui_cata::man_xy_star($i) "[format "%2.2f" [lindex $cent 0]] [format "%2.2f" [lindex $cent 1]]"    } msg ]
         if {$err} {
            gren_info "err: $err \n"
            gren_info "msg: $msg \n"
            gren_info "cnt 0: [lindex $cent 0] \n"
            gren_info "cnt 1: [lindex $cent 1] \n"
         }
      }
   }
   set rdiff [::math::statistics::max $rdiff]

   cleanmark
   ::bdi_gui_cata_creation::manual_view

}



proc ::bdi_gui_cata_creation::manual_create_wcs_test {  } {

   gren_info "manual_create_wcs_test\n"

   for {set i 1} {$i<=7} {incr i} {
      set ::bdi_gui_cata::man_xy_star($i) ""
   }
   for {set i 1} {$i<=7} {incr i} {
      set ::bdi_gui_cata::man_ad_star($i) ""
   }
   set ::bdi_gui_cata::man_xy_star(1) "756.27 962.93"
   set ::bdi_gui_cata::man_xy_star(2) "730.72 511.74"
   set ::bdi_gui_cata::man_xy_star(3) "345.60 717.79"
   set ::bdi_gui_cata::man_xy_star(4) "711.30 668.55"
   set ::bdi_gui_cata::man_xy_star(5) "213.40 438.23"
   set ::bdi_gui_cata::man_ad_star(1) "265.002279 -15.459027"
   set ::bdi_gui_cata::man_ad_star(2) "265.005853 -15.514163"
   set ::bdi_gui_cata::man_ad_star(3) "265.054556 -15.488658"
   set ::bdi_gui_cata::man_ad_star(4) "265.008090 -15.494978"
   set ::bdi_gui_cata::man_ad_star(5) "265.071672 -15.522862"
}




#------------------------------------------------------------
## Creation de la calibration WCS d'une image en mode manuel,
# a partir des etoiles (et de leurs references) definies dans
# la GUI (onglet Manuel). L'astrometrie est calculee par Priam.
# @return void
#
proc ::bdi_gui_cata_creation::manual_create_wcs {  } {

   global audace bddconf private

   ::tools_cata::push_img_list

   $::bdi_gui_cata::gui_enrimg    configure -state disabled
   $::bdi_gui_cata::gui_creercata configure -state disabled

   gren_info "Creation Manuelle du WCS\n"

   set sources {}
   set fieldimg [list "IMG" [list "ra" "dec" "err_pos" "mag" "err_mag"] [::tools_cata::get_img_fields]]

   # Liste des etoiles pointees a la mano
   gren_info "     Preparation des sources\n"
   for {set i 1} {$i<=7} {incr i} {
      if {$::bdi_gui_cata::man_xy_star($i) != "" && $::bdi_gui_cata::man_ad_star($i) != ""} {
         set x [split $::bdi_gui_cata::man_xy_star($i) " "]
         set xsm [lindex $x 0]
         set ysm [lindex $x 1]
         set x [split $::bdi_gui_cata::man_ad_star($i) " "]
         set ra [lindex $x 0]
         set dec [lindex $x 1]
         set b [::tools_cata::get_img_null]
         set b [lreplace $b 2 3 $xsm $ysm]
         set b [lreplace $b 8 9 $ra $dec]
         lappend sources [list [list "IMG" [list $ra $dec 0 0 0] $b ] ]
      }
   }
   set fields  [list $fieldimg]
   set listsources [list $fields $sources]

   gren_info "     Mesure des PSF\n"

   ::bdi_tools_psf::get_psf_listsources listsources "yes"

   gren_info "$private(psf_toolbox,$audace(visuNo),psf,rdiff)   \n"

   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
   if {[::manage_source::get_nb_sources_by_cata $listsources ASTROID] < 3} {
      tk_messageBox -message "Moins de 3 etoiles de reference valide (ASTROID). Calibration astrometrique impossible." -type ok
      return
   }

   gren_info "     Creation des fichiers et lancement de Priam\n"
   set id 0
   set ls [lindex $listsources 1]
   foreach s $ls {
      set x  [lsearch -index 0 $s "ASTROID"]
      if {$x>=0} {
         set astroid [lindex $s $x]
         set othf [lindex $astroid 2]
         ::bdi_tools_psf::set_by_key othf "flagastrom" "R"
         ::bdi_tools_psf::set_by_key othf "cataastrom" "IMG"
         set astroid [lreplace $astroid 2 2 $othf]
         set s [lreplace $s $x $x $astroid]
         set ls [lreplace $ls $id $id $s]
      }
      incr id
   }
   set listsources [lreplace $listsources 1 1 $ls]

   set ::tools_cata::img_list [list $::tools_cata::current_image]
   array unset ::bdi_gui_cata::cata_list
   set ::bdi_gui_cata::cata_list(1) $listsources

   set tt0 [clock clicks -milliseconds]
   ::bdi_tools_astrometry::init_priam
   ::bdi_tools_astrometry::exec_priam
   gren_info "Determination de la solution astrometrique (Priam) en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

   foreach vals $::tools_cata::new_astrometry(1) {
      buf$::audace(bufNo) setkwd $vals
   }

   set key [list "BDDIMAGES WCS" "Y" "string" "WCS performed: Y|N|?" ""]
   buf$::audace(bufNo) setkwd $key

   set filename [::bddimages_liste::lget $::tools_cata::current_image filename]
   set filename [string range $filename 0 [expr [string last .gz $filename] -1]]
   set file [file join $bddconf(dirtmp) $filename]
   gren_info  "file = $file\n"

   gren_info "     Enregistrement du WCS dans l'image $file\n"

   saveima $file
   loadima $file

   # Obtention du nouvel header
   set err [catch {set tabkey [::bdi_tools_image::get_tabkey_from_buffer] } msg ]
   if {$err} {
      gren_erreur "Error: gui_cata_creation::manual_create_wcs: tabkey non charge: $err -> $msg\n"
      set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
      $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs
      ::tools_cata::pop_img_list
      return
   }

   ::tools_cata::pop_img_list

   # redefini l'image avec le tabkey
   set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]

   # finalisation gui
   set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good
   $::bdi_gui_cata::gui_wcs       configure -bg $::bdi_gui_cata::color_wcs
   $::bdi_gui_cata::gui_enrimg    configure -state normal
   $::bdi_gui_cata::gui_creercata configure -state normal

   return

}

proc ::bdi_gui_cata_creation::get_wcs_fields {  } {
   return [list EQUINOX RADESYS CTYPE1 CTYPE2 LONPOLE CUNIT1 CUNIT2 CRPIX1 CRPIX2 FOCLEN RA DEC CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA1 CROTA2 CD1_1 CD1_2 CD2_1 CD2_2 ]
}


proc ::bdi_gui_cata_creation::paste_wcs {  } {

   if {[info exists ::bdi_gui_cata_creation::wcs_to_paste]} {
      set lh [::bdi_gui_cata_creation::get_wcs_fields]
      foreach key $lh {
         buf$::audace(bufNo) setkwd $::bdi_gui_cata_creation::wcs_to_paste($key)
      }
      $::bdi_gui_cata::gui_enrimg    configure -state normal
      saveima i
      loadima i
   }
}

proc ::bdi_gui_cata_creation::copy_wcs {  } {

   array unset ::bdi_gui_cata_creation::wcs_to_paste
   set lh [::bdi_gui_cata_creation::get_wcs_fields]
   foreach key $lh {
      set ::bdi_gui_cata_creation::wcs_to_paste($key) [buf$::audace(bufNo) getkwd $key]
   }
   $::bdi_gui_cata::gui_paste_wcs configure -state normal


}

proc ::bdi_gui_cata_creation::voir_wcs {  } {

   set lh [::bdi_gui_cata_creation::get_wcs_fields]
   foreach key $lh {
      gren_info "[buf$::audace(bufNo) getkwd $key]\n"

   }
}

proc ::bdi_gui_cata_creation::modif_centre_arcsec { x y } {

   set kra  [buf$::audace(bufNo) getkwd "CRVAL1"]
   set kdec [buf$::audace(bufNo) getkwd "CRVAL2"]
   set ra   [lindex $kra 1]
   set dec  [lindex $kdec 1]

   gren_debug "avant  RA DEC : $ra $dec\n"
   set radec [buf$::audace(bufNo) xy2radec {512 512}]
   gren_debug "Centre : $radec\n"

   set ra   [expr $ra + $x/3600.]
   set dec  [expr $dec + $y/3600.]
   set kra  [lreplace $kra 1 1 $ra]
   set kdec [lreplace $kdec 1 1 $dec]
   buf$::audace(bufNo) setkwd $kra
   buf$::audace(bufNo) setkwd $kdec

   saveima i
   loadima i

   gren_debug "apres  RA DEC : $ra $dec\n"
   set radec [buf$::audace(bufNo) xy2radec {512 512}]
   gren_debug "Centre : $radec\n"
}




proc ::bdi_gui_cata_creation::voir_usno {  } {

   global bddconf

   set scale_x [lindex [buf$::audace(bufNo) getkwd "CDELT1" ] 1]
   set scale_y [lindex [buf$::audace(bufNo) getkwd "CDELT2" ] 1]
   set naxis1  [lindex [buf$::audace(bufNo) getkwd "NAXIS1" ] 1]
   set naxis2  [lindex [buf$::audace(bufNo) getkwd "NAXIS2" ] 1]
   set xcent   [expr $naxis1/2.0]
   set ycent   [expr $naxis2/2.0]
   set a       [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
   set ra      [lindex $a 0]
   set dec     [lindex $a 1]
   set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
   set usnoa2  [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius]
   set usnoa2  [::manage_source::set_common_fields $usnoa2 USNOA2 { magR 0.5 }]

   set fields  [lindex $usnoa2 0]
   set sources [lindex $usnoa2 1]
   set newsources ""
   set tabmag ""
   set id 0
   foreach s $sources {
      foreach cata $s {
         if { [lindex $cata 0] == "USNOA2" } {
            set cm [lindex $cata 1]
            set ra [lindex $cm 0]
            set dec [lindex $cm 1]
            set mag [lindex $cm 3]
            if {$ra != "" && $dec != ""} {
               set img_xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $img_xy 0]
               set y [lindex $img_xy 1]
               if {$x > 0 && $x < $naxis1 && $y > 0 && $y < $naxis2} {
                  lappend newsource $s
                  lappend tabmag [list $id $mag]
                  incr id
               }
            }
         }
      }
   }
   set usnoa2 [list $fields $newsource]

   set tabmag [lsort -index 1 $tabmag]

   set nbs [::manage_source::get_nb_sources_by_cata $usnoa2 "USNOA2"]
   gren_debug "$nbs Sources USNOA2 extraites -> ROLLUP = [::manage_source::get_nb_sources_rollup $usnoa2]\n"

   affich_rond $usnoa2 "USNOA2" $::bdi_gui_cata::color_usnoa2  $::bdi_gui_cata::size_usnoa2

   set cpt 0
   foreach x $tabmag {
      set id [lindex $x 0]

      set ra  [lindex $usnoa2 [list 1 $id 0 1 0]]
      set dec [lindex $usnoa2 [list 1 $id 0 1 1]]

      affich_un_rond $ra $dec red 2
      incr cpt
      if {$cpt>100} {break}
   }

   gren_info "Green circles: $nbs USNOA2 STARS\n"
   gren_info "Red circle: 100 brighests USNOA2 STARS\n"
}




proc ::bdi_gui_cata_creation::manual_priam {  } {

   global bddconf

   cleanmark

   ::tools_cata::push_img_list

   set tabkey  [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1 ] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2 ] 1]
   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
   set xcent   [expr $naxis1/2.0]
   set ycent   [expr $naxis2/2.0]
   set a       [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
   set ra      [lindex $a 0]
   set dec     [lindex $a 1]
   set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]
   set usnoa2  [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius]
   set usnoa2  [::manage_source::set_common_fields $usnoa2 USNOA2 { magR 0.5 }]

   set fields  [lindex $usnoa2 0]
   set sources [lindex $usnoa2 1]
   set newsources ""
   set tabmag ""
   set id 0
   foreach s $sources {
      foreach cata $s {
         if { [lindex $cata 0] == "USNOA2" } {
            set cm [lindex $cata 1]
            set ra [lindex $cm 0]
            set dec [lindex $cm 1]
            set mag [lindex $cm 3]
            if {$ra != "" && $dec != ""} {
               set img_xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $img_xy 0]
               set y [lindex $img_xy 1]
               if {$x > 0 && $x < $naxis1 && $y > 0 && $y < $naxis2} {
                  lappend newsources $s
                  lappend tabmag [list $id $mag]
                  incr id
               }
            }
         }
      }
   }
   set usnoa2 [list $fields $newsources]
   set tabmag [lsort -index 1 $tabmag]

   set newsources ""
   set cpt 0
   foreach x $tabmag {
      set id [lindex $x 0]
      set s [lindex $usnoa2 [list 1 $id]]
      set ra  [lindex $s { 0 1 0 } ]
      set dec [lindex $s { 0 1 1 } ]

      set err [ catch {set err_psf [::bdi_tools_psf::get_psf_source s "no" "no"] } msg ]

      if {$err || $err_psf != ""} {
         continue
      }

      set x  [lsearch -index 0 $s "ASTROID"]
      if {$x>=0} {
         set astroid [lindex $s $x]
         set othf [lindex $astroid 2]
         ::bdi_tools_psf::set_by_key othf "flagastrom" "R"
         ::bdi_tools_psf::set_by_key othf "cataastrom" "USNOA2"
         set astroid [lreplace $astroid 2 2 $othf]
         set s [lreplace $s $x $x $astroid]
         lappend newsources $s
         affich_un_rond $ra $dec green 2
         incr cpt
      }
      if {$cpt>99} {break}
   }

   set usnoa2 [list $fields $newsources]
   if {$cpt > 0} {::bdi_tools_psf::set_fields_astroid usnoa2}
   set nbs [::manage_source::get_nb_sources_by_cata $usnoa2 "USNOA2"]
   gren_debug "$nbs Sources USNOA2 extraites -> ROLLUP = [::manage_source::get_nb_sources_rollup $usnoa2]\n"

   set ::tools_cata::img_list [list $::tools_cata::current_image]
   array unset ::bdi_gui_cata::cata_list
   set ::bdi_gui_cata::cata_list(1) $usnoa2

   set tt0 [clock clicks -milliseconds]
   ::bdi_tools_astrometry::init_priam
   ::bdi_tools_astrometry::exec_priam
   gren_info "Determination de la solution astrometrique (Priam) en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

   foreach vals $::tools_cata::new_astrometry(1) {
      buf$::audace(bufNo) setkwd $vals
   }

   set key [list "BDDIMAGES WCS" "Y" "string" "WCS performed: Y|N|?" ""]
   buf$::audace(bufNo) setkwd $key

   set filename [::bddimages_liste::lget $::tools_cata::current_image filename]
   set filename [string range $filename 0 [expr [string last .gz $filename] -1]]
   set file [file join $bddconf(dirtmp) $filename]
   gren_info "Enregistrement du WCS dans l'image $file\n"

   saveima $file
   loadima $file

   # Obtention du nouvel header
   set err [catch {set tabkey [::bdi_tools_image::get_tabkey_from_buffer] } msg ]
   if {$err} {
      gren_erreur "Error: gui_cata_creation::manual_create_wcs: tabkey non charge: $err -> $msg\n"
      set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_bad
      $::bdi_gui_cata::gui_wcs configure -bg $::bdi_gui_cata::color_wcs
      ::tools_cata::pop_img_list
      return
   }

   ::tools_cata::pop_img_list

   set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]

   # affiche etoiles de ref
   affich_rond $usnoa2 "USNOA2" red  2

   # finalisation gui
   set ::bdi_gui_cata::color_wcs $::bdi_gui_cata::color_button_good

   $::bdi_gui_cata::gui_wcs       configure -bg $::bdi_gui_cata::color_wcs
   $::bdi_gui_cata::gui_enrimg    configure -state normal
   $::bdi_gui_cata::gui_creercata configure -state normal

   gren_info "Fin...\n"

}

#------------------------------------------------------------
## Creation des cata d'une image en mode manuel.
# @return void
#
proc ::bdi_gui_cata_creation::manual_create_cata {  } {

   global bddconf

   ::tools_cata::push_img_list

   set ::tools_cata::create_cata 0
   $::bdi_gui_cata::gui_enrimg configure -state disabled

   # Lancement Sextractor
   set ext $::conf(extension,defaut)
   set mypath "."
   set sky0 dummy0
   set sky dummy
   catch {buf$::audace(bufNo) delkwd CATASTAR}
   buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
   createFileConfigSextractor
   buf$::audace(bufNo) save [ file join ${mypath} ${sky}$ext ]
   ::bdi_gui_cata_creation::set_user_confsex
   sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"

   # Extraction Resultat Sextractor et Creation de la liste
   set fields [list [list IMG [list ra dec poserr mag magerr] [::tools_cata::get_img_fields]]]
   set sources {}
   set chan [open "catalog.cat" r]
   while {[gets $chan line] >= 0} {
      set a [split $line "="]
      set a [lindex $a 0]
      set a [split $a " "]
      set c {}
      foreach b $a {
         if {$b==""} {continue}
         lappend c $b
      }
      set id                 [lindex $c 0]
      set flux_sex           [lindex $c 1]
      set err_flux_sex       [lindex $c 2]
      set instr_mag          [lindex $c 3]
      set err_mag            [lindex $c 4]
      set background_sex     [lindex $c 5]
      set xpos               [lindex $c 6]
      set ypos               [lindex $c 7]
      set major_axis_sex     [lindex $c 11]
      set minor_axis_sex     [lindex $c 12]
      set position_angle_sex [lindex $c 13]
      set fwhm_sex           [lindex $c 14]
      set flag_sex           [lindex $c 15]
      set radec  [buf$::audace(bufNo) xy2radec [list $xpos $ypos]]
      set ra  [lindex $radec 0]
      set dec [lindex $radec 1]

      set l [list $id 1 $xpos $ypos $instr_mag $err_mag $flux_sex $err_flux_sex $ra $dec \
                  0.0 0.0 0.0 0.0 0.0 0 0 \
                  $background_sex 0.0 0.0 0.0 $major_axis_sex $minor_axis_sex $position_angle_sex \
                  $fwhm_sex $flag_sex]
      lappend sources [list [list "IMG" {} $l]]

   }
   set ::tools_cata::current_listsources [list $fields $sources]
   set ::tools_cata::current_listsources [::bdi_tools_sources::set_common_fields $::tools_cata::current_listsources IMG { calib_mag calib_mag_ss1}]
   #::manage_source::imprim_3_sources $::tools_cata::current_listsources

   # Modification de la liste
   set tabkey  [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1 ] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2 ] 1]
   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
   set xcent   [expr $naxis1/2.0]
   set ycent   [expr $naxis2/2.0]

   set a       [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
   set ra      [lindex $a 0]
   set dec     [lindex $a 1]
   set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

   # 1ere identification sur l USNOA2
   #set first_ident_cata "USNOA2"
   #gren_debug "csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius\n"
   #set usnoa2 [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius]
   #set usnoa2 [::bdi_tools_sources::set_common_fields $usnoa2 USNOA2 { magR 0.5 }]
   #affich_rond $usnoa2 USNOA2 $::bdi_gui_cata::color_usnoa2  $::bdi_gui_cata::size_usnoa2
   #set ::tools_cata::current_listsources [identification $::tools_cata::current_listsources IMG $usnoa2 USNOA2 30.0 -30.0 {} 0]
   #set nbs [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources "USNOA2"]
   #gren_debug "     $nbs Sources identifiees -> ROLLUP = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   #if {[::manage_source::get_nb_sources_by_cata  $::tools_cata::current_listsources USNOA2] <= 2 } {
   #   gren_erreur "WCS Impossible\n"
   #   ::tools_cata::pop_img_list
   #   return
   #}

   # 1ere identification sur l UCAC4
   set first_ident_cata "UCAC4"
   gren_debug "csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius\n"
   set ucac4 [csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius]
   set ucac4 [::bdi_tools_sources::set_common_fields $ucac4 UCAC4 { im2_mag sigmag_mag }]
   affich_rond $ucac4 UCAC4  $::bdi_gui_cata::color_ucac4  $::bdi_gui_cata::size_ucac4
   set ::tools_cata::current_listsources [ identification $::tools_cata::current_listsources IMG $ucac4 UCAC4 30.0 -30.0 {} 0]
   set nbs [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources "UCAC4"]
   gren_debug "     $nbs Sources identifiees -> ROLLUP = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   if {[::manage_source::get_nb_sources_by_cata  $::tools_cata::current_listsources UCAC4] <= 2 } {
      gren_erreur "WCS Impossible\n"
      ::tools_cata::pop_img_list
      return
   }

   set ::tools_cata::ra  $ra
   set ::tools_cata::dec $dec

   # Calcul des magnitudes

   set fields [lindex $::tools_cata::current_listsources 0]
   set sources [lindex $::tools_cata::current_listsources 1]
   set newsources ""
   foreach s $sources {
      set news ""
      foreach cata $s {
         if {[lindex $cata 0] == "IMG"} {
            set c [lindex $cata 1]
            set l [lindex $cata 2]
            set flux [lindex $l 6]

            set tabmagref ""
            set tabfluxref ""
            set tabmag ""
            foreach s2 $sources {
               foreach cata2 $s2 {
                  if {[lindex $cata2 0] == $first_ident_cata} {
                     set magref [lindex [lindex $cata2 1] 3]
                     lappend tabmagref $magref

                     foreach cata3 $s2 {
                        if {[lindex $cata3 0] == "IMG"} {
                           set fluxref  [lindex [lindex $cata3 2] 6]
                           lappend tabfluxref $fluxref
                           set magobjcalc [expr $magref - log10(($flux*1.0)/($fluxref*1.0))*2.5]
                           lappend tabmag $magobjcalc
                        }
                     }
                  }
               }
            }
            set mag [::math::statistics::median $tabmag]
            #set errmag [::math::statistics::mean $errmag]
            #set errmag [::math::statistics::stdev $mag]
            set c [ lreplace $c 3 3 $mag]
            lappend news [list "IMG" $c $l]
         } else {
           lappend news $cata
         }
      }
      lappend newsources $news
   }
   set ::tools_cata::current_listsources [list $fields $newsources]

   # calcule l erreur en mag
   set tabdmag ""
   set sources [lindex $::tools_cata::current_listsources 1]
   foreach s $sources {
      foreach cata $s {
         if {[lindex $cata 0] == "IMG"} {
            set mag [lindex [lindex $cata 1] 3]
            foreach cata2 $s {
               if {[lindex $cata2 0] == $first_ident_cata} {
                  set magcata [lindex [lindex $cata2 1] 3]
                  lappend tabdmag [expr abs($magcata - $mag)]
               }
            }
         }
      }
   }
   set dmag [::math::statistics::median $tabdmag]
   set stdmag [::math::statistics::stdev $tabdmag]
   set dmag [expr $dmag + $stdmag]

   # mise a jour de l erreur en mag
   set fields [lindex $::tools_cata::current_listsources 0]
   set sources [lindex $::tools_cata::current_listsources 1]
   set newsources ""
   foreach s $sources {
      set news ""
      foreach cata $s {
         if {[lindex $cata 0] == "IMG"} {
            set c [lindex $cata 1]
            set l [lindex $cata 2]
            set c [lreplace $c 4 4 $dmag]
            lappend news [list "IMG" $c $l]
         } else {
           lappend news $cata
         }
      }
      lappend newsources $news
   }
   set ::tools_cata::current_listsources [list $fields $newsources]

   # Resultats des magnitudes
   #::manage_source::get_fields_from_sources $::tools_cata::current_listsources

   set log 0

   if {$log} {
      set sources [lindex $::tools_cata::current_listsources 1]
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "IMG"} {
              set l [lindex $cata 2]
              set flux [lindex $l 6]
              set mag [lindex [lindex $cata 1] 3]
              set errmag [lindex [lindex $cata 1] 4]
              gren_debug "IMG $flux $mag $errmag "
              foreach cata2 $s {
                 if {[lindex $cata2 0] == $first_ident_cata} {
                    gren_debug "($first_ident_cata) "
                    set dmag [expr [lindex [lindex $cata2 1] 3] - $mag ]
                    set emag [lindex [lindex $cata2 1] 4]
                    gren_debug " $dmag $emag "
                 }
              }
              gren_debug "\n"
            }
         }
      }
   }

   #set ::tools_cata::current_listsources [::bdi_tools_sources::set_common_fields $::tools_cata::current_listsources IMG { calib_mag calib_mag_ss1}]
   #::manage_source::imprim_3_sources $::tools_cata::current_listsources
   set ::tools_cata::current_listsources [::manage_source::extract_catalog $::tools_cata::current_listsources "IMG"]
   gren_debug "rollupsE = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   # Obtention du CATA
   if {[::tools_cata::get_cata] == false} {
      set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_bad
      $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata
   } else {
      set ::bdi_gui_cata::color_cata $::bdi_gui_cata::color_button_good
      $::bdi_gui_cata::gui_cata configure -bg $::bdi_gui_cata::color_cata

      set imgfilename [::bddimages_liste::lget $::tools_cata::current_image filename]
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      # Sauvegarde du cata XML
      gren_info "Enregistrement du cata XML: $cataxml\n"
      set votable [::votableUtil::list2votable $::tools_cata::current_listsources $tabkey]
      set fxml [open $cataxml "w"]
      puts $fxml $votable
      close $fxml
   }

   gren_debug "rollupE = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   $::bdi_gui_cata::gui_enrimg configure -state normal
   ::tools_cata::pop_img_list

   gren_info "Fin...\n"
}



#------------------------------------------------------------
## Insertion d'une image dans la bdd en mode manuel.
# @return void
#
proc ::bdi_gui_cata_creation::manual_insert_img {  } {

   global bddconf

   set log 1

   set idbddimg [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]
   set imgfilename [::bddimages_liste::lget $::tools_cata::current_image "filename"]
   set dirimgfilename [::bddimages_liste::lget $::tools_cata::current_image "dirfilename"]
   set imgfilebase [file join $bddconf(dirbase) $dirimgfilename $imgfilename]

   set imgfilename [::bddimages_liste::lget $::tools_cata::current_image filename]
   set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
   set cataxml "${f}_cata.xml"

   set imgfilename [unzipedfilename $imgfilename]
   set imgfiletmp [file join $bddconf(dirtmp) $imgfilename]

   gren_info "Verification image $idbddimg\n"

   set ident [bddimages_image_identification $idbddimg]
   set fileimg [lindex $ident 1]
   set idbddcata [lindex $ident 2]
   set catafilebase [lindex $ident 3]

   if {$fileimg == -1} {
      gren_erreur "Fichier image inexistant ($idbddimg) \n"
      gren_erreur "Fichier image inexistant ($idbddimg) \n"
      return
   }

   if {$imgfilebase!=$fileimg} {
      gren_erreur "Insertion de l image impossible\n"
      gren_erreur "Le fichiers sont different.\n"
      gren_erreur "Fichier MEMORY $filebase\n"
      gren_erreur "Fichier SQL $fileimg\n"
      return
   }

   if {![file exists $imgfiletmp]} {
      gren_erreur "Le fichier n existe pas\n"
      gren_erreur "Creez le WCS\n"
      return
   }

   if {$catafilebase == -1 } {
      if {$log} {gren_info "cata n existe pas dans la base\n"}
   } else {
      if {$log} {gren_info "cata existe dans la base\n"}
      if {$log} {gren_info "cata dans la base = $catafilebase\n"}
      if {$log} {gren_info "idbddcata = $idbddcata\n"}
   }

   gren_info "Effacement de l image dans la base\n"

   # efface l image dans la base et le disque
   bddimages_image_delete_fromsql $ident
   bddimages_image_delete_fromdisk $ident

   gren_info "Insertion de l image dans la base\n"
   gren_debug "idlist : $::tools_cata::id_current_image\n"
   set i [::bddimages_liste::lget [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image -1]] "idbddimg"]
   gren_debug "idlist2 : $i\n"

   # Insertion de l image
   set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
   catch {gren_info "$errnum : $msg : $r"}
   if {$errnum==0} {

      # Modification de l idbddimg
      gren_info "\nInsertion reussie\n"
      gren_info "  Old Idbddimg = $i\n"
      gren_info "  New Idbddimg = $r\n"
      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "idbddimg" $r]

      set idbddimg $r

      # Modification du tabkey
      gren_info "Chargement du TABKEY depuis le buffer\n"
      set err [catch {set tabkey [::bdi_tools_image::get_tabkey_from_buffer]} msg]
      if {$err} {
         gren_erreur "Insertion Impossible :($err) $msg \n"
         return
      }

      # Modification du tabkey
      gren_info "Modification du TABKEY\n"
      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "tabkey" $tabkey]

      # Insertion du cata
      gren_info "Verification cata pour idbddimg=$idbddimg\n"
      gren_info "catafile : $cataxml\n"

      if {![file exists $cataxml]} {
         gren_erreur "Le fichier cata n existe pas\n"
      } else {
         if {$log} {gren_info "Le fichier cata existe dans tmp\n"}
         set ident [bddimages_image_identification $idbddimg]
         set catafilebase [lindex $ident 3]
         set idbddcata [lindex $ident 2]
         if {$catafilebase == -1 } {
            if {$log} {gren_info "cata n existe pas dans la base\n"}
            # insertion du CATA
            set errnum [catch {set r [insertion_solo $cataxml]} msg ]
            catch {gren_info "$errnum : $msg : $r"}
            if {$errnum==0} {
               gren_info "\nInsertion reussie\n"
               gren_info "New Idbddcata = $r\n"
               ::bdi_gui_cata::affiche_cata
            }

         } else {
            if {$log} {gren_info "cata existe dans la base\n"}
            if {$log} {gren_info "cata dans la base = $catafilebase\n"}
            if {$log} {gren_info "idbddcata = $idbddcata\n"}
         }
      }

      # Modification img_list
      gren_info "Modification de img_list\n"
      set i [expr $::tools_cata::id_current_image -1]
      set ::tools_cata::img_list [lreplace $::tools_cata::img_list $i $i $::tools_cata::current_image]

    }

}



#------------------------------------------------------------
## Fonction d'acces a plusieurs actions, dediee au developpement.
# @param tag string Mot cle designant l'action: box | all | 3sources
# @return void
#
proc ::bdi_gui_cata_creation::develop { tag } {

   switch $tag {

      "box" {
         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         if {$err>0 || $rect ==""} {
            tk_messageBox -message "Veuillez selectionner un carre dans l'image" -type ok
            return
         }
         set l [::manage_source::extract_sources_by_array $rect $::tools_cata::current_listsources]
         ::manage_source::imprim_all_sources $l
      }

      "all" {
         ::manage_source::imprim_all_sources $::tools_cata::current_listsources
      }

      "3sources" {
         ::manage_source::imprim_3_sources $::tools_cata::current_listsources
      }

   }

}



#------------------------------------------------------------
## Affiche l'image suivante
# @return void
#
proc ::bdi_gui_cata_creation::next { } {

   if {$::tools_cata::id_current_image < $::tools_cata::nb_img_list} {
      incr ::tools_cata::id_current_image
      catch {unset ::tools_cata::current_listsources}
      gren_msg "Chargement de l'image: [::bddimages_liste::lget $::tools_cata::current_image filename]\n"
      ::bdi_gui_cata_creation::charge_current_image
   }

}



#------------------------------------------------------------
## Affiche l'image precedente
# @return void
#
proc ::bdi_gui_cata_creation::back { } {

   if {$::tools_cata::id_current_image > 1 } {
      incr ::tools_cata::id_current_image -1
      catch {unset ::tools_cata::current_listsources}
      gren_msg "Chargement de l'image: [::bddimages_liste::lget $::tools_cata::current_image filename]\n"
      ::bdi_gui_cata_creation::charge_current_image
   }
}



#------------------------------------------------------------
## Change le statut des elements des options de creation du cata Astroid (mesures de PSF)
# @param this string pathName des elements de GUI concernes par un changement de statut
# @return void
#
proc ::bdi_gui_cata_creation::handlePSFParams { this } {

   if {$::bdi_tools_psf::use_psf} {
      $this.opts.saturation.val   configure -state normal
      $this.opts.delta.val        configure -state normal
      $this.methglobale.check     configure -state normal
      $this.opts2.threshold.val   configure -state normal
      $this.opts2.limitradius.val configure -state normal
      if {$::bdi_tools_psf::use_global} {
         $this.opts2.threshold.val   configure -state normal
         $this.opts2.limitradius.val configure -state normal
         $this.opts.delta.val        configure -state disabled
      } else {
         $this.opts2.threshold.val   configure -state disabled
         $this.opts2.limitradius.val configure -state disabled
         $this.opts.delta.val        configure -state normal
      }
   } else {
      $this.opts.saturation.val   configure -state disabled
      $this.opts.delta.val        configure -state disabled
      $this.methglobale.check     configure -state disabled
      $this.opts2.threshold.val   configure -state disabled
      $this.opts2.limitradius.val configure -state disabled
   }

}



#------------------------------------------------------------
## Creation du menu Audace->Interop, et gestion de l'etat des boutons de broadcast
# @return void
#
proc ::bdi_gui_cata_creation::startInterop { } {

   set w $::bdi_gui_cata_creation::votoolsmenu

   set err [ catch {::vo_tools::InstallMenuInterop $w} msg ]
   if {$err == 1} {
      gren_erreur "Warning: gui_cata_creation::startInterop: $msg\n"
   }

   ::bdi_gui_cata_creation::handleVOButtons

}



#------------------------------------------------------------
## Gestion de l'etat des boutons de broadcast vers les outils VO
# @param args string pathName des boutons a gerer (w.action.imgtab, w.action.script)
# @return void
# @todo args à vérifier
proc ::bdi_gui_cata_creation::handleVOButtons { args } {

   global audace

   if {$args ne "disabled"} {

      # Bouton Interop
      set w $::bdi_gui_cata_creation::votoolsmenu
      set err [catch {MenuGet $::audace(visuNo) "Interop"} msg]
      if {! $err} {
         pack forget $w
      } else {
         pack $w
      }

      # Boutons action
      set w $::bdi_gui_cata_creation::votoolsaction
      set but [list $w.broadcast $w.script]
      foreach b $but {
         if {[::Samp::isConnected]} {
            $b configure -state active
         } else {
            $b configure -state disable
         }
      }

   }

}


#------------------------------------------------------------
## GUI de choix de la couleur pour l'affichage des catalogues
# @param color_cata string Couleur initiale
# @param button string pathName du bouton a colorer
# @return void
#
proc ::bdi_gui_cata_creation::choose_color { color_cata button } {

   upvar $color_cata color
   ::bdi_gui_config::choose_color color $button
   ::bdi_gui_cata::affiche_cata

}


#proc ::bdi_gui_cata_creation::select_cs_gaia { loc } {
#
#   
#   #gren_info  "select gaia : loc : $loc \n"
#   #gren_info  " etat : gaiaw : $::tools_cata::use_gaia \n"
#   #gren_info  " etat : gaial : $::tools_cata::use_gaia1 \n"
#   
#   set wgw $::bdi_gui_cata_creation::widget(conesearch,wg).gaia_check
#   set wgl $::bdi_gui_cata_creation::widget(conesearch,wg).gaia1_check
#   
#   if {$loc == "dir"} {
#      if {$::tools_cata::use_gaia1==1} {
#         # on a selectionne gaialocal
#         if {$::tools_cata::use_gaia==1} {set ::tools_cata::use_gaia 0}
#      } else {
#         # on a deselectionne gaialocal
#      }
#   }
#   if {$loc == "www"} {
#      if {$::tools_cata::use_gaia==1} {
#         # on a selectionne gaia www
#         if {$::tools_cata::use_gaia1==1} {set ::tools_cata::use_gaia1 0}
#      } else {
#         # on a deselectionne gaia www
#      }
#   }
#   
#}


#------------------------------------------------------------
## GUI principale de creation des fichiers catalogues d'un lot d'images
# @param img_list list Liste des images (\sa charge_list).
# @return void
#
proc ::bdi_gui_cata_creation::go { img_list } {

   global audace caption
   global conf bddconf
   global private

   ::bdi_gui_cata_creation::charge_list $img_list
   catch { ::tools_cata::set_aladin_script_params }

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_creation_cata) ] } { set conf(bddimages,geometry_creation_cata) "+100+100" }
   set bddconf(geometry_creation_cata) $conf(bddimages,geometry_creation_cata)

   #--- Creation de la fenetre
   set ::bdi_gui_cata_creation::fen .new
   if { [winfo exists $::bdi_gui_cata_creation::fen] } {
      wm withdraw $::bdi_gui_cata_creation::fen
      wm deiconify $::bdi_gui_cata_creation::fen
      focus $::bdi_gui_cata_creation::fen
      return
   }

   #--- GUI
   toplevel $::bdi_gui_cata_creation::fen -class Toplevel
   wm geometry $::bdi_gui_cata_creation::fen $bddconf(geometry_creation_cata)
   wm resizable $::bdi_gui_cata_creation::fen 1 1
   wm title $::bdi_gui_cata_creation::fen "$caption(gui_cata_creation,title)"
   wm protocol $::bdi_gui_cata_creation::fen WM_DELETE_WINDOW "::bdi_gui_cata_creation::fermer"

   set frm $::bdi_gui_cata_creation::fen.frm_creation_cata

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cata_creation::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un frame pour les ACTIONS
      set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
          set ::bdi_gui_cata::gui_back [button $actions.back -text "$caption(gui_cata_creation,prec)" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata_creation::back" -state $::bdi_gui_cata::stateback]
          pack $actions.back -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
          set ::bdi_gui_cata::gui_next [button $actions.next -text "$caption(gui_cata_creation,next)" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata_creation::next" -state $::bdi_gui_cata::statenext]
          pack $actions.next -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
          set ::bdi_gui_cata::gui_create [button $actions.go -text "$caption(gui_cata_creation,create)" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata_creation::create_cata" -state normal]
          pack $actions.go -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
          set ::bdi_gui_cata::gui_stimage [label $actions.stimage -text "$::tools_cata::id_current_image / $::tools_cata::nb_img_list"]
          pack $::bdi_gui_cata::gui_stimage -side left -padx 3 -pady 3
          set bouc [frame $actions.bouc -borderwidth 0 -cursor arrow -relief groove]
          pack $bouc -in $actions -side left -expand 0 -fill x -padx 10 -pady 5
               checkbutton $bouc.check -highlightthickness 0 -text "$caption(gui_cata_creation,analyse)" -variable ::tools_cata::boucle
               pack $bouc.check -in $bouc -side left -padx 5 -pady 0
          set lampions [frame $actions.actions -borderwidth 0 -cursor arrow -relief groove]
          pack $lampions -in $actions -anchor s -side right -expand 0 -fill x -padx 10 -pady 5
               set ::bdi_gui_cata::gui_wcs [button $lampions.wcs -text "WCS" -borderwidth 1 -takefocus 0 -command "" \
                  -bg $::bdi_gui_cata::color_wcs -relief sunken -state disabled]
               pack $lampions.wcs -side top -anchor e -expand 0 -fill x -padx 0 -pady 0 -ipadx 0 -ipady 0
               set ::bdi_gui_cata::gui_cata [button $lampions.cata -text "CATA" -borderwidth 1 -takefocus 0 -command "" \
                  -bg $::bdi_gui_cata::color_cata -relief sunken -state disabled]
               pack $lampions.cata -side top -anchor e -expand 0 -fill x -padx 0 -pady 0 -ipadx 0 -ipady 0

      #--- Cree un frame pour les onglets
      set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets -in $frm -side top -expand 0 -fill x -padx 10 -pady 5

         pack [ttk::notebook $onglets.nb]
         set f1 [frame $onglets.nb.f1]
         set f2 [frame $onglets.nb.f2]
         set f3 [frame $onglets.nb.f3]
         set f5 [frame $onglets.nb.f5]
         set f6 [frame $onglets.nb.f6]
         set f7 [frame $onglets.nb.f7]
         set f8 [frame $onglets.nb.f8]
         set f9 [frame $onglets.nb.f9]

         $onglets.nb add $f1 -text $caption(gui_cata_creation,catalogue)
         $onglets.nb add $f2 -text $caption(gui_cata_creation,variables)
         $onglets.nb add $f3 -text $caption(gui_cata_creation,image)
         $onglets.nb add $f5 -text $caption(gui_cata_creation,sextractor)
         $onglets.nb add $f6 -text $caption(gui_cata_creation,psf)
         $onglets.nb add $f7 -text $caption(gui_cata_creation,interop)
         $onglets.nb add $f8 -text $caption(gui_cata_creation,manuel)
         $onglets.nb add $f9 -text $caption(gui_cata_creation,develop)

         $onglets.nb select $f3
         ttk::notebook::enableTraversal $onglets.nb

      #-----------------------------------------------------------------------
      #--- Onglet CATALOGUES
      #-----------------------------------------------------------------------

      #--- Cree un frame pour afficher les onglets
      set subonglets [frame $f1.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $subonglets -in $f1 -side top -expand 1 -fill both -padx 5 -pady 5

         pack [ttk::notebook $subonglets.list] -expand yes -fill both -padx 5 -pady 5

         set conesearch [frame $subonglets.list.cs]
         pack $conesearch -in $subonglets.list -expand yes -fill both
         $subonglets.list add $conesearch -text "$caption(gui_cata_creation,conesearch)"

         set appariement [frame $subonglets.list.app]
         pack $appariement -in $subonglets.list -expand yes -fill both
         $subonglets.list add $appariement -text "$caption(gui_cata_creation,appariement)"

         set affichage [frame $subonglets.list.cata]
         pack $affichage -in $subonglets.list -expand yes -fill both
         $subonglets.list add $affichage -text "$caption(gui_cata_creation,dispcata)"


         #--- Cree un frame pour la liste des cata
         label $conesearch.titre -text "$caption(gui_cata_creation,conesearchmsg)" -font $bddconf(font,arial_10_b)
         pack $conesearch.titre -in $conesearch -side top -fill x -anchor c -pady 10

         #--- Cree un frame pour la liste des cata
         set cataconf [frame $conesearch.conf -borderwidth 0 -relief groove]
         pack $cataconf -in $conesearch -anchor c -side top -expand 0 -padx 10 -pady 5
         set ::bdi_gui_cata_creation::widget(conesearch,wg) $cataconf
         
            checkbutton $cataconf.skybot_check -highlightthickness 0 -text "  SKYBOT" -variable ::tools_cata::use_skybot
               entry $cataconf.skybot_dir -relief flat -borderwidth 1 -textvariable ::tools_cata::catalog_skybot -width 35 -state disabled
            checkbutton $cataconf.sdss_check -highlightthickness 0 -text "  SDSS" -variable ::tools_cata::use_sdss
               entry $cataconf.sdss_dir -relief flat -borderwidth 1 -textvariable ::tools_cata::catalog_sdss -width 35 -state disabled
            checkbutton $cataconf.panstarrs_check -highlightthickness 0 -text "  PANSTARRS" -variable ::tools_cata::use_panstarrs
               entry $cataconf.panstarrs_dir -relief flat -borderwidth 1 -textvariable ::tools_cata::catalog_panstarrs -width 35 -state disabled
            checkbutton $cataconf.usnoa2_check -highlightthickness 0 -text "  USNO-A2" -variable ::tools_cata::use_usnoa2 -state disabled  \
                  -command {
                     if {$::tools_cata::use_usnoa2 == 0 && $::bdi_tools_appariement::calibwcs_method == 0} {
                        tk_messageBox -title "Warning" -type ok -message "$caption(gui_cata_creation,appariementusno)"
                        set ::tools_cata::use_usnoa2 1
                     }
                     ::bdi_tools_appariement::update_current_refcatalist usnoa2 $::tools_cata::use_usnoa2 $::tools_cata::catalog_usnoa2
                   }
               entry $cataconf.usnoa2_dir -relief flat -textvariable ::tools_cata::catalog_usnoa2 -width 35 -state disabled
            checkbutton $cataconf.gaia1_check -highlightthickness 0 -text "  GAIA1" -variable ::tools_cata::use_gaia1 \
                  -command {::bdi_tools_appariement::update_current_refcatalist gaia1 $::tools_cata::use_gaia1 $::tools_cata::catalog_gaia1}
               entry $cataconf.gaia1_dir -relief flat -textvariable ::tools_cata::catalog_gaia1 -width 35 -state disabled
            checkbutton $cataconf.tycho2_check -highlightthickness 0 -text "  TYCHO-2" -variable ::tools_cata::use_tycho2 \
                  -command {::bdi_tools_appariement::update_current_refcatalist tycho2 $::tools_cata::use_tycho2 $::tools_cata::catalog_tycho2}
               entry $cataconf.tycho2_dir -relief flat -textvariable ::tools_cata::catalog_tycho2 -width 35 -state disabled
            checkbutton $cataconf.ucac2_check -highlightthickness 0 -text "  UCAC2" -variable ::tools_cata::use_ucac2 \
                  -command {::bdi_tools_appariement::update_current_refcatalist ucac2 $::tools_cata::use_ucac2 $::tools_cata::catalog_ucac2}
               entry $cataconf.ucac2_dir -relief flat -textvariable ::tools_cata::catalog_ucac2 -width 35 -state disabled
            checkbutton $cataconf.ucac3_check -highlightthickness 0 -text "  UCAC3" -variable ::tools_cata::use_ucac3 \
                  -command {::bdi_tools_appariement::update_current_refcatalist ucac3 $::tools_cata::use_ucac3 $::tools_cata::catalog_ucac3}
               entry $cataconf.ucac3_dir -relief flat -textvariable ::tools_cata::catalog_ucac3 -width 35 -state disabled
            checkbutton $cataconf.ucac4_check -highlightthickness 0 -text "  UCAC4" -variable ::tools_cata::use_ucac4 \
                  -command {::bdi_tools_appariement::update_current_refcatalist ucac4 $::tools_cata::use_ucac4 $::tools_cata::catalog_ucac4}
               entry $cataconf.ucac4_dir -relief flat -textvariable ::tools_cata::catalog_ucac4 -width 35 -state disabled
            checkbutton $cataconf.ppmx_check -highlightthickness 0 -text "  PPMX" -variable ::tools_cata::use_ppmx \
                  -command {::bdi_tools_appariement::update_current_refcatalist ppmx $::tools_cata::use_ppmx $::tools_cata::catalog_ppmx}
               entry $cataconf.ppmx_dir -relief flat -textvariable ::tools_cata::catalog_ppmx -width 35 -state disabled
            checkbutton $cataconf.ppmxl_check -highlightthickness 0 -text "  PPMXL" -variable ::tools_cata::use_ppmxl \
                  -command {::bdi_tools_appariement::update_current_refcatalist ppmxl $::tools_cata::use_ppmxl $::tools_cata::catalog_ppmxl}
               entry $cataconf.ppmxl_dir -relief flat -textvariable ::tools_cata::catalog_ppmxl -width 35 -state disabled
            checkbutton $cataconf.nomad1_check -highlightthickness 0 -text "  NOMAD1" -variable ::tools_cata::use_nomad1 \
                  -command {::bdi_tools_appariement::update_current_refcatalist nomad1 $::tools_cata::use_nomad1 $::tools_cata::catalog_nomad1}
               entry $cataconf.nomad1_dir -relief flat -textvariable ::tools_cata::catalog_nomad1 -width 35 -state disabled
            checkbutton $cataconf.twomass_check -highlightthickness 0 -text "  2MASS" -variable ::tools_cata::use_2mass \
                  -command {::bdi_tools_appariement::update_current_refcatalist 2mass $::tools_cata::use_2mass $::tools_cata::catalog_2mass}
               entry $cataconf.twomass_dir -relief flat -textvariable ::tools_cata::catalog_2mass -width 35 -state disabled
            checkbutton $cataconf.wfibc_check -highlightthickness 0 -text "  WFIBC" -variable ::tools_cata::use_wfibc \
                  -command {::bdi_tools_appariement::update_current_refcatalist wfibc $::tools_cata::use_wfibc $::tools_cata::catalog_wfibc}
               entry $cataconf.wfibc_dir -relief flat -textvariable ::tools_cata::catalog_wfibc -width 35 -state disabled
            frame $cataconf.blank -height 15

         grid $cataconf.skybot_check    $cataconf.skybot_dir    -sticky nsw -pady 3
         grid $cataconf.sdss_check      $cataconf.sdss_dir      -sticky nsw -pady 3
         grid $cataconf.panstarrs_check $cataconf.panstarrs_dir -sticky nsw -pady 3
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
         grid columnconfigure $cataconf 0 -pad 30


         #--- Cree un frame pour la liste des cata
         label $appariement.titre -text "$caption(gui_cata_creation,appariementmsg)" -font $bddconf(font,arial_10_b)
         pack $appariement.titre -in $appariement -side top -fill x -anchor c -pady 10

         #--- Cree un frame pour les options d'appariement
         set catappa [frame $appariement.conf -borderwidth 0 -relief groove]
         pack $catappa -in $appariement -anchor c -side top -expand 0 -padx 10 -pady 5

            ::bdi_tools_appariement::gui $catappa

         #--- Cree un frame pour la liste des cata
         set catafftitre [frame $affichage.titre -borderwidth 0 -relief groove]
         pack $catafftitre -in $affichage -anchor w -side top -expand 0 -fill x -padx 10 -pady 10
            label $catafftitre.lab -text "$caption(gui_cata_creation,dispcatamsg)" -font $bddconf(font,arial_10_b)
            pack $catafftitre.lab -in $catafftitre -side top -fill x -anchor c -pady 10

         #--- Cree un frame pour la liste des cata
         set cataff [frame $affichage.conf -borderwidth 0 -relief groove]
         pack $cataff -in $affichage -anchor c -side top -expand 0 -padx 10 -pady 5

            checkbutton $cataff.skybot_check -highlightthickness 0 -text "  SKYBOT" \
               -variable ::bdi_gui_cata::gui_skybot -command "::bdi_gui_cata::affiche_cata"
               label $cataff.skybot_val -textvariable ::tools_cata::nb_skybot -width 4
               button $cataff.skybot_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_skybot \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_skybot $cataff.skybot_color"
               spinbox $cataff.skybot_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_skybot -command "::bdi_gui_cata::affiche_cata"
               $cataff.skybot_radius set $::bdi_gui_cata::size_skybot_sav
            checkbutton $cataff.gaia1_check -highlightthickness 0 -text "  GAIA1" \
               -variable ::bdi_gui_cata::gui_gaia1 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.gaia1_val -textvariable ::tools_cata::nb_gaia1 -width 4
               button $cataff.gaia1_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_gaia1 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_gaia1 $cataff.gaia1_color"
               spinbox $cataff.gaia1_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_gaia1 -command "::bdi_gui_cata::affiche_cata"
               $cataff.gaia1_radius set $::bdi_gui_cata::size_gaia1_sav
            checkbutton $cataff.sdss_check -highlightthickness 0 -text "  SDSS" \
               -variable ::bdi_gui_cata::gui_sdss -command "::bdi_gui_cata::affiche_cata"
               label $cataff.sdss_val -textvariable ::tools_cata::nb_sdss -width 4
               button $cataff.sdss_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_sdss \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_sdss $cataff.sdss_color"
               spinbox $cataff.sdss_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_sdss -command "::bdi_gui_cata::affiche_cata"
               $cataff.sdss_radius set $::bdi_gui_cata::size_sdss_sav
            checkbutton $cataff.panstarrs_check -highlightthickness 0 -text "  PANSTARRS" \
               -variable ::bdi_gui_cata::gui_panstarrs -command "::bdi_gui_cata::affiche_cata"
               label $cataff.panstarrs_val -textvariable ::tools_cata::nb_panstarrs -width 4
               button $cataff.panstarrs_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_panstarrs \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_panstarrs $cataff.panstarrs_color"
               spinbox $cataff.panstarrs_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_panstarrs -command "::bdi_gui_cata::affiche_cata"
               $cataff.panstarrs_radius set $::bdi_gui_cata::size_panstarrs_sav
            checkbutton $cataff.astroid_check -highlightthickness 0 -text "  ASTROID" \
               -variable ::bdi_gui_cata::gui_astroid -command "::bdi_gui_cata::affiche_cata"
               label $cataff.astroid_val -textvariable ::tools_cata::nb_astroid -width 4
               button $cataff.astroid_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_astroid \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_astroid $cataff.astroid_color"
               spinbox $cataff.astroid_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_astroid -command "::bdi_gui_cata::affiche_cata"
               $cataff.astroid_radius set $::bdi_gui_cata::size_astroid_sav
            checkbutton $cataff.img_check -highlightthickness 0 -text "  IMG" \
               -variable ::bdi_gui_cata::gui_img -command "::bdi_gui_cata::affiche_cata"
               label $cataff.img_val -textvariable ::tools_cata::nb_img -width 4
               button $cataff.img_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_img \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_img $cataff.img_color"
               spinbox $cataff.img_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_img -command "::bdi_gui_cata::affiche_cata"
               $cataff.img_radius set $::bdi_gui_cata::size_img_sav
            checkbutton $cataff.usnoa2_check -highlightthickness 0 -text "  USNOA2" \
               -variable ::bdi_gui_cata::gui_usnoa2 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.usnoa2_val -textvariable ::tools_cata::nb_usnoa2 -width 4
               button $cataff.usnoa2_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_usnoa2 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_usnoa2 $cataff.usnoa2_color"
               spinbox $cataff.usnoa2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_usnoa2 -command "::bdi_gui_cata::affiche_cata"
               $cataff.usnoa2_radius set $::bdi_gui_cata::size_usnoa2_sav
            checkbutton $cataff.tycho2_check -highlightthickness 0 -text "  TYCHO2" \
               -variable ::bdi_gui_cata::gui_tycho2 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.tycho2_val -textvariable ::tools_cata::nb_tycho2 -width 4
               button $cataff.tycho2_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_tycho2 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_tycho2 $cataff.tycho2_color"
               spinbox $cataff.tycho2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_tycho2 -command "::bdi_gui_cata::affiche_cata"
               $cataff.tycho2_radius set $::bdi_gui_cata::size_tycho2_sav
            checkbutton $cataff.ucac2_check -highlightthickness 0 -text "  UCAC2" \
               -variable ::bdi_gui_cata::gui_ucac2 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.ucac2_val -textvariable ::tools_cata::nb_ucac2 -width 4
               button $cataff.ucac2_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ucac2 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_ucac2 $cataff.ucac2_color"
               spinbox $cataff.ucac2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_ucac2 -command "::bdi_gui_cata::affiche_cata"
               $cataff.ucac2_radius set $::bdi_gui_cata::size_ucac2_sav
            checkbutton $cataff.ucac3_check -highlightthickness 0 -text "  UCAC3" \
               -variable ::bdi_gui_cata::gui_ucac3 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.ucac3_val -textvariable ::tools_cata::nb_ucac3 -width 4
               button $cataff.ucac3_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ucac3 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_ucac3 $cataff.ucac3_color"
               spinbox $cataff.ucac3_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_ucac3 -command "::bdi_gui_cata::affiche_cata"
               $cataff.ucac3_radius set $::bdi_gui_cata::size_ucac3_sav
            checkbutton $cataff.ucac4_check -highlightthickness 0 -text "  UCAC4" \
               -variable ::bdi_gui_cata::gui_ucac4 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.ucac4_val -textvariable ::tools_cata::nb_ucac4 -width 4
               button $cataff.ucac4_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ucac4 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_ucac4 $cataff.ucac4_color"
               spinbox $cataff.ucac4_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_ucac4 -command "::bdi_gui_cata::affiche_cata"
               $cataff.ucac4_radius set $::bdi_gui_cata::size_ucac4_sav
            checkbutton $cataff.ppmx_check -highlightthickness 0 -text "  PPMX" \
               -variable ::bdi_gui_cata::gui_ppmx -command "::bdi_gui_cata::affiche_cata"
               label $cataff.ppmx_val -textvariable ::tools_cata::nb_ppmx -width 4
               button $cataff.ppmx_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ppmx \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_ppmx $cataff.ppmx_color"
               spinbox $cataff.ppmx_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_ppmx -command "::bdi_gui_cata::affiche_cata"
               $cataff.ppmx_radius set $::bdi_gui_cata::size_ppmx_sav
            checkbutton $cataff.ppmxl_check -highlightthickness 0 -text "  PPMXL" \
               -variable ::bdi_gui_cata::gui_ppmxl -command "::bdi_gui_cata::affiche_cata"
               label $cataff.ppmxl_val -textvariable ::tools_cata::nb_ppmxl -width 4
               button $cataff.ppmxl_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ppmxl \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_ppmxl $cataff.ppmxl_color"
               spinbox $cataff.ppmxl_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_ppmxl -command "::bdi_gui_cata::affiche_cata"
               $cataff.ppmxl_radius set $::bdi_gui_cata::size_ppmxl_sav
            checkbutton $cataff.nomad1_check -highlightthickness 0 -text "  NOMAD1" \
               -variable ::bdi_gui_cata::gui_nomad1 -command "::bdi_gui_cata::affiche_cata"
               label $cataff.nomad1_val -textvariable ::tools_cata::nb_nomad1 -width 4
               button $cataff.nomad1_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_nomad1 \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_nomad1 $cataff.nomad1_color"
               spinbox $cataff.nomad1_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_nomad1 -command "::bdi_gui_cata::affiche_cata"
               $cataff.nomad1_radius set $::bdi_gui_cata::size_nomad1_sav
            checkbutton $cataff.2mass_check -highlightthickness 0 -text "  2MASS" \
               -variable ::bdi_gui_cata::gui_2mass -command "::bdi_gui_cata::affiche_cata"
               label $cataff.2mass_val -textvariable ::tools_cata::nb_2mass -width 4
               button $cataff.2mass_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_2mass \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_2mass $cataff.2mass_color"
               spinbox $cataff.2mass_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_2mass -command "::bdi_gui_cata::affiche_cata"
               $cataff.2mass_radius set $::bdi_gui_cata::size_2mass_sav
            checkbutton $cataff.wfibc_check -highlightthickness 0 -text "  WFIBC" \
               -variable ::bdi_gui_cata::gui_wfibc -command "::bdi_gui_cata::affiche_cata"
               label $cataff.wfibc_val -textvariable ::tools_cata::nb_wfibc -width 4
               button $cataff.wfibc_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_wfibc \
                  -command "::bdi_gui_cata_creation::choose_color ::bdi_gui_cata::color_wfibc $cataff.wfibc_color"
               spinbox $cataff.wfibc_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -width 3 \
                  -textvariable ::bdi_gui_cata::size_wfibc -command "::bdi_gui_cata::affiche_cata"
               $cataff.wfibc_radius set $::bdi_gui_cata::size_wfibc_sav

            frame $cataff.blank -height 15

         grid $cataff.img_check     $cataff.img_val     $cataff.img_color     $cataff.img_radius     $cataff.astroid_check   $cataff.astroid_val   $cataff.astroid_color   $cataff.astroid_radius   -sticky nsw -pady 1
         grid $cataff.skybot_check  $cataff.skybot_val  $cataff.skybot_color  $cataff.skybot_radius  $cataff.sdss_check      $cataff.sdss_val      $cataff.sdss_color      $cataff.sdss_radius      -sticky nsw -pady 1
         grid $cataff.gaia1_check   $cataff.gaia1_val   $cataff.gaia1_color   $cataff.gaia1_radius   $cataff.panstarrs_check $cataff.panstarrs_val $cataff.panstarrs_color $cataff.panstarrs_radius -sticky nsw -pady 1
         grid $cataff.blank
         grid $cataff.usnoa2_check  $cataff.usnoa2_val  $cataff.usnoa2_color  $cataff.usnoa2_radius  $cataff.wfibc_check   $cataff.wfibc_val    $cataff.wfibc_color   $cataff.wfibc_radius   -sticky nsw -pady 1
         grid $cataff.tycho2_check  $cataff.tycho2_val  $cataff.tycho2_color  $cataff.tycho2_radius  $cataff.ucac3_check   $cataff.ucac3_val    $cataff.ucac3_color   $cataff.ucac3_radius   -sticky nsw -pady 1
         grid $cataff.ucac2_check   $cataff.ucac2_val   $cataff.ucac2_color   $cataff.ucac2_radius   $cataff.ucac4_check   $cataff.ucac4_val    $cataff.ucac4_color   $cataff.ucac4_radius   -sticky nsw -pady 1
         grid $cataff.ppmx_check    $cataff.ppmx_val    $cataff.ppmx_color    $cataff.ppmx_radius    $cataff.ppmxl_check   $cataff.ppmxl_val    $cataff.ppmxl_color   $cataff.ppmxl_radius   -sticky nsw -pady 1
         grid $cataff.nomad1_check  $cataff.nomad1_val  $cataff.nomad1_color  $cataff.nomad1_radius  $cataff.2mass_check   $cataff.2mass_val    $cataff.2mass_color   $cataff.2mass_radius   -sticky nsw -pady 1
         grid columnconfigure $cataff 0 -pad 10
         grid columnconfigure $cataff 2 -pad 10
         grid columnconfigure $cataff 3 -pad 10
         grid columnconfigure $cataff 4 -pad 10
         grid columnconfigure $cataff 6 -pad 10
         grid columnconfigure $cataff 7 -pad 10


      #-----------------------------------------------------------------------
      #--- Onglet VARIABLES
      #-----------------------------------------------------------------------

      set param [frame $f2.title -borderwidth 0 -cursor arrow -relief groove]
      pack $param -in $f2 -anchor c -side top -expand 0 -padx 10 -pady 10

         set title [frame $param.title -borderwidth 0 -cursor arrow -relief groove]
         pack $title -in $param -anchor s -side top -expand 0 -padx 10 -pady 10
            label $title.lab -highlightthickness 0 -text "$caption(gui_cata_creation,paramcata)" -font $bddconf(font,arial_10_b)
            pack $title.lab -in $title -side left -anchor c -expand 0 -padx 2 -pady 2

         set log [frame $param.log -borderwidth 0 -cursor arrow -relief groove]
         pack $log -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $log.check -highlightthickness 0 -text "  $caption(gui_cata_creation,activelog)" -variable ::tools_cata::log
            pack $log.check -in $log -side left -expand 0 -fill x -padx 5 -pady 5

         set deuxpasses [frame $param.deuxpasses -borderwidth 0 -cursor arrow -relief groove]
         pack $deuxpasses -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $deuxpasses.check -highlightthickness 0 -text "  $caption(gui_cata_creation,2passes)" -variable ::tools_cata::deuxpasses
            pack $deuxpasses.check -in $deuxpasses -side left -padx 5 -pady 0

         set keepradec [frame $param.keepradec -borderwidth 0 -cursor arrow -relief groove]
         pack $keepradec -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $keepradec.check -highlightthickness 0 -text " $caption(gui_cata_creation,radecprec)" -variable ::tools_cata::keep_radec
            pack $keepradec.check -in $keepradec -side left -padx 5 -pady 0

         set delpv [frame $param.delpv -borderwidth 0 -cursor arrow -relief groove]
         pack $delpv -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $delpv.check -highlightthickness 0 -text "  $caption(gui_cata_creation,supprpv)" -variable ::tools_cata::delpv
            pack $delpv.check -in $delpv -side left -padx 5 -pady 0

         set delimg [frame $param.delimg -borderwidth 0 -cursor arrow -relief groove]
         pack $delimg -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $delimg.check -highlightthickness 0 -text "  $caption(gui_cata_creation,supprimg)" -variable ::tools_cata::delimg
            pack $delimg.check -in $delimg -side left -padx 5 -pady 0

         set create_cata [frame $param.create_cata -borderwidth 0 -cursor arrow -relief groove]
         pack $create_cata -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $create_cata.check -highlightthickness 0 -text "  $caption(gui_cata_creation,insertcata)" -variable ::tools_cata::create_cata
            pack $create_cata.check -in $create_cata -side left -padx 5 -pady 0

         set myuncosm [frame $param.myuncosm -borderwidth 0 -cursor arrow -relief groove]
         pack $myuncosm -in $param -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
            checkbutton $myuncosm.check -highlightthickness 0 -text "  $caption(gui_cata_creation,uncosmic)" -variable ::bdi_gui_cata::use_uncosmic
            pack $myuncosm.check -in $myuncosm -side left -padx 5 -pady 0
            label $myuncosm.lab1 -text "coef.:"
            pack $myuncosm.lab1 -in $myuncosm -side left -padx 5 -pady 0
            entry $myuncosm.val1 -relief sunken -textvariable ::tools_cdl::uncosm_param1 -width 5
            pack $myuncosm.val1 -in $myuncosm -side left -pady 1 -anchor w
            label $myuncosm.lab2 -text "clipmax:"
            pack $myuncosm.lab2 -in $myuncosm -side left -padx 5 -pady 0
            entry $myuncosm.val2 -relief sunken -textvariable ::tools_cdl::uncosm_param2 -width 5
            pack $myuncosm.val2 -in $myuncosm -side left -pady 1 -anchor w

         set limit_nbstars [frame $param.limit_nbstars -borderwidth 0 -cursor arrow -relief groove]
         pack $limit_nbstars -in $param -anchor s -side top -expand 0 -fill x -padx 20 -pady 5

            label $limit_nbstars.lab -text "$caption(gui_cata_creation,limitestars)"
            entry $limit_nbstars.val -relief sunken -textvariable ::tools_cata::limit_nbstars_accepted -width 5

            grid $limit_nbstars.lab $limit_nbstars.val -sticky nsw -pady 1
            grid columnconfigure $limit_nbstars 0 -pad 10

         set threshold_ident [frame $param.threshold_ident -borderwidth 0 -cursor arrow -relief groove]
         pack $threshold_ident -in $param -anchor s -side top -expand 0 -fill x -padx 20 -pady 5

            label $threshold_ident.star_lab0 -text "$caption(gui_cata_creation,seuilidentstar)"  -justify left -borderwidth 1
            label $threshold_ident.star_lab1 -text "$caption(gui_cata_creation,enpos)"
            entry $threshold_ident.star_val1 -relief sunken -textvariable ::tools_cata::threshold_ident_pos_star -width 6
            label $threshold_ident.star_lab2 -text "$caption(gui_cata_creation,enmag)"
            entry $threshold_ident.star_val2 -relief sunken -textvariable ::tools_cata::threshold_ident_mag_star -width 6

            label $threshold_ident.plan_lab0 -text "$caption(gui_cata_creation,seuilidentplan)" -justify left
            label $threshold_ident.plan_lab1 -text "$caption(gui_cata_creation,enpos)"
            entry $threshold_ident.plan_val1 -relief sunken -textvariable ::tools_cata::threshold_ident_pos_ast -width 6
            label $threshold_ident.plan_lab2 -text "$caption(gui_cata_creation,enmag)"
            entry $threshold_ident.plan_val2 -relief sunken -textvariable ::tools_cata::threshold_ident_mag_ast -width 6

            grid $threshold_ident.star_lab0 $threshold_ident.star_lab1 $threshold_ident.star_val1 $threshold_ident.star_lab2 $threshold_ident.star_val2 -sticky nsw -pady 1
            grid $threshold_ident.plan_lab0 $threshold_ident.plan_lab1 $threshold_ident.plan_val1 $threshold_ident.plan_lab2 $threshold_ident.plan_val2 -sticky nsw -pady 1
            grid columnconfigure $threshold_ident 0 -pad 10


      #-----------------------------------------------------------------------
      #--- Onglet IMAGE
      #-----------------------------------------------------------------------

      set infoimage [frame $f3.infoimage -borderwidth 0 -cursor arrow -relief groove]
      pack $infoimage -in $f3 -anchor c -side top -expand 0 -padx 10 -pady 10

         #--- Nom et date de l'image
         set img [frame $infoimage.img -borderwidth 1 -cursor arrow -relief solid -borderwidth 1]
         pack $img -in $infoimage -anchor c -side top -expand 0 -padx 10 -pady 10

            set ::bdi_gui_cata::gui_nomimage [label $img.nom -text $::tools_cata::current_image_name -font $bddconf(font,arial_10_b)]
            pack $img.nom -in $img -side top -padx 3 -pady 3 -ipadx 5 -ipady 2

            set ::bdi_gui_cata::gui_dateimage [label $img.date -text $::tools_cata::current_image_date]
            pack $img.date -in $img -side top -padx 3 -pady 3

         #--- Champs du header de l'image
         set keys [frame $infoimage.keys -borderwidth 0 -cursor arrow -relief groove]
         pack $keys -in $infoimage -anchor s -side top -expand 0 -padx 10 -pady 5

            #--- RA
            set ra [frame $keys.ra -borderwidth 0 -cursor arrow -relief groove]
            pack $ra -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $ra.name -text "RA (deg):"
                pack $ra.name -in $ra -side left -padx 15 -pady 3
                entry $ra.val -relief sunken -textvariable ::tools_cata::ra
                pack $ra.val -in $ra -side right -pady 1 -anchor w

            #--- DEC
            set dec [frame $keys.dec -borderwidth 0 -cursor arrow -relief groove]
            pack $dec -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $dec.name -text "DEC (deg):"
                pack $dec.name -in $dec -side left -padx 15 -pady 3
                entry $dec.val -relief sunken -textvariable ::tools_cata::dec
                pack $dec.val -in $dec -side right -pady 1 -anchor w

            #--- pixsize1
            set pixsize1 [frame $keys.pixsize1 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize1 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize1.name -text "PIXSIZE1 (mum):"
                pack $pixsize1.name -in $pixsize1 -side left -padx 15 -pady 3
                entry $pixsize1.val -relief sunken -textvariable ::tools_cata::pixsize1
                pack $pixsize1.val -in $pixsize1 -side right -pady 1 -anchor w

            #--- pixsize2
            set pixsize2 [frame $keys.pixsize2 -borderwidth 0 -cursor arrow -relief groove]
            pack $pixsize2 -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $pixsize2.name -text "PIXSIZE2 (mum):"
                pack $pixsize2.name -in $pixsize2 -side left -padx 15 -pady 3
                entry $pixsize2.val -relief sunken -textvariable ::tools_cata::pixsize2
                pack $pixsize2.val -in $pixsize2 -side right -pady 1 -anchor w

            #--- foclen
            set foclen [frame $keys.foclen -borderwidth 0 -cursor arrow -relief groove]
            pack $foclen -in $keys -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
                label $foclen.name -text "FOCLEN (m):"
                pack $foclen.name -in $foclen -side left -padx 15 -pady 3
                entry $foclen.val -relief sunken -textvariable ::tools_cata::foclen
                pack $foclen.val -in $foclen -side right -pady 1 -anchor w

         #--- set and reset center
         set setbut [frame $infoimage.setbut -borderwidth 0 -cursor arrow -relief groove]
         pack $setbut -in $infoimage -anchor s -side top -expand 0 -padx 5 -pady 1
            #--- set val
            button $setbut.setval -text "Set Center" -borderwidth 2 -takefocus 1 -command "::bdi_gui_cata_creation::setval"
            pack $setbut.setval -side left -padx 5 -pady 5 -expand 0
            #--- reset center
            button $setbut.resetval -text "Reset Center" -borderwidth 2 -takefocus 1 -command "::bdi_gui_cata_creation::resetcenter"
            pack $setbut.resetval -side left -padx 5 -pady 5 -expand 0


      #-----------------------------------------------------------------------
      #--- Onglet SEXTRACTOR
      #-----------------------------------------------------------------------

      set confsex [frame $f5.confsex -borderwidth 0 -cursor arrow -relief groove]
      pack $confsex -in $f5 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         frame $confsex.buttons -borderwidth 0 -cursor arrow -relief groove
         pack $confsex.buttons -in $confsex  -side top -anchor e -expand 0

            button $confsex.buttons.clean -borderwidth 1 -command "cleanmark" -text "Clean"
            pack $confsex.buttons.clean -side left -anchor e -expand 0
            button $confsex.buttons.test -borderwidth 1 -command "::bdi_gui_cata_creation::test_user_confsex" -text "Test"
            pack $confsex.buttons.test -side left -anchor e -expand 0
            button $confsex.buttons.save -borderwidth 1 -command "::bdi_gui_cata_creation::set_user_confsex" -text "Save"
            pack $confsex.buttons.save -side left -anchor e -expand 0

         text $confsex.file
         pack $confsex.file -in $confsex -side top -padx 3 -pady 3 -anchor w

         frame $confsex.options -borderwidth 0 -cursor arrow -relief groove
         pack $confsex.options -in $confsex  -side top -anchor e -expand 0 -pady 5
            checkbutton $confsex.options.viewrejected -highlightthickness 0 -text "Affiche les sources rejetees" \
               -variable ::bdi_gui_cata_creation::gui_sex_viewrejected -command ""
            pack $confsex.options.viewrejected -in $confsex.options -side top -anchor w -expand 0


      #-----------------------------------------------------------------------
      #--- Onglet PSF
      #-----------------------------------------------------------------------

      set psf [frame $f6.psf -borderwidth 0 -cursor arrow -relief groove]
      pack $psf -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- Title
            label $psf.lab -text "$caption(gui_cata_creation,psftitle)" -font $bddconf(font,arial_10_b)
            pack $psf.lab -in $psf -side top -anchor c -expand 0 -padx 5 -pady 10

            #--- Creation du cata psf
            set creer [frame $psf.creer -borderwidth 0 -cursor arrow -relief groove]
            pack $creer -in $psf -side top -anchor w -expand 0 -fill x -pady 5
               checkbutton $creer.check -highlightthickness 0 -text "  $caption(gui_cata_creation,psfcreer)" \
                     -variable ::bdi_tools_psf::use_psf -command ""
               pack $creer.check -in $creer -side left -padx 3 -pady 3 -anchor w

            #--- Option de creation du cata Astroid
            set methconf [frame $psf.methconf -borderwidth 0 -cursor arrow -relief sunken]
            pack $methconf -in $psf  -side top -anchor e -expand 0 -fill x  -padx 3 -pady 3

            ::audace::psf_init $::audace(visuNo)
            ::audace::psf_gui_methodes $::audace(visuNo) $methconf
#               ::bdi_gui_psf::gui_configuration $methconf

            #::bdi_gui_cata_creation::handlePSFParams $psf


      #-----------------------------------------------------------------------
      #--- Onglet INTEROP
      #-----------------------------------------------------------------------

      #--- Cree un frame pour afficher les actions Interop
      set interop [frame $f7.interop -borderwidth 0 -cursor arrow -relief groove]
      pack $interop -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Calcul des coordonnees du centre du fov
         set resolver [frame $interop.resolver -borderwidth 0 -cursor arrow -relief solid]
         pack $resolver -in $interop -anchor s -side top -expand 0 -fill x -padx 1 -pady 10

            label $resolver.title -text "$caption(gui_cata_creation,resolver)" -font $bddconf(font,arial_10_b)
            pack $resolver.title -in $resolver -anchor c -side top -padx 5 -pady 10

            set gril [frame $resolver.grid -borderwidth 0 -cursor arrow -relief solid]
            pack $gril -in $resolver -anchor c -side top -pady 10

               label $gril.ldate    -text "$caption(gui_cata_creation,lepoch)"
               label $gril.ltarget  -text "$caption(gui_cata_creation,ltarget)"
               label $gril.lcoord   -text "$caption(gui_cata_creation,lcoord)"
               label $gril.lradius  -text "$caption(gui_cata_creation,lradius)"
               label $gril.luaicode -text "$caption(gui_cata_creation,luaicode)"

               entry $gril.edate -relief sunken -width 22 -textvariable ::tools_cata::current_image_date
               entry $gril.etarget -relief sunken -width 22 -textvariable ::tools_cata::target
               entry $gril.ecoord -relief sunken -width 22 -textvariable ::tools_cata::coord
               entry $gril.eradius -relief sunken -width 22 -textvariable ::tools_cata::radius
               entry $gril.euaicode -relief sunken -width 22 -textvariable ::tools_cata::uaicode

               button $gril.resolve -text "$caption(gui_cata_creation,butresolve)" -width 10 -borderwidth 1 -relief groove \
                  -command "::tools_cata::skybotResolver"
               button $gril.setcenter -text "$caption(gui_cata_creation,butcenter)" -width 10 -borderwidth 1 -relief groove \
                  -command "::tools_cata::setCenterFromRADEC"
               button $gril.blank1 -borderwidth 0 -width 12 -relief solid -borderwidth 0 -state disabled
               button $gril.blank2 -borderwidth 0 -width 12 -relief solid -borderwidth 0 -state disabled

            grid $gril.ldate    $gril.edate    $gril.blank1    -sticky nsw -pady 1
            grid $gril.ltarget  $gril.etarget  $gril.resolve   -sticky nsw -pady 1
            grid $gril.lcoord   $gril.ecoord   $gril.setcenter -sticky nsw -pady 1
            grid $gril.lradius  $gril.eradius  $gril.blank2    -sticky nsw -pady 1
            grid $gril.luaicode $gril.euaicode $gril.blank2    -sticky nsw -pady 1
            grid configure $gril.ldate $gril.ltarget $gril.lcoord $gril.lradius $gril.luaicode -sticky nse
            grid columnconfigure $gril 0 -pad 10
            grid columnconfigure $gril 2 -pad 5

         # Bouton pour envoyer les plans courants (image,table) vers Aladin
         set votools [frame $interop.votools -borderwidth 0 -cursor arrow -relief solid -borderwidth 1]
         pack $votools -in $interop -anchor s -side top -expand 0 -padx 10 -pady 5 -ipadx 20 -ipady 10

            label $votools.title -text "$caption(gui_cata_creation,votitle)" -font $bddconf(font,arial_10_b)
            pack $votools.title -in $votools -anchor c -side top -padx 5 -pady 10

            set ::bdi_gui_cata_creation::votoolsmenu [frame $votools.menu -borderwidth 0 -relief groove]
            pack $::bdi_gui_cata_creation::votoolsmenu -in $votools -anchor c -side top -padx 5 -pady 2
               button $::bdi_gui_cata_creation::votoolsmenu.connect -borderwidth 1 -text "$caption(gui_cata_creation,voconnect)" \
                  -command "::bdi_gui_cata_creation::startInterop"
               pack $::bdi_gui_cata_creation::votoolsmenu.connect -in $::bdi_gui_cata_creation::votoolsmenu -side top

            set ::bdi_gui_cata_creation::votoolsaction [frame $votools.action -borderwidth 0 -relief groove]
            pack $::bdi_gui_cata_creation::votoolsaction -in $votools -anchor c -side top -padx 5 -pady 10
               button $::bdi_gui_cata_creation::votoolsaction.broadcast -text "$caption(gui_cata_creation,voimgtab)" -borderwidth 1 -relief groove \
                  -command "::tools_cata::broadcastImageAndTable"
               pack $::bdi_gui_cata_creation::votoolsaction.broadcast -in $::bdi_gui_cata_creation::votoolsaction -side top -fill x
               button $::bdi_gui_cata_creation::votoolsaction.script -text "$caption(gui_cata_creation,voscript)" -borderwidth 1 -relief groove \
                  -command "::tools_cata::broadcastAladinScript"
               pack $::bdi_gui_cata_creation::votoolsaction.script -in $::bdi_gui_cata_creation::votoolsaction -side top -fill x


      #-----------------------------------------------------------------------
      #--- Onglet MANUEL
      #-----------------------------------------------------------------------

      #--- Cree un frame pour afficher la GUI du Mode Manuel
      set manuel [frame $f8.manuel -borderwidth 0 -cursor arrow -relief groove]
      pack $manuel -in $f8 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label $manuel.title -text "$caption(gui_cata_creation,manueltitle)" -font $bddconf(font,arial_10_b)
            pack $manuel.title -in $manuel -anchor c -side top -padx 5 -pady 5

            frame $manuel.entr -borderwidth 0 -cursor arrow -relief groove
            pack $manuel.entr -in $manuel -side top

               set fov [frame $manuel.fov -borderwidth 0 -cursor arrow  -borderwidth 0]
               pack $fov -in $manuel.entr -side top

                  frame $fov.alpha -borderwidth 0 -cursor arrow -relief groove
                  pack $fov.alpha -in $fov -side left
                     label $fov.alpha.lab -text "RA (deg)"
                     pack $fov.alpha.lab -in $fov.alpha -side top -padx 1 -pady 1 -anchor c
                     entry $fov.alpha.val -relief sunken -textvariable ::tools_cata::ra -width 12
                     pack $fov.alpha.val -in $fov.alpha -side top -padx 1 -pady 1 -anchor w

                  frame $fov.delta -borderwidth 0 -cursor arrow -relief groove
                  pack $fov.delta -in $fov -side left
                     label $fov.delta.lab -text "DEC (deg)"
                     pack $fov.delta.lab -in $fov.delta -side top -padx 1 -pady 1 -anchor c
                     entry $fov.delta.val -relief sunken -textvariable ::tools_cata::dec -width 12
                     pack $fov.delta.val -in $fov.delta -side top -padx 1 -pady 1 -anchor w

                  frame $fov.fov -borderwidth 0 -cursor arrow -relief groove
                  pack $fov.fov -in $fov -side left
                     label $fov.fov.lab -text "Fov (arcmin)"
                     pack $fov.fov.lab -in $fov.fov -side top -padx 1 -pady 1 -anchor c
                     entry $fov.fov.val -relief sunken -textvariable ::tools_cata::radius -width 12
                     pack $fov.fov.val -in $fov.fov -side top -padx 1 -pady 1 -anchor w

                  frame $fov.crota -borderwidth 0 -cursor arrow -relief groove
                  pack $fov.crota -in $fov -side left
                     label $fov.crota.lab -text "Orient. (deg)"
                     pack $fov.crota.lab -in $fov.crota -side top -padx 1 -pady 1 -anchor c
                     entry $fov.crota.val -relief sunken -textvariable ::tools_cata::crota2 -width 12
                     pack $fov.crota.val -in $fov.crota -side top -padx 1 -pady 1 -anchor w

                  frame $fov.dss -borderwidth 0 -cursor arrow -relief groove
                  pack $fov.dss -in $fov -side left -padx 5 -fill y
                     button $fov.dss.lab -borderwidth 2 -text "Get DSS" -command "::bdi_gui_cata::getDSS"
                     pack $fov.dss.lab -in $fov.dss -anchor s -side bottom

               set coord [frame $manuel.entr.coord -borderwidth 0 -cursor arrow]
               pack $coord -in $manuel.entr

                  image create photo icon_clean
                  icon_clean configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]

                  set img [frame $coord.l -borderwidth 0 -cursor arrow  -borderwidth 0]
                  pack $img -in $coord -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                     frame $img.title -borderwidth 0 -cursor arrow -relief groove
                     pack $img.title  -in $img  -side top  -anchor c
                        label $img.title.xy  -text "X Y (pixel)" -borderwidth 0 -relief groove  -width 25
                        pack  $img.title.xy -in $img.title -side left -padx 3 -pady 3 -anchor w
                        label $img.title.ad  -text "RA DEC (deg)" -borderwidth 0  -relief groove  -width 25
                        pack  $img.title.ad -in $img.title -side right -padx 3 -pady 3 -anchor e

                     for {set i 1} {$i<8} {incr i} {
                        frame $img.v$i -borderwidth 1 -cursor arrow -relief groove
                        pack $img.v$i -in $img  -side top
                           entry $img.v$i.xy -relief sunken -textvariable ::bdi_gui_cata::man_xy_star($i)
                           pack  $img.v$i.xy -in $img.v$i -side left -padx 1 -pady 1 -anchor w
                           button  $img.v$i.grab -borderwidth 1 -command "::bdi_gui_cata_creation::grab $i" -text "Grab"
                           pack    $img.v$i.grab -in $img.v$i -side left -anchor e -expand 0
                           entry $img.v$i.ad -relief sunken  -textvariable ::bdi_gui_cata::man_ad_star($i)
                           pack  $img.v$i.ad -in $img.v$i -side left -padx 1 -pady 1 -anchor w
                           button $img.v$i.clean -borderwidth 1 -image icon_clean -command {
                              set ::bdi_gui_cata::man_xy_star($i) ""
                              set ::bdi_gui_cata::man_ad_star($i) ""
                           }
                           pack $img.v$i.clean -in $img.v$i -side left -anchor e -expand 0
                     }

                  set visu [frame $coord.r -borderwidth 0 -cursor arrow  -borderwidth 0]
                  pack $visu -in $coord -anchor c -side right -expand 0 -fill x -padx 10 -pady 5

                     button $visu.efface -borderwidth 1 -command "::bdi_gui_cata_creation::manual_clean" -text "Effacer"
                     pack $visu.efface -in $visu -side top -anchor c -fill x
                     button $visu.blank -borderwidth 0 -state disabled
                     pack $visu.blank -in $visu -side top -anchor c -fill x
                     button $visu.voir -borderwidth 1 -text "Voir XY" -command "::bdi_gui_cata_creation::manual_view"
                     pack $visu.voir -in $visu -side top -anchor c -fill x
                     button $visu.fit -borderwidth 1 -text "Fit XY" -command "::bdi_gui_cata_creation::manual_fit"
                     pack $visu.fit -in $visu -side top -anchor c -fill x
                     button $visu.clean  -borderwidth 1 -text "Clean XY" -command "cleanmark"
                     pack $visu.clean -in $visu -side top -anchor c -fill x

               frame $manuel.entr.buttons0 -borderwidth 0 -cursor arrow -relief groove
               pack $manuel.entr.buttons0 -in $manuel.entr -side top -pady 10

                  button $manuel.entr.buttons0.creerwcs -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::copy_wcs" -text "Copy WCS"
                  pack $manuel.entr.buttons0.creerwcs -in $manuel.entr.buttons0 -side left -anchor e -expand 0
                  set ::bdi_gui_cata::gui_paste_wcs [button $manuel.entr.buttons0.priam -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::paste_wcs" -text "Paste WCS" -state disabled]
                  pack $manuel.entr.buttons0.priam -in $manuel.entr.buttons0 -side left -anchor e -expand 0
                  set ::bdi_gui_cata::gui_voir_wcs [button $manuel.entr.buttons0.voir_wcs -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::voir_wcs" -text "Voir WCS" -state normal]
                  pack $manuel.entr.buttons0.voir_wcs -in $manuel.entr.buttons0 -side left -anchor e -expand 0

               frame $manuel.entr.buttons1 -borderwidth 0 -cursor arrow -relief groove
               pack $manuel.entr.buttons1 -in $manuel.entr -side top -pady 10

                  button $manuel.entr.buttons1.creerwcs -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::manual_create_wcs" -text "Basic WCS"
                  pack $manuel.entr.buttons1.creerwcs -in $manuel.entr.buttons1 -side left -anchor e -expand 0
                  button $manuel.entr.buttons1.voirusno -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::voir_usno" -text "Voir USNOA2"
                  pack $manuel.entr.buttons1.voirusno -in $manuel.entr.buttons1 -side left -anchor e -expand 0
                  button $manuel.entr.buttons1.priam -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::manual_priam" -text "Priam WCS"
                  pack $manuel.entr.buttons1.priam -in $manuel.entr.buttons1 -side left -anchor e -expand 0


               frame $manuel.entr.buttons2 -borderwidth 0 -cursor arrow -relief groove
               pack $manuel.entr.buttons2 -in $manuel.entr -side top -pady 10

                  set ::bdi_gui_cata::gui_creercata [button $manuel.entr.buttons2.creercata -borderwidth 1  \
                     -command "::bdi_gui_cata_creation::manual_create_cata" -text "Creer Cata" -state disabled]
                  pack $manuel.entr.buttons2.creercata -in $manuel.entr.buttons2 -side left -anchor e -expand 0
                  set ::bdi_gui_cata::gui_enrimg [button $manuel.entr.buttons2.enrimg -borderwidth 1 \
                     -command "::bdi_gui_cata_creation::manual_insert_img" -text "Insertion Image" -state disabled]
                  pack $manuel.entr.buttons2.enrimg -in $manuel.entr.buttons2 -side left -anchor e -expand 0


      #-----------------------------------------------------------------------
      #--- Onglet DEVELOP
      #-----------------------------------------------------------------------

      set develop [frame $f9.develop -borderwidth 0 -cursor arrow -relief groove]
      pack $develop -in $f9 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         frame $develop.entr -borderwidth 0 -cursor arrow -relief groove
         pack $develop.entr  -in $develop  -side top

            set inf [frame $develop.entr.affsourcegrab -borderwidth 0 -cursor arrow  -borderwidth 0]
            pack $inf -side top
               button $inf.lab -borderwidth 1 -command "::bdi_gui_cata_creation::develop box" -text "Voir dans la console : les sources d'une fenetre"
               pack   $inf.lab -side top -padx 3 -pady 3 -anchor c

            set inf [frame $develop.entr.affsourceall -borderwidth 0 -cursor arrow  -borderwidth 0]
            pack $inf -side top
               button $inf.lab -borderwidth 1 -command "::bdi_gui_cata_creation::develop all" -text "Voir dans la console : toutes les sources"
               pack   $inf.lab -side top -padx 3 -pady 3 -anchor c

            set inf [frame $develop.entr.affsource3 -borderwidth 0 -cursor arrow  -borderwidth 0]
            pack $inf -side top
               button $inf.lab -borderwidth 1 -command "::bdi_gui_cata_creation::develop 3sources" -text "Voir dans la console : 3 sources"
               pack   $inf.lab -side top -padx 3 -pady 3 -anchor c


      #-----------------------------------------------------------------------
      #--- BOUTONS PIED
      #-----------------------------------------------------------------------
      set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
      pack $boutonpied -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         set ::bdi_gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
            -command "::bdi_gui_cata_creation::fermer"]
         pack $boutonpied.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #set ::bdi_gui_cata::gui_info [label $boutonpied.info -text ""]
         #pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
         #set ::bdi_gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
         #pack $::bdi_gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


   # Post-actions
   ::bdi_gui_cata::affiche_cata
   ::bdi_gui_cata_creation::get_default_confsex
   ::bdi_gui_cata_creation::handleVOButtons
   ::vo_tools::addInteropListener "::bdi_gui_cata_creation::handleVOButtons"

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_cata_creation::fen

   # Surcharge des couleurs et fontes
   $confsex.file configure -background white
   $confsex.file configure -font  $bddconf(font,courier_10)

   $::bdi_gui_cata::gui_wcs  configure -bg $::bdi_gui_cata::color_wcs
   $::bdi_gui_cata::gui_wcs  configure -bg $::bdi_gui_cata::color_cata

   $cataff.img_color       configure -bg $::bdi_gui_cata::color_img
   $cataff.skybot_color    configure -bg $::bdi_gui_cata::color_skybot
   $cataff.gaia1_color     configure -bg $::bdi_gui_cata::color_gaia1
   $cataff.sdss_color      configure -bg $::bdi_gui_cata::color_sdss
   $cataff.panstarrs_color configure -bg $::bdi_gui_cata::color_panstarrs
   $cataff.astroid_color   configure -bg $::bdi_gui_cata::color_astroid
   $cataff.usnoa2_color    configure -bg $::bdi_gui_cata::color_usnoa2
   $cataff.tycho2_color    configure -bg $::bdi_gui_cata::color_tycho2
   $cataff.ucac2_color     configure -bg $::bdi_gui_cata::color_ucac2
   $cataff.ppmx_color      configure -bg $::bdi_gui_cata::color_ppmx
   $cataff.nomad1_color    configure -bg $::bdi_gui_cata::color_nomad1
   $cataff.wfibc_color     configure -bg $::bdi_gui_cata::color_wfibc
   $cataff.ucac3_color     configure -bg $::bdi_gui_cata::color_ucac3
   $cataff.ucac4_color     configure -bg $::bdi_gui_cata::color_ucac4
   $cataff.ppmxl_color     configure -bg $::bdi_gui_cata::color_ppmxl
   $cataff.2mass_color     configure -bg $::bdi_gui_cata::color_2mass

}
