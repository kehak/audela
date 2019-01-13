## @file bdi_tools_cdl.tcl
#  @brief     Outils pour la cr&eacute;ation des courbes de lumi&egrave;re
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_cdl.tcl]
#  @endcode

# $Id: bdi_tools_cdl.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_cdl
# @brief Outils pour la cr&eacute;ation des courbes de lumi&egrave;re
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_cdl {

   variable progress          ;#< Barre de progression
   variable table_mesure      ;#
   variable id_to_name        ;#
   variable name_to_id        ;#
   variable table_data_source ;#
   variable table_variations  ;#
   variable table_noms        ;#
   variable table_othf        ;#
   variable table_nbcata      ;#
   variable table_star_exist  ;#
   variable table_values      ;#

}

#----------------------------------------------------------------------------
## Initialisation des variables de namespace
#  \details   Si la variable n'existe pas alors on va chercher
#             dans la variable globale \c conf
proc ::bdi_tools_cdl::inittoconf {  } {

   global conf

   set ::bdi_tools_cdl::nbref      0
   set ::bdi_tools_cdl::nbscience  0
   set ::bdi_tools_cdl::nbrej      0

   if {! [info exists ::bdi_tools_cdl::rapport_rapporteur] } {
      if {[info exists conf(bddimages,photometry,rapport,rapporteur)]} {
         set ::bdi_tools_cdl::rapport_rapporteur $conf(bddimages,photometry,rapport,rapporteur)
      } else {
         set ::bdi_tools_cdl::rapport_rapporteur ""
      }
   }
   if {! [info exists ::bdi_tools_cdl::rapport_adresse] } {
      if {[info exists conf(bddimages,photometry,rapport,adresse)]} {
         set ::bdi_tools_cdl::rapport_adresse $conf(bddimages,photometry,rapport,adresse)
      } else {
         set ::bdi_tools_cdl::rapport_adresse ""
      }
   }
   if {! [info exists ::bdi_tools_cdl::rapport_mail] } {
      if {[info exists conf(bddimages,photometry,rapport,mail)]} {
         set ::bdi_tools_cdl::rapport_mail $conf(bddimages,photometry,rapport,mail)
      } else {
         set ::bdi_tools_cdl::rapport_mail ""
      }
   }
   if {! [info exists ::bdi_tools_cdl::rapport_reduc] } {
      if {[info exists conf(bddimages,photometry,rapport,reduc)]} {
         set ::bdi_tools_cdl::rapport_reduc $conf(bddimages,photometry,rapport,reduc)
      } else {
         set ::bdi_tools_cdl::rapport_reduc ""
      }
   }
   if {! [info exists ::bdi_tools_cdl::rapport_instru] } {
      if {[info exists conf(bddimages,photometry,rapport,instru)]} {
         set ::bdi_tools_cdl::rapport_instru $conf(bddimages,photometry,rapport,instru)
      } else {
         set ::bdi_tools_cdl::rapport_instru ""
      }
   }

}


#----------------------------------------------------------------------------
## Sauvegarde des variables de namespace
# \return void
#
proc ::bdi_tools_cdl::closetoconf {  } {

   global conf

   set conf(bddimages,photometry,rapport,rapporteur) $::bdi_tools_cdl::rapport_rapporteur
   set conf(bddimages,photometry,rapport,adresse)    $::bdi_tools_cdl::rapport_adresse
   set conf(bddimages,photometry,rapport,mail)       $::bdi_tools_cdl::rapport_mail
   set conf(bddimages,photometry,rapport,reduc)      $::bdi_tools_cdl::rapport_reduc
   set conf(bddimages,photometry,rapport,instru)     $::bdi_tools_cdl::rapport_instru

}



proc ::bdi_tools_cdl::charge_from_gestion { } {

   set tt0 [clock clicks -milliseconds]
   ::bdi_tools_cdl::init_spectral_type

   array unset ::bdi_tools_cdl::table_noms
   array unset ::bdi_tools_cdl::table_nbcata
   array unset ::bdi_tools_cdl::table_othf
   array unset ::bdi_tools_cdl::table_star_exist
   array unset ::bdi_tools_cdl::idcata_to_jdc
   array unset ::bdi_tools_cdl::table_jdmidexpo
   array unset ::bdi_tools_cdl::table_star_ids

   set idcata 0
   foreach ::tools_cata::current_image $::tools_cata::img_list {
      incr idcata

      ::bdi_tools_cdl::set_progress $idcata $::tools_cata::nb_img_list
      ::bdi_tools_cdl::get_memory

      set tabkey   [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set exposure [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"] 1] ]
      set xscale  [string trim [lindex [::bddimages_liste::lget $tabkey "CDELT1"] 1] ]
      set yscale  [string trim [lindex [::bddimages_liste::lget $tabkey "CDELT2"] 1] ]
      set ::bdi_tools_cdl::rapport_uai_code [string trim [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1] ]
      set ::bdi_tools_cdl::rapport_observ   [string trim [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1] ]
      set ex [::bddimages_liste::lexist $tabkey "INSTRUME"]
      if {$ex != 0} {
         set ::bdi_tools_cdl::rapport_instru [string trim [lindex [::bddimages_liste::lget $tabkey "INSTRUME"] 1] ]
      }

      if {$exposure == -1} {
         gren_erreur "WARNING: Exposure inconnu pour l'image : $date\n"
         set midexpo 0
      } else {
         set midexpo [expr ($exposure/2.0) / 86400.0]
      }

      if {$idcata==1} {
         set jdc_orig [expr [mc_date2jd $dateobs] + $midexpo]
         set ::bdi_tools_cdl::idcata_to_jdc(1) 0.0
      } else {
         set ::bdi_tools_cdl::idcata_to_jdc($idcata) [expr [mc_date2jd $dateobs] + $midexpo - $jdc_orig]
      }


      set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($idcata)

      set sources [lindex  $::tools_cata::current_listsources 1]
      set tab_fwhm ""
      set ids -1
      foreach s $sources {
         incr ids

         set name [::manage_source::namincata $s]
         if {$name == ""} {continue}

         if {[info exists ::bdi_tools_cdl::table_noms($name)]} {
            incr ::bdi_tools_cdl::table_nbcata($name)
         } else {
            set ::bdi_tools_cdl::table_noms($name)   0
            set ::bdi_tools_cdl::table_nbcata($name) 1
         }
         set ::bdi_tools_cdl::table_jdmidexpo($idcata) [expr [mc_date2jd $dateobs] + $midexpo]
         set ::bdi_tools_cdl::table_date($idcata) $dateobs
         set ::bdi_tools_cdl::table_othf($name,$idcata,othf) [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set ::bdi_tools_cdl::table_star_exist($name,$idcata) 1
         set ::bdi_tools_cdl::table_star_ids($name,$idcata) $ids

         set err [ catch {
            set fwhmx [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) fwhmx]
            set fwhmy [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) fwhmy]
            if {$fwhmx != ""} { set fwhmx [expr $fwhmx * $xscale] }
            if {$fwhmy != ""} { set fwhmy [expr $fwhmy * $yscale] }
            if {$fwhmx != "" && $fwhmy != ""} {
               set fwhm [expr sqrt((pow($fwhmx,2)+pow($fwhmy,2))/2)*3600]
            } else {
               set fwhm ""
            }
         } msg ]
         if {$err} {
            gren_erreur "Impossible de determiner la fwhm sur $name a la date de $dateobs\n$msg\n"
         } else {
            if {$fwhm != ""} {
               # PATCH (20151108) pour eviter d'exploser la valeur de FWHM:
               if {$fwhm > 100.0} {
                  gren_erreur "! FWHM incorrecte (>100\"): fwhm(x) = [expr $fwhmx*3600.0] :: fwhm(y) = [expr $fwhmy*3600] @ $dateobs -> non prise en compte pour les stats\n"
               } else {
                  lappend tab_fwhm $fwhm
               }
            }
         }
         # Sciences References Rejetees
         #if {$idcata == 10} {
         #   set ::bdi_tools_cdl::test_sources $sources
         #
         #   set nameuc [::manage_source::naming $s UCAC4]
         #   if {$nameuc == "UCAC4_442-052846"} {
         #      gren_info "$idcata $ids $nameuc $name othf=$::bdi_tools_cdl::table_othf($name,$idcata,othf)\n"
         #      gren_info "$s\n"
         #   }
         #}

         set flagphotom [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) flagphotom]
         set cataphotom [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) cataphotom]
         switch $flagphotom {
            "R" {
                 set ::bdi_tools_cdl::table_noms($name) 1
                 #gren_info "($idcata) $name as reference $flagphotom $cataphotom\n"
            }
            "S" {

                 if {$::bdi_tools_cdl::table_noms($name) != 1 } {
                    set ::bdi_tools_cdl::table_noms($name) 2
                 }
            }
            default {
            }
         }

         set USNOA2_magB     ""
         set USNOA2_magR     ""
         set UCAC4_im1_mag   ""
         set UCAC4_im2_mag   ""
         set NOMAD1_magB     ""
         set NOMAD1_magV     ""
         set NOMAD1_magR     ""
         set NOMAD1_magJ     ""
         set NOMAD1_magH     ""
         set NOMAD1_magK     ""

         foreach cata $s {
            switch [lindex $cata 0] {
               "USNOA2" {
                  set USNOA2_magB   [lindex $cata 2 6]
                  set USNOA2_magR   [lindex $cata 2 7]
               }
               "UCAC4" {
                  set UCAC4_im1_mag [lindex $cata 2 4]
                  set UCAC4_im2_mag [lindex $cata 2 5]
               }
               "NOMAD1" {
                  set NOMAD1_magB   [lindex $cata 2 13]
                  set NOMAD1_magV   [lindex $cata 2 15]
                  set NOMAD1_magR   [lindex $cata 2 17]
                  set NOMAD1_magJ   [lindex $cata 2 18]
                  set NOMAD1_magH   [lindex $cata 2 19]
                  set NOMAD1_magK   [lindex $cata 2 20]
               }
            }
         }
         set r [::bdi_tools_cdl::get_spectral_type \
                                 [list \
                                        $USNOA2_magB  $USNOA2_magR  $UCAC4_im1_mag $UCAC4_im2_mag \
                                        $NOMAD1_magB  $NOMAD1_magV  $NOMAD1_magR   $NOMAD1_magJ \
                                        $NOMAD1_magH  $NOMAD1_magK  ] \
               ]

         set ::bdi_tools_cdl::table_mag($name,USNOA2_magB)   $USNOA2_magB
         set ::bdi_tools_cdl::table_mag($name,USNOA2_magR)   $USNOA2_magR
         set ::bdi_tools_cdl::table_mag($name,UCAC4_im1_mag) $UCAC4_im1_mag
         set ::bdi_tools_cdl::table_mag($name,UCAC4_im2_mag) $UCAC4_im2_mag
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magB)   $NOMAD1_magB
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magV)   $NOMAD1_magV
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magR)   $NOMAD1_magR
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magJ)   $NOMAD1_magJ
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magH)   $NOMAD1_magH
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magK)   $NOMAD1_magK

         set ::bdi_tools_cdl::table_values($name,sptype,cpt) [lindex $r 1]
         set ::bdi_tools_cdl::table_values($name,sptype,sep) [lindex $r 2]
         #break
      }

   # Fin boucle sur les images
   }

   set ::bdi_tools_cdl::fwhm [format "%.2f" [::math::statistics::mean $tab_fwhm]]
   set ::bdi_tools_cdl::fwhm_std [format "%.2f" [::math::statistics::stdev $tab_fwhm]]
   gren_info "For all images and all sources : FWHM = $::bdi_tools_cdl::fwhm ; STD = $::bdi_tools_cdl::fwhm_std\n"

   ::bdi_tools_cdl::calc_nb_sources

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Chargement depuis la fenetre gestion en $tt sec \n"
}


#----------------------------------------------------------------------------
## Calcule le nombre de sources dans les differents ensemble de donnees
# References, Sciences et Rejetees
#
proc ::bdi_tools_cdl::calc_nb_sources { } {

   set ::bdi_tools_cdl::nbref      0
   set ::bdi_tools_cdl::nbscience  0
   set ::bdi_tools_cdl::nbrej      0

   foreach { name o } [array get ::bdi_tools_cdl::table_noms] {
      switch $o {
         "1" {
              incr ::bdi_tools_cdl::nbref
         }
         "2" {
              incr ::bdi_tools_cdl::nbscience
         }
         default {
              incr ::bdi_tools_cdl::nbrej
         }
      }
   }
}



#----------------------------------------------------------------------------
## Stoppe le chargement des cata XML a la volee.
#
proc ::bdi_tools_cdl::stop_charge_cata_alavolee { } {

   set ::bdi_tools_cdl::encours_charge_cata_xml 0

}



#----------------------------------------------------------------------------
## Chargement des cata de la liste d'image selectionnee dans l'outil Recherche.
#  \note le resultat de cette procedure affecte la variable de
# namespace  \c tools_cata::img_list puis charge toutes l'info des cata
# associes aux images
#
proc ::bdi_tools_cdl::charge_cata_alavolee { } {

   set tt0 [clock clicks -milliseconds]

   ::bdi_tools_cdl::init_spectral_type

   array unset ::bdi_tools_cdl::table_noms
   array unset ::bdi_tools_cdl::table_nbcata
   array unset ::bdi_tools_cdl::table_othf
   array unset ::bdi_tools_cdl::table_star_exist
   array unset ::bdi_tools_cdl::idcata_to_jdc
   array unset ::bdi_tools_cdl::table_jdmidexpo
   array unset ::bdi_tools_cdl::table_star_ids

   # array unset ::bdi_gui_cata::cata_list

   gren_info "Chargement des donnees a la volee, veuillez patienter ..."

   set ::bdi_tools_cdl::encours_charge_cata_xml 1
   set idcata 0
   foreach ::tools_cata::current_image $::tools_cata::img_list {
      if {$::bdi_tools_cdl::encours_charge_cata_xml!=1} { break }
      incr idcata
      ::bdi_gui_cata::load_cata
      ::bdi_tools_cdl::set_progress $idcata $::tools_cata::nb_img_list
      ::bdi_tools_cdl::get_memory

      set tabkey   [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set exposure [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"] 1] ]
      set ::bdi_tools_cdl::rapport_uai_code [string trim [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1] ]
      set ::bdi_tools_cdl::rapport_observ   [string trim [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1] ]
      set ex [::bddimages_liste::lexist $tabkey "INSTRUME"]
      if {$ex != 0} {
         set ::bdi_tools_cdl::rapport_instru [string trim [lindex [::bddimages_liste::lget $tabkey "INSTRUME"] 1] ]
      }

      if {$exposure == -1} {
         gren_erreur "WARNING: Exposure inconnu pour l'image : $date\n"
         set midexpo 0
      } else {
         set midexpo [expr ($exposure/2.0) / 86400.0]
      }

      if {$idcata==1} {
         set jdc_orig [expr [mc_date2jd $dateobs] + $midexpo]
         set ::bdi_tools_cdl::idcata_to_jdc(1) 0.0
      } else {
         set ::bdi_tools_cdl::idcata_to_jdc($idcata) [expr [mc_date2jd $dateobs] + $midexpo - $jdc_orig]
      }

      # set ::bdi_gui_cata::cata_list($idcata) $::tools_cata::current_listsources

      set sources [lindex  $::tools_cata::current_listsources 1]

      set ids -1
      foreach s $sources {
         incr ids

         set name [::manage_source::namincata $s]
         if {$name == ""} {continue}

         if {[info exists ::bdi_tools_cdl::table_noms($name)]} {
            incr ::bdi_tools_cdl::table_nbcata($name)
         } else {
            set ::bdi_tools_cdl::table_noms($name)   0
            set ::bdi_tools_cdl::table_nbcata($name) 1
         }
         set ::bdi_tools_cdl::table_jdmidexpo($idcata) [expr [mc_date2jd $dateobs] + $midexpo]
         set ::bdi_tools_cdl::table_date($idcata) $dateobs
         set ::bdi_tools_cdl::table_othf($name,$idcata,othf) [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set ::bdi_tools_cdl::table_star_exist($name,$idcata) 1
         set ::bdi_tools_cdl::table_star_ids($name,$idcata) $ids

         set flagphotom [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) flagphotom]
         set cataphotom [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) cataphotom]
         switch $flagphotom {
            "R" {
                 set ::bdi_tools_cdl::table_noms($name) 1
                 #gren_info "($idcata) $name as reference $flagphotom $cataphotom\n"
            }
            "S" {
                 if {$::bdi_tools_cdl::table_noms($name) != 1 } {
                    set ::bdi_tools_cdl::table_noms($name) 2
                 }
            }
            default {
            }
         }

         # Couleurs
         set USNOA2_magB     ""
         set USNOA2_magR     ""
         set UCAC4_im1_mag   ""
         set UCAC4_im2_mag   ""
         set NOMAD1_magB     ""
         set NOMAD1_magV     ""
         set NOMAD1_magR     ""
         set NOMAD1_magJ     ""
         set NOMAD1_magH     ""
         set NOMAD1_magK     ""

         foreach cata $s {
            switch [lindex $cata 0] {
               "USNOA2" {
                  set USNOA2_magB   [lindex $cata 2 6]
                  set USNOA2_magR   [lindex $cata 2 7]
               }
               "UCAC4" {
                  set UCAC4_im1_mag [lindex $cata 2 4]
                  set UCAC4_im2_mag [lindex $cata 2 5]
               }
               "NOMAD1" {
                  set NOMAD1_magB   [lindex $cata 2 13]
                  set NOMAD1_magV   [lindex $cata 2 15]
                  set NOMAD1_magR   [lindex $cata 2 17]
                  set NOMAD1_magJ   [lindex $cata 2 18]
                  set NOMAD1_magH   [lindex $cata 2 19]
                  set NOMAD1_magK   [lindex $cata 2 20]
               }
            }
         }
         set r [::bdi_tools_cdl::get_spectral_type \
                                 [list \
                                        $USNOA2_magB  $USNOA2_magR  $UCAC4_im1_mag $UCAC4_im2_mag \
                                        $NOMAD1_magB  $NOMAD1_magV  $NOMAD1_magR   $NOMAD1_magJ \
                                        $NOMAD1_magH  $NOMAD1_magK  ] \
               ]

         set ::bdi_tools_cdl::table_mag($name,USNOA2_magB)   $USNOA2_magB
         set ::bdi_tools_cdl::table_mag($name,USNOA2_magR)   $USNOA2_magR
         set ::bdi_tools_cdl::table_mag($name,UCAC4_im1_mag) $UCAC4_im1_mag
         set ::bdi_tools_cdl::table_mag($name,UCAC4_im2_mag) $UCAC4_im2_mag
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magB)   $NOMAD1_magB
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magV)   $NOMAD1_magV
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magR)   $NOMAD1_magR
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magJ)   $NOMAD1_magJ
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magH)   $NOMAD1_magH
         set ::bdi_tools_cdl::table_mag($name,NOMAD1_magK)   $NOMAD1_magK

         set ::bdi_tools_cdl::table_values($name,sptype)     [lindex $r 0]
         set ::bdi_tools_cdl::table_values($name,sptype,cpt) [lindex $r 1]
         set ::bdi_tools_cdl::table_values($name,sptype,sep) [lindex $r 2]
         #break
      }

   # Fin boucle sur les images
   }

   ::bdi_tools_cdl::calc_nb_sources

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Chargement a la volee complet en $tt sec \n"

   return

}




#----------------------------------------------------------------------------
## Chargement des variables necessaires au calcul de photometrie
#
proc ::bdi_tools_cdl::charge_cata_list { } {

   set tt0 [clock clicks -milliseconds]

   array unset ::bdi_tools_cdl::table_mesure
   array unset ::bdi_tools_cdl::id_to_name
   array unset ::bdi_tools_cdl::name_to_id
   array unset ::bdi_tools_cdl::table_data_source
   array unset ::bdi_tools_cdl::table_variations

   if {[info exists ::bdi_tools_cdl::list_of_stars]} {unset ::bdi_tools_cdl::list_of_stars}

   # reference
   set ids 0
   foreach {name y} [array get ::bdi_tools_cdl::table_noms] {

      incr ids
      if {$y != 1} {continue}

      array unset tab

      set nbimg 0
      set nbmes 0
      set flux_min 100000000000
      set radius_min 100000000000
      set nb_err_psf 0
               
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
         if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {

            incr nbimg

            set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set flux    [::bdi_tools_psf::get_val othf "flux"]
            set radius  [::bdi_tools_psf::get_val othf "radius"]
            set mag     [::bdi_tools_psf::get_val othf "mag"]

            # Colonne Nb Err PSF
            if {$err_psf != "-"} {
               incr nb_err_psf
            }

            # Colonne Radius Min
            if {$radius != "" && [string is integer $radius] && $radius < $radius_min} {
               set radius_min $radius
            }

            # gren_info "$name $idcata FLUX=$flux\n"
            if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {
               
               # Flag
               set ::bdi_tools_cdl::table_mesure($idcata,$name) 1
               
               # Ajout table flux pour stats
               lappend tab(flux) $flux
               
               # Nb mesure reussie
               incr nbmes
               
               # Ajout table mag pour stats
               if {$mag!="" && [string is double $mag] && $mag+1 != $mag} { lappend tab(mag) $mag }
               
               # Colonne Flux Min
               if {$flux < $flux_min} {
                  set flux_min $flux
               }

            } else {
               #set ::bdi_tools_cdl::table_noms($name) 0
               continue
            }
         }
      }

      #gren_info "[llength $tab(mag)] $nbimg\n"
      #gren_info "$tab(mag)\n"

      if { [info exists tab(mag)] } {
         if {[llength $tab(mag)]>1} {
            set mag_mean  [format "%0.4f" [::math::statistics::mean $tab(mag)]]
            set mag_stdev [format "%0.4f" [::math::statistics::stdev $tab(mag)]]
         } else {
            set mag_mean  [format "%0.4f" [lindex $tab(mag) 0]]
            set mag_stdev 0
         }
      } else {
            set mag_mean  "-99"
            set mag_stdev "0"
      }

      lappend ::bdi_tools_cdl::list_of_stars $ids
      set ::bdi_tools_cdl::id_to_name($ids) $name
      set ::bdi_tools_cdl::name_to_id($name) $ids
      set ::bdi_tools_cdl::table_data_source($name) [list $ids $name $nbimg $nbmes $mag_mean \
                                                          $mag_stdev $nb_err_psf $radius_min $flux_min]
   }

   # science & Rejected

   set ids 0
   foreach {name y} [array get ::bdi_tools_cdl::table_noms] {

      incr ids
      if {$y != 2 && $y != 0} {continue}

      array unset tab

      set nbimg 0
      set nbmes 0
      set flux_min 100000000000
      set radius_min 100000000000
      set nb_err_psf 0

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
         if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {
            incr nbimg
            set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set flux    [::bdi_tools_psf::get_val othf "flux"]
            set radius  [::bdi_tools_psf::get_val othf "radius"]
            set mag     [::bdi_tools_psf::get_val othf "mag"]

            # Colonne Nb Err PSF
            if {$err_psf != "-"} {
               incr nb_err_psf
            }

            # Colonne Radius Min
            if {$radius != "" && [string is integer $radius] && $radius < $radius_min} {
               set radius_min $radius
            }

            if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {

               # Ajout table flux pour stats
               lappend tab(flux) $flux
               
               # Nb mesure reussie
               incr nbmes
               
               # Ajout table mag pour stats
               if {$mag!="" && [string is double $mag] && $mag+1 != $mag} { lappend tab(mag) $mag }
               
               # Colonne Flux Min
               if {$flux < $flux_min} {
                  set flux_min $flux
               }

            } else {
               continue
            }
         }
      }

      if { [info exists tab(mag)] } {
         if {[llength $tab(mag)]>1} {
            set mag_mean  [format "%0.4f" [::math::statistics::mean $tab(mag)]]
            set mag_stdev [format "%0.4f" [::math::statistics::stdev $tab(mag)]]
         } else {
            set mag_mean  [format "%0.4f" [lindex $tab(mag) 0]]
            set mag_stdev 0
         }
      } else {
            set mag_mean  "-99"
            set mag_stdev "0"
      }

      set ::bdi_tools_cdl::table_data_source($name) [list $ids $name $nbimg $nbmes $mag_mean \
                                                          $mag_stdev $nb_err_psf $radius_min $flux_min]


   }


   if {![info exists ::bdi_tools_cdl::list_of_stars]} {
     gren_erreur "Aucune reference definie\n"
     return
   }


   # Onglet variation
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {

      foreach ids1 $::bdi_tools_cdl::list_of_stars {
         set name1 $::bdi_tools_cdl::id_to_name($ids1)
         if {![info exists ::bdi_tools_cdl::table_othf($name1,$idcata,othf)]} { continue }
         set othf $::bdi_tools_cdl::table_othf($name1,$idcata,othf)
         set flux1 [::bdi_tools_psf::get_val othf "flux"]
         if { $flux1=="" || $flux1<=0 || $flux1+1 == $flux1} { continue }

         foreach ids2 $::bdi_tools_cdl::list_of_stars {
            set name2 $::bdi_tools_cdl::id_to_name($ids2)
            if {![info exists ::bdi_tools_cdl::table_othf($name2,$idcata,othf)]} { continue }
            set othf $::bdi_tools_cdl::table_othf($name2,$idcata,othf)
            set flux2 [::bdi_tools_psf::get_val othf "flux"]
            if { $flux2=="" || $flux2<=0 || $flux2+1 == $flux2 } { continue }

            lappend ::bdi_tools_cdl::table_variations($ids1,$ids2,flux) [expr 1.0*$flux1/$flux2]
            lappend ::bdi_tools_cdl::table_variations($ids2,$ids1,flux) [expr 1.0*$flux2/$flux1]

         }

      }

   }

   array unset tab
   foreach ids1 $::bdi_tools_cdl::list_of_stars {
      foreach ids2 $::bdi_tools_cdl::list_of_stars {
         if { [info exists ::bdi_tools_cdl::table_variations($ids1,$ids2,flux)] } {
            set tab(flux) $::bdi_tools_cdl::table_variations($ids1,$ids2,flux)


            set nbmes [llength $tab(flux)]
            if {$nbmes>1} {
               set meanflux  [::math::statistics::mean  $tab(flux)]
               set stdevflux [::math::statistics::stdev $tab(flux)]
               set mag ""
               foreach rflux $tab(flux) {
                  lappend mag [expr  - 2.5*log10($rflux)]
               }
               set stdevmag  [::math::statistics::stdev $mag]
            } else {
               set meanflux  [lindex $tab(flux) 0]
               set stdevflux 0
               set stdevmag  "-98"
            }
         } else {
            set nbmes -1
            set meanflux  "-99"
            set stdevmag  "-99"
            set stdevflux "-99"
         }

         set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,mean)  $meanflux
         set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,stdev) $stdevflux
         set ::bdi_tools_cdl::table_variations($ids1,$ids2,mag,stdev)  $stdevmag
         set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,nbmes) $nbmes
      }
   }

   # Onglet Classification

   # Onglet Timeline
   set idcata 0
   #for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
      # date iso -> ::bdi_tools_cdl::table_date($idcata)
      # date iso -> ::bdi_tools_cdl::table_date($idcata)

   #}

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Affichage complet en $tt sec \n"

}




#----------------------------------------------------------------------------
## Ajoute une reference
#  \param name : Nom de la source de reference a ajouter
#  \param idps : identifiant numerique dans l'appli photometrie
#
proc ::bdi_tools_cdl::add_to_ref { name idps } {

   lappend ::bdi_tools_cdl::list_of_stars $idps

   if {![info exists ::bdi_tools_cdl::id_to_name($idps)]} {

      array unset tab
      set nbimg 0
      set nbmes 0
      set flux_min 100000000000
      set radius_min 100000000000
      set nb_err_psf 0

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
         if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {

            incr nbimg

            set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set flux    [::bdi_tools_psf::get_val othf "flux"]
            set radius  [::bdi_tools_psf::get_val othf "radius"]
            set mag     [::bdi_tools_psf::get_val othf "mag"]

            # Colonne Nb Err PSF
            if {$err_psf != "-"} {
               incr nb_err_psf
            }

            # Colonne Radius Min
            if {$radius != "" && [string is integer $radius] && $radius < $radius_min} {
               set radius_min $radius
            }

            if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {

               # Flag
               set ::bdi_tools_cdl::table_mesure($idcata,$name) 1
               
               # Ajout table flux pour stats
               lappend tab(flux) $flux
               
               # Nb mesure reussie
               incr nbmes
               
               # Ajout table mag pour stats
               if {$mag!="" && [string is double $mag] && $mag+1 != $mag} { lappend tab(mag) $mag }

               # Colonne Flux Min
               if {$flux < $flux_min} {
                  set flux_min $flux
               }

            } else {
               continue
            }
         }
      }

      if { [info exists tab(mag)] } {
         if {[llength $tab(mag)]>1} {
            set mag_mean  [format "%0.4f" [::math::statistics::mean $tab(mag)]]
            set mag_stdev [format "%0.4f" [::math::statistics::stdev $tab(mag)]]
         } else {
            set mag_mean  [format "%0.4f" [lindex $tab(mag) 0]]
            set mag_stdev 0
         }
      } else {
            set mag_mean  "-99"
            set mag_stdev "0"
      }

      set ::bdi_tools_cdl::id_to_name($idps) $name
      set ::bdi_tools_cdl::name_to_id($name) $idps
      set ::bdi_tools_cdl::table_data_source($name) [list $idps $name $nbimg $nbmes $mag_mean \
                                                          $mag_stdev $nb_err_psf $radius_min $flux_min]


   }

   # Onglet variation
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {

      if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} { continue }

      foreach ids1 $::bdi_tools_cdl::list_of_stars {
         set name1 $::bdi_tools_cdl::id_to_name($ids1)
         if {![info exists ::bdi_tools_cdl::table_othf($name1,$idcata,othf)]} { continue }
         set othf $::bdi_tools_cdl::table_othf($name1,$idcata,othf)
         set flux1 [::bdi_tools_psf::get_val othf "flux"]
         if { $flux1=="" || $flux1<=0 || $flux1+1 == $flux1} { continue }

         set name2 $name
         if {![info exists ::bdi_tools_cdl::table_othf($name2,$idcata,othf)]} { continue }
         set othf $::bdi_tools_cdl::table_othf($name2,$idcata,othf)
         set flux2 [::bdi_tools_psf::get_val othf "flux"]
         if { $flux2=="" || $flux2<=0 || $flux2+1 == $flux2 } { continue }

         lappend ::bdi_tools_cdl::table_variations($ids1,$ids2,flux) [expr 1.0*$flux1/$flux2]
         lappend ::bdi_tools_cdl::table_variations($ids2,$ids1,flux) [expr 1.0*$flux2/$flux1]

      }

   }

   array unset tab
   foreach ids1 $::bdi_tools_cdl::list_of_stars {
      foreach ids2 $::bdi_tools_cdl::list_of_stars {

         # condition du calcul necessaire
         if {$ids1 != $idps && $ids2 != $idps } {continue}

         if { [info exists ::bdi_tools_cdl::table_variations($ids1,$ids2,flux)] } {
            set tab(flux) $::bdi_tools_cdl::table_variations($ids1,$ids2,flux)


            set nbmes [llength $tab(flux)]
            if {$nbmes>1} {
               set meanflux  [::math::statistics::mean  $tab(flux)]
               set stdevflux [::math::statistics::stdev $tab(flux)]
               set mag ""
               foreach rflux $tab(flux) {
                  lappend mag [expr  - 2.5*log10($rflux)]
               }
               set stdevmag  [::math::statistics::stdev $mag]
            } else {
               set meanflux  [lindex $tab(flux) 0]
               set stdevflux 0
               set stdevmag  "-98"
            }
         } else {
            set nbmes -1
            set meanflux  "-99"
            set stdevmag  "-99"
            set stdevflux "-99"
         }

         set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,mean)  $meanflux
         set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,stdev) $stdevflux
         set ::bdi_tools_cdl::table_variations($ids1,$ids2,mag,stdev)  $stdevmag
         set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,nbmes) $nbmes
      }
   }
}


#----------------------------------------------------------------------------
## Met a jour la variable de progression
#  \param cur : pas courant
#  \param max : pax maximum
#
proc ::bdi_tools_cdl::set_progress { cur max } {
   set ::bdi_tools_cdl::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update
}



proc ::bdi_tools_cdl::free_memory {  } {

   array unset ::bdi_tools_cdl::table_mesure
   array unset ::bdi_tools_cdl::id_to_name
   array unset ::bdi_tools_cdl::name_to_id
   array unset ::bdi_tools_cdl::table_data_source
   array unset ::bdi_tools_cdl::table_variations
   array unset ::bdi_tools_cdl::table_noms
   array unset ::bdi_tools_cdl::table_othf
   array unset ::bdi_tools_cdl::table_nbcata
   array unset ::bdi_tools_cdl::table_star_exist
   array unset ::bdi_tools_cdl::table_values
   array unset ::bdi_tools_cdl::idcata_to_jdc
   array unset ::bdi_tools_cdl::table_jdmidexpo
   array unset ::bdi_tools_cdl::table_mag

   if {[info exists ::bdi_tools_cdl::list_of_stars]} {unset ::bdi_tools_cdl::list_of_stars}
}


#----------------------------------------------------------------------------
## Parser des champs de memoire
#  \param p_info : lignes de texte
#  \param key : cle dont la valeur est a recuperer
#  \return valeur : la valeur est a recuperer
#
proc ::bdi_tools_cdl::get_mem { p_info key } {
   upvar $p_info info

   set a [string first $key $info]
   set a [ string range $info [expr $a + [string length $key]] [expr $a + 30] ]
   set b [expr [string first "kB" $a] -1]
   set a [ string range $a 0 $b ]
   set a [ string trim $a]
   return $a
}


#----------------------------------------------------------------------------
## Recupere les info de la memoire
#  \return void
#
proc ::bdi_tools_cdl::get_memory {  } {

   if {$::bdi_tools_cdl::memory(memview)==0} {return}

   set pid [exec pidof audela]

   set info [exec cat /proc/$pid/status ]

   set ::bdi_tools_cdl::memory(mempid) [format "%0.1f Mb" [expr \
               [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]

   set info [exec cat /proc/meminfo ]

   set ::bdi_tools_cdl::memory(memtotal) [::bdi_tools_cdl::get_mem info "MemTotal:"]
   set ::bdi_tools_cdl::memory(memfree) [::bdi_tools_cdl::get_mem info "MemFree:"]
   set ::bdi_tools_cdl::memory(swaptotal) [::bdi_tools_cdl::get_mem info "SwapTotal:"]
   set ::bdi_tools_cdl::memory(swapfree) [::bdi_tools_cdl::get_mem info "SwapFree:"]
   set ::bdi_tools_cdl::memory(mem) [format "%0.1f" [expr 100.0*$::bdi_tools_cdl::memory(memfree)/$::bdi_tools_cdl::memory(memtotal)]]
   set ::bdi_tools_cdl::memory(swap) [format "%0.1f" [expr 100.0*$::bdi_tools_cdl::memory(swapfree)/$::bdi_tools_cdl::memory(swaptotal)]]
}

#----------------------------------------------------------------------------
## Recupere les info de la memoire le type spectral d'une etoile
#  \param l liste des magnitude dans les differents filtres
#  \return liste_results : liste de 3 parametres : indice spectral (0.0-50.0),
#  nombre de filtres, sep : sparation entre les indices min et max qui
# peux s'interpreter comme l'erreur sur la determination du type spectral
#
proc ::bdi_tools_cdl::get_spectral_type { l } {

   set USNOA2_magB    [ lindex $l  0 ]
   set USNOA2_magR    [ lindex $l  1 ]
   set UCAC4_im1_mag  [ lindex $l  2 ]
   set UCAC4_im2_mag  [ lindex $l  3 ]
   set NOMAD1_magB    [ lindex $l  4 ]
   set NOMAD1_magV    [ lindex $l  5 ]
   set NOMAD1_magR    [ lindex $l  6 ]
   set NOMAD1_magJ    [ lindex $l  7 ]
   set NOMAD1_magH    [ lindex $l  8 ]
   set NOMAD1_magK    [ lindex $l  9 ]

   set U ""
   set B ""
   set V ""
   set U ""
   set R ""
   set I ""
   set J ""
   set H ""
   set K ""
   set L ""
   set M ""
   set N ""

   if {$USNOA2_magB   != "" && $USNOA2_magB   > -10 } {set B $USNOA2_magB  }
   if {$USNOA2_magR   != "" && $USNOA2_magR   > -10 } {set R $USNOA2_magR  }
#      if {$UCAC4_im1_mag != "" && $UCAC4_im1_mag > -10 } {set N $UCAC4_im1_mag}
#      if {$UCAC4_im2_mag != "" && $UCAC4_im2_mag > -10 } {set N $UCAC4_im2_mag}
   if {$NOMAD1_magB   != "" && $NOMAD1_magB   > -10 } {set B $NOMAD1_magB  }
   if {$NOMAD1_magV   != "" && $NOMAD1_magV   > -10 } {set V $NOMAD1_magV  }
   if {$NOMAD1_magR   != "" && $NOMAD1_magR   > -10 } {set R $NOMAD1_magR  }
   if {$NOMAD1_magJ   != "" && $NOMAD1_magJ   > -10 } {set J $NOMAD1_magJ  }
   if {$NOMAD1_magH   != "" && $NOMAD1_magH   > -10 } {set H $NOMAD1_magH  }
   if {$NOMAD1_magK   != "" && $NOMAD1_magK   > -10 } {set K $NOMAD1_magK  }

   set UB ""
   set BV ""
   set VR ""
   set VI ""
   set VJ ""
   set VH ""
   set VK ""
   set VL ""
   set VM ""
   set VN ""

   if {$U!="" && $B!=""} { set UB [expr $U - $B] }
   if {$B!="" && $V!=""} { set BV [expr $B - $V] }
   if {$V!="" && $R!=""} { set VR [expr $V - $R] }
   if {$V!="" && $I!=""} { set VI [expr $V - $I] }
   if {$V!="" && $J!=""} { set VJ [expr $V - $J] }
   if {$V!="" && $H!=""} { set VH [expr $V - $H] }
   if {$V!="" && $K!=""} { set VK [expr $V - $K] }
   if {$V!="" && $L!=""} { set VL [expr $V - $L] }
   if {$V!="" && $M!=""} { set VM [expr $V - $M] }
   if {$V!="" && $N!=""} { set VN [expr $V - $N] }

   set idst ""
   if {$UB!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band UB $UB] }
   if {$BV!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band BV $BV] }
   if {$VR!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VR $VR] }
   if {$VI!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VI $VI] }
   if {$VJ!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VJ $VJ] }
   if {$VH!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VH $VH] }
   if {$VK!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VK $VK] }
   if {$VL!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VL $VL] }
   if {$VM!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VM $VM] }
   if {$VN!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VN $VN] }

   set cpt  [llength $idst]

   if {$cpt > 1 } {
      set mean [expr int([::math::statistics::mean $idst])]
      set min  [::math::statistics::min $idst]
      set max  [::math::statistics::max $idst]
      set sep  [expr $max - $min]
   } elseif { $cpt == 1 } {
      set mean [lindex $idst 0]
      set sep  -99
   } else {
      set mean -99
      set sep  -99
   }
   if {$mean>=0 && $mean<50} {
      return [list [lindex $::bdi_tools_cdl::table_sptype(sptype) $mean] $cpt $sep]
   }
   return "?"
}





#----------------------------------------------------------------------------
## Calcul l'indice numerique du type spectral pour une bande de magnitude
#  \param band : bande de magnitude (ex : B-V)
#  \param mag : valeur ed la magnitude (ex : magB-MagV)
#  \return idmin : indice numerique
#
proc ::bdi_tools_cdl::get_indice_by_band { band mag} {

   set min 99
   set idst 0
   set idmin -1

   foreach val $::bdi_tools_cdl::table_sptype($band) {
      set tmp [expr abs($val - $mag)]
      if {$tmp<$min} {
         set idmin $idst
         set min $tmp
      }
      incr idst
   }
   return $idmin
}

#----------------------------------------------------------------------------
## Definition de la table de calcul des indeices numeriques du type spectral
# en fonction des valeurs des bandes.
# Initialisation du tableau en variable de namespace
#  \return void
#  \brief Explication de la table :
# The following table aims to provide a guide to the unreddened
# colours expected for main sequence stars of spectral types B0
# to M4. The data are taken from Fitzgerald (1970 - A&A 4, 234),
# who provides UBV data for spectral classes O5 to M8, and from
# Ducati et al. (2001 - ApJ, 558, 309), who cover B0 to M4. Both
# compilations also present data for giants and supergiants.
# Ducati et al. present photometry on the Johnson 11-colour
# system, and we have used the relations given by Bessell (1979
# - PASP 91, 589) to transform the (V-R) and (V-I) colours to
# the Cousins system. The L (3.5 micron), M (4.8 micron) and N
# (10.5 micron) colours are essentially on the PbS-based system
# and give only a guide to the colours with modern photometers,
# detectors and filters.
#
#
# SpType   U-B   (B-V)  (V-R)C  (V-I)C   (V-J)   (V-H)   (V-K)   (V-L)   (V-M)   (V-N)  (V-R)J  (V-I)J
# B0.0   -1.08   -0.30   -0.19   -0.31   -0.80   -0.92   -0.97   -1.13   -1.00   -9.99   -0.22   -0.44
# B0.5   -1.00   -0.28   -0.18   -0.31   -0.77   -0.89   -0.95   -1.11   -0.99   -9.99   -0.20   -0.43
# B1.0   -0.95   -0.26   -0.16   -0.30   -0.73   -0.85   -0.93   -1.08   -0.96   -9.99   -0.18   -0.42
# B1.5   -0.88   -0.25   -0.15   -0.29   -0.70   -0.82   -0.91   -1.05   -0.94   -9.99   -0.17   -0.41
# B2.0   -0.81   -0.24   -0.14   -0.29   -0.67   -0.79   -0.89   -1.02   -0.92   -9.99   -0.15   -0.40
# B2.5   -0.72   -0.22   -0.13   -0.28   -0.64   -0.76   -0.86   -0.97   -0.88   -0.96   -0.14   -0.39
# B3.0   -0.68   -0.20   -0.12   -0.27   -0.60   -0.72   -0.82   -0.92   -0.84   -0.91   -0.13   -0.38
# B3.5   -0.65   -0.19   -0.12   -0.26   -0.58   -0.70   -0.80   -0.90   -0.82   -0.87   -0.12   -0.37
# B4.0   -0.63   -0.18   -0.11   -0.25   -0.56   -0.68   -0.77   -0.86   -0.79   -0.84   -0.11   -0.35
# B4.5   -0.61   -0.17   -0.11   -0.24   -0.54   -0.65   -0.74   -0.83   -0.76   -0.80   -0.11   -0.34
# B5.0   -0.58   -0.16   -0.10   -0.24   -0.51   -0.62   -0.71   -0.78   -0.73   -0.75   -0.10   -0.33
# B6.0   -0.49   -0.14   -0.10   -0.21   -0.46   -0.57   -0.64   -0.70   -0.65   -0.66   -0.09   -0.29
# B7.0   -0.43   -0.13   -0.09   -0.19   -0.41   -0.51   -0.57   -0.61   -0.58   -0.58   -0.08   -0.26
# B7.5   -0.40   -0.12   -0.09   -0.17   -0.39   -0.48   -0.54   -0.57   -0.54   -0.53   -0.08   -0.24
# B8.0   -0.36   -0.11   -0.08   -0.16   -0.36   -0.45   -0.49   -0.52   -0.49   -0.48   -0.07   -0.22
# B8.5   -0.27   -0.09   -0.08   -0.13   -0.31   -0.40   -0.43   -0.43   -0.42   -0.39   -0.07   -0.18
# B9.0   -0.18   -0.07   -0.07   -0.10   -0.26   -0.34   -0.33   -0.34   -0.34   -0.30   -0.06   -0.14
# B9.5   -0.10   -0.04   -0.05   -0.08   -0.22   -0.29   -0.26   -0.27   -0.26   -0.22   -0.03   -0.11
# A0.0   -0.02   -0.01   -0.04   -0.04   -0.16   -0.19   -0.17   -0.18   -0.18   -0.14   -0.01   -0.05
# A1.0    0.01    0.02   -0.02   -0.02   -0.11   -0.12   -0.11   -0.12   -0.13   -0.08    0.01   -0.03
# A2.0    0.05    0.05   -0.01    0.00   -0.07   -0.04   -0.05   -0.07   -0.08   -0.02    0.03    0.00
# A3.0    0.08    0.08    0.01    0.02   -0.02    0.03    0.01   -0.01   -0.02    0.03    0.05    0.02
# A4.0    0.09    0.12    0.02    0.05    0.03    0.11    0.08    0.05   -0.04    0.09    0.07    0.07
# A5.0    0.09    0.15    0.04    0.09    0.09    0.19    0.15    0.12    0.10    0.16    0.10    0.12
# A6.0    0.10    0.17    0.05    0.12    0.13    0.30    0.21    0.17    0.15    0.21    0.11    0.16
# A7.0    0.10    0.20    0.06    0.15    0.18    0.32    0.27    0.23    0.20    0.26    0.13    0.19
# A8.0    0.09    0.27    0.09    0.20    0.25    0.42    0.36    0.33    0.29    0.34    0.16    0.26
# A9.0    0.08    0.30    0.10    0.24    0.31    0.49    0.44    0.41    0.36    0.41    0.18    0.31
# F0.0    0.03    0.32    0.12    0.28    0.37    0.57    0.52    0.49    0.43    0.48    0.21    0.36
# F1.0    0.00    0.34    0.14    0.31    0.43    0.64    0.58    0.57    0.49    0.54    0.23    0.40
# F2.0    0.00    0.35    0.15    0.35    0.48    0.71    0.66    0.66    0.56    0.60    0.25    0.45
# F5.0   -0.02    0.45    0.21    0.44    0.67    0.93    0.89    0.90    0.77    0.80    0.33    0.57
# F8.0    0.02    0.53    0.24    0.50    0.79    1.06    1.03    1.06    0.91    0.91    0.37    0.64
# G0.0    0.06    0.60    0.27    0.54    0.87    1.15    1.14    1.18    1.01    1.01    0.41    0.70
# G2.0    0.09    0.63    0.30    0.58    0.97    1.25    1.26    1.31    1.12    1.11    0.45    0.75
# G3.0    0.12    0.65    0.30    0.59    0.98    1.27    1.28    1.33    1.14    1.13    0.45    0.76
# G5.0    0.20    0.68    0.31    0.61    1.02    1.31    1.32    1.38    1.18    1.17    0.47    0.78
# G8.0    0.30    0.74    0.35    0.66    1.14    1.44    1.47    1.55    1.34    1.30    0.52    0.85
# K0.0    0.44    0.81    0.42    0.75    1.34    1.67    1.74    1.85    1.61    1.54    0.61    0.97
# K1.0    0.48    0.86    0.46    0.82    1.46    1.80    1.89    2.02    1.78    1.68    0.67    1.05
# K2.0    0.67    0.92    0.50    0.89    1.60    1.94    2.06    2.21    1.97    1.84    0.73    1.14
# K3.0    0.73    0.95    0.55    0.97    1.73    2.09    2.23    2.40    2.17    2.01    0.80    1.25
# K4.0    1.00    1.00    0.60    1.04    1.84    2.22    2.38    2.57    2.36    2.15    0.86    1.34
# K5.0    1.06    1.15    0.68    1.20    2.04    2.46    2.66    2.87    2.71    2.44    0.97    1.54
# K7.0    1.21    1.33    0.62    1.45    2.30    2.78    3.01    3.25    3.21    2.83    1.13    1.86
# M0.0    1.23    1.37    0.70    1.67    2.49    3.04    3.29    3.54    3.65    3.16    1.26    2.15
# M1.0    1.18    1.47    0.76    1.84    2.61    3.22    3.47    3.72    3.95    3.39    1.36    2.36
# M2.0    1.15    1.47    0.83    2.06    2.74    3.42    3.67    3.92    4.31    3.66    1.46    2.62
# M3.0    1.17    1.50    0.89    2.24    2.84    3.58    3.83    4.08    4.62    3.89    1.56    2.84
# M4.0    1.07    1.52    0.94    2.43    2.93    3.74    3.98    4.22    4.93    4.11    1.65    3.07
#----------------------------------------------------------------------------
proc ::bdi_tools_cdl::init_spectral_type { } {

   array unset ::bdi_tools_cdl::table_sptype

   set ::bdi_tools_cdl::table_sptype(UB) [list \
                   -1.08 -1.00 -0.95 -0.88 -0.81 \
                   -0.72 -0.68 -0.65 -0.63 -0.61 \
                   -0.58 -0.49 -0.43 -0.40 -0.36 \
                   -0.27 -0.18 -0.10 -0.02  0.01 \
                    0.05  0.08  0.09  0.09  0.10 \
                    0.10  0.09  0.08  0.03  0.00 \
                    0.00 -0.02  0.02  0.06  0.09 \
                    0.12  0.20  0.30  0.44  0.48 \
                    0.67  0.73  1.00  1.06  1.21 \
                    1.23  1.18  1.15  1.17  1.07 \
                    ]

   set ::bdi_tools_cdl::table_sptype(BV) [list \
                   -0.30 -0.28 -0.26 -0.25 -0.24 \
                   -0.22 -0.20 -0.19 -0.18 -0.17 \
                   -0.16 -0.14 -0.13 -0.12 -0.11 \
                   -0.09 -0.07 -0.04 -0.01  0.02 \
                    0.05  0.08  0.12  0.15  0.17 \
                    0.20  0.27  0.30  0.32  0.34 \
                    0.35  0.45  0.53  0.60  0.63 \
                    0.65  0.68  0.74  0.81  0.86 \
                    0.92  0.95  1.00  1.15  1.33 \
                    1.37  1.47  1.47  1.50  1.52 \
                    ]


   set ::bdi_tools_cdl::table_sptype(VR) [list \
                   -0.19 -0.18 -0.16 -0.15 -0.14 \
                   -0.13 -0.12 -0.12 -0.11 -0.11 \
                   -0.10 -0.10 -0.09 -0.09 -0.08 \
                   -0.08 -0.07 -0.05 -0.04 -0.02 \
                   -0.01  0.01  0.02  0.04  0.05 \
                    0.06  0.09  0.10  0.12  0.14 \
                    0.15  0.21  0.24  0.27  0.30 \
                    0.30  0.31  0.35  0.42  0.46 \
                    0.50  0.55  0.60  0.68  0.62 \
                    0.70  0.76  0.83  0.89  0.94 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VI) [list \
                   -0.31 -0.31 -0.30 -0.29 -0.29 \
                   -0.28 -0.27 -0.26 -0.25 -0.24 \
                   -0.24 -0.21 -0.19 -0.17 -0.16 \
                   -0.13 -0.10 -0.08 -0.04 -0.02 \
                    0.00  0.02  0.05  0.09  0.12 \
                    0.15  0.20  0.24  0.28  0.31 \
                    0.35  0.44  0.50  0.54  0.58 \
                    0.59  0.61  0.66  0.75  0.82 \
                    0.89  0.97  1.04  1.20  1.45 \
                    1.67  1.84  2.06  2.24  2.43 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VJ) [list \
                   -0.80 -0.77 -0.73 -0.70 -0.67 \
                   -0.64 -0.60 -0.58 -0.56 -0.54 \
                   -0.51 -0.46 -0.41 -0.39 -0.36 \
                   -0.31 -0.26 -0.22 -0.16 -0.11 \
                   -0.07 -0.02  0.03  0.09  0.13 \
                    0.18  0.25  0.31  0.37  0.43 \
                    0.48  0.67  0.79  0.87  0.97 \
                    0.98  1.02  1.14  1.34  1.46 \
                    1.60  1.73  1.84  2.04  2.30 \
                    2.49  2.61  2.74  2.84  2.93 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VH) [list \
                   -0.92 -0.89 -0.85 -0.82 -0.79 \
                   -0.76 -0.72 -0.70 -0.68 -0.65 \
                   -0.62 -0.57 -0.51 -0.48 -0.45 \
                   -0.40 -0.34 -0.29 -0.19 -0.12 \
                   -0.04  0.03  0.11  0.19  0.30 \
                    0.32  0.42  0.49  0.57  0.64 \
                    0.71  0.93  1.06  1.15  1.25 \
                    1.27  1.31  1.44  1.67  1.80 \
                    1.94  2.09  2.22  2.46  2.78 \
                    3.04  3.22  3.42  3.58  3.74 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VK) [list \
                   -0.97 -0.95 -0.93 -0.91 -0.89 \
                   -0.86 -0.82 -0.80 -0.77 -0.74 \
                   -0.71 -0.64 -0.57 -0.54 -0.49 \
                   -0.43 -0.33 -0.26 -0.17 -0.11 \
                   -0.05  0.01  0.08  0.15  0.21 \
                    0.27  0.36  0.44  0.52  0.58 \
                    0.66  0.89  1.03  1.14  1.26 \
                    1.28  1.32  1.47  1.74  1.89 \
                    2.06  2.23  2.38  2.66  3.01 \
                    3.29  3.47  3.67  3.83  3.98 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VL) [list \
                   -1.13 -1.11 -1.08 -1.05 -1.02 \
                   -0.97 -0.92 -0.90 -0.86 -0.83 \
                   -0.78 -0.70 -0.61 -0.57 -0.52 \
                   -0.43 -0.34 -0.27 -0.18 -0.12 \
                   -0.07 -0.01  0.05  0.12  0.17 \
                    0.23  0.33  0.41  0.49  0.57 \
                    0.66  0.90  1.06  1.18  1.31 \
                    1.33  1.38  1.55  1.85  2.02 \
                    2.21  2.40  2.57  2.87  3.25 \
                    3.54  3.72  3.92  4.08  4.22 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VM) [list \
                   -1.00 -0.99 -0.96 -0.94 -0.92 \
                   -0.88 -0.84 -0.82 -0.79 -0.76 \
                   -0.73 -0.65 -0.58 -0.54 -0.49 \
                   -0.42 -0.34 -0.26 -0.18 -0.13 \
                   -0.08 -0.02 -0.04  0.10  0.15 \
                    0.20  0.29  0.36  0.43  0.49 \
                    0.56  0.77  0.91  1.01  1.12 \
                    1.14  1.18  1.34  1.61  1.78 \
                    1.97  2.17  2.36  2.71  3.21 \
                    3.65  3.95  4.31  4.62  4.93 \
                    ]

   set ::bdi_tools_cdl::table_sptype(VN) [list \
                   -9.99 -9.99 -9.99 -9.99 -9.99 \
                   -0.96 -0.91 -0.87 -0.84 -0.80 \
                   -0.75 -0.66 -0.58 -0.53 -0.48 \
                   -0.39 -0.30 -0.22 -0.14 -0.08 \
                   -0.02  0.03  0.09  0.16  0.21 \
                    0.26  0.34  0.41  0.48  0.54 \
                    0.60  0.80  0.91  1.01  1.11 \
                    1.13  1.17  1.30  1.54  1.68 \
                    1.84  2.01  2.15  2.44  2.83 \
                    3.16  3.39  3.66  3.89  4.11 \
                    ]

   set ::bdi_tools_cdl::table_sptype(sptype) [list \
             "(01) B0.0" "(02) B0.5" "(03) B1.0" "(04) B1.5" "(05) B2.0" \
             "(06) B2.5" "(07) B3.0" "(08) B3.5" "(09) B4.0" "(10) B4.5" \
             "(11) B5.0" "(12) B6.0" "(13) B7.0" "(14) B7.5" "(15) B8.0" \
             "(16) B8.5" "(17) B9.0" "(18) B9.5" "(19) A0.0" "(20) A1.0" \
             "(21) A2.0" "(22) A3.0" "(23) A4.0" "(24) A5.0" "(25) A6.0" \
             "(26) A7.0" "(27) A8.0" "(28) A9.0" "(29) F0.0" "(30) F1.0" \
             "(31) F2.0" "(32) F5.0" "(33) F8.0" "(34) G0.0" "(35) G2.0" \
             "(36) G3.0" "(37) G5.0" "(38) G8.0" "(39) K0.0" "(40) K1.0" \
             "(41) K2.0" "(42) K3.0" "(43) K4.0" "(44) K5.0" "(45) K7.0" \
             "(46) M0.0" "(47) M1.0" "(48) M2.0" "(49) M3.0" "(50) M4.0" \
                    ]

 }


#proc ::bdi_tools_cdl::calcul_const_mags2 { } {
#
#
#   ::bdi_tools_cdl::calcul_const_mags
#   ::bdi_tools_cdl::calcul_ref
#   ::bdi_tools_cdl::charge_list
#   ::bdi_tools_cdl::calcul_const_mags
#
#}


#----------------------------------------------------------------------------
## Calcul des constantes de magnitudes
#  \return void
#
proc ::bdi_tools_cdl::calcul_const_mags { } {

   set tt0 [clock clicks -milliseconds]

   set fluxcst 100000.0

   # preparation des donnees
   array unset ::bdi_tools_cdl::table_superstar_flux
   array unset ::bdi_tools_cdl::table_superstar_id
   array unset ::bdi_tools_cdl::table_superstar_idcata
   array unset ::bdi_tools_cdl::table_superstar_exist
   array unset ::bdi_tools_cdl::table_star_flux
   set table_idcata ""
   array unset table_name
   array unset table_ids
   set idcata 0
   set id_superstar 0
   set nb_superstar 0

   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

      if {![info exists ::bdi_tools_cdl::table_date($idcata)]} {
         continue
      }
      set table_name($idcata) ""
      set indice_superstar ""
      set cpt 0
      set ids 0
      set sum 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y != 1} {continue}
         if {![info exists ::bdi_tools_cdl::table_mesure($idcata,$name)]} { continue }
         if { $::bdi_tools_cdl::table_mesure($idcata,$name) != 1 } { continue }
         lappend table_name($idcata) $name
         lappend table_ids($idcata) $ids

         set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
         set flux [::bdi_tools_psf::get_val othf "flux"]
         if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {
            #gren_info "idcata $idcata name $name ids $ids\n"
            set ::bdi_tools_cdl::table_star_flux($name,$idcata,flux) $flux
            set sum [expr $sum + $::bdi_tools_cdl::table_star_flux($name,$idcata,flux)]

            if {$cpt == 0} {
               append indice_superstar $ids
               set ::bdi_tools_cdl::table_superstar_list($idcata) [list $ids]
            }
            if {$cpt != 0} {
               append indice_superstar ",$ids"
               lappend ::bdi_tools_cdl::table_superstar_list($idcata) $ids
            }
            incr cpt

         } else {

            ::console::affiche_erreur "Attention calcul de la const mag incorrect\n"
            ::console::affiche_erreur "Flux invalide pour l etoile $name\n"
            ::console::affiche_erreur "FLUX = $flux\n"
            ::console::affiche_erreur "IDCATA = $idcata\n"
            ::console::affiche_erreur "DATE  = $::bdi_tools_cdl::table_date($idcata)\n"
            return

         }

      }
      if {[llength $table_name($idcata)] > 0} {
         lappend table_idcata $idcata
      }

      if {$indice_superstar != ""} {
         if {[info exists ::bdi_tools_cdl::table_superstar_exist($indice_superstar)]} {
            set id_superstar $::bdi_tools_cdl::table_superstar_exist($indice_superstar)
         } else {
            incr nb_superstar
            set id_superstar $nb_superstar
            set ::bdi_tools_cdl::table_superstar_exist($indice_superstar) $id_superstar
         }
         set ::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata) $sum
         set ::bdi_tools_cdl::table_superstar_idcata($idcata) $id_superstar
         set ::bdi_tools_cdl::table_superstar_id($id_superstar) [split $indice_superstar ,]
         #gren_info "superstar_exist: $id_superstar $indice_superstar $idcata ($::bdi_tools_cdl::table_superstar_id($id_superstar)) Flux = $::bdi_tools_cdl::table_superstar_flux($id_superstar)\n"
      }

   }
   #gren_info "nb_superstar = $nb_superstar \n"
   # Affichage des superstars
   #foreach {indice_superstar id_superstar} [array get ::bdi_tools_cdl::table_superstar_exist] {
   #   gren_info "id_superstar $id_superstar indice_superstar $indice_superstar \n"
   #   continue
   #}


   for {set k 1} {$k <= 1} { incr k } {

      # calcul des magnitudes des superstars
      array unset ::bdi_tools_cdl::table_superstar_mag
      array unset ::bdi_tools_cdl::table_superstar_solu
      array unset ::bdi_tools_cdl::table_star_mag

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}


         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
         #if { $id_superstar !=1 } { continue }

         #gren_info "idcata $idcata : id_superstar $id_superstar \n"
         #gren_info "starlist ($::bdi_tools_cdl::table_superstar_id($id_superstar))\n"
         #gren_info "Flux superstar = $::bdi_tools_cdl::table_superstar_flux($id_superstar)\n"

         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {

            set name  $::bdi_tools_cdl::id_to_name($ids)
            set mag   [lindex $::bdi_tools_cdl::table_data_source($name) 4]
            set flux  $::bdi_tools_cdl::table_star_flux($name,$idcata,flux)

            set magss [expr $mag -2.5 * log10(1.0 * $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata) / $flux) ]
            #lappend ::bdi_tools_cdl::table_superstar_mag
            #gren_info "ids = $ids Mag = $mag Flux = $flux -> mag superstar ($id_superstar) = $magss\n"

            if {![info exists ::bdi_tools_cdl::table_superstar_mag($id_superstar)]} {
               set ::bdi_tools_cdl::table_superstar_mag($id_superstar) [list $magss]
            } else {
               lappend ::bdi_tools_cdl::table_superstar_mag($id_superstar) $magss
            }
         }

      }

      # superstars moyennes
      foreach {indice_superstar id_superstar} [array get ::bdi_tools_cdl::table_superstar_exist] {

         #if { $id_superstar !=1 } { continue }

         if {![info exists ::bdi_tools_cdl::table_superstar_mag($id_superstar)]} {
            continue
         }

         set ::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) 0
         set ::bdi_tools_cdl::table_superstar_solu($id_superstar,stdevmag) 0

         set nb [llength $::bdi_tools_cdl::table_superstar_mag($id_superstar)]
         if {$nb == 0} {
            continue
         }
         if {$nb == 1} {
            set mean  [lindex $::bdi_tools_cdl::table_superstar_mag($id_superstar) 0]
            set stdev 0
         }
         if {$nb > 1} {
            set mean [::math::statistics::mean $::bdi_tools_cdl::table_superstar_mag($id_superstar)]
            set stdev [::math::statistics::stdev $::bdi_tools_cdl::table_superstar_mag($id_superstar)]
         }

         set ::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) $mean
         set ::bdi_tools_cdl::table_superstar_solu($id_superstar,stdevmag) $stdev


         #gren_info "id_superstar $id_superstar nb = $nb  mag = $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) stdev = $::bdi_tools_cdl::table_superstar_solu($id_superstar,stdevmag) \n"
         continue
      }

      # Maj des magnitudes des etoiles de references
      array unset mag_stars
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}

         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
         #if { $id_superstar !=1 } { continue }
         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {
            set name  $::bdi_tools_cdl::id_to_name($ids)
            set flux  $::bdi_tools_cdl::table_star_flux($name,$idcata,flux)
            set mag [expr $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) -2.5 * log10(1.0 * $flux / $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata)) ]
            if {![info exists mag_stars($ids)]} {
               set mag_stars($ids) [list $mag]
            } else {
               lappend mag_stars($ids) $mag
            }
            set ::bdi_tools_cdl::table_star_mag($ids,$idcata) $mag
         }
      }

      foreach {ids tab_mag} [array get mag_stars] {
         set name  $::bdi_tools_cdl::id_to_name($ids)
         #gren_info "Star $ids : $tab_mag \n"
         if {![info exists tab_mag]} {
            continue
         }
         set nb [llength $tab_mag]
         if {$nb == 0} {
            continue
         }
         if {$nb == 1} {
            set mean  [lindex $tab_mag 0]
            set stdev 0
         }
         if {$nb > 1} {
            set mean [::math::statistics::mean $tab_mag]
            set stdev [::math::statistics::stdev $tab_mag]
         }
         set mean [format "%0.4f" $mean]
         set stdev [format "%0.4f" $stdev]
         set ::bdi_tools_cdl::table_data_source($name) [lreplace $::bdi_tools_cdl::table_data_source($name) 4 4 $mean]
         set ::bdi_tools_cdl::table_data_source($name) [lreplace $::bdi_tools_cdl::table_data_source($name) 5 5 $stdev]
         #gren_info "Star $ids : nb = $nb :  mag = $mean stdev = $stdev \n"
      }

   }

   # Fin de calcul de la constante de magnitude
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Calcul de la constante de magnitude en $tt sec \n"

}



#----------------------------------------------------------------------------
## Calcul de la photometrie des objets sciences
#  \return void
#
proc ::bdi_tools_cdl::calcul_science { } {

   set tt0 [clock clicks -milliseconds]
      # Maj des magnitudes des etoiles de references
      array unset mag_sciences
      array unset ::bdi_tools_cdl::table_science_mag

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
         #if { $id_superstar !=1 } { continue }
         set ids 0
         foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
            incr ids
            if {$y != 2} {continue}
            #gren_info "=> $::bdi_tools_cdl::table_data_source($name)\n"
            if {![info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {continue}
            set ::bdi_tools_cdl::id_to_name($ids) $name
            set ::bdi_tools_cdl::name_to_id($name) $ids
            set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set flux [::bdi_tools_psf::get_val othf "flux"]
            if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {
               #gren_info "flux = $flux\n"
               set mag [expr $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) -2.5 * log10(1.0 * $flux / $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata)) ]

               #gren_info "mag = $idcata $mag\n"
               if {![info exists mag_sciences($ids)]} {
                  set mag_sciences($ids) [list $mag]
               } else {
                  lappend mag_sciences($ids) $mag
               }
               set ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) $mag

               # Calcul de l'erreur en mag
               set err_flux [::bdi_tools_psf::get_val othf "err_flux"]
               if {$err_flux!="" && [string is double $err_flux] && $err_flux+1 != $err_flux && $err_flux > 0} {

                  set magmax [expr $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) \
                                 -2.5 * log10(1.0 * ($flux + $err_flux) / $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata)) ]
                  set err_mag [expr $mag - $magmax]
                  set ::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag) $err_mag

               }
            }
         }
      }

      foreach {ids tab_mag} [array get mag_sciences] {
         set name $::bdi_tools_cdl::id_to_name($ids)
         if {![info exists tab_mag]} {
            continue
         }
         set nb [llength $tab_mag]
         if {$nb == 0} {
            continue
         }
         if {$nb == 1} {
            set mean  [lindex $tab_mag 0]
            set stdev 0
         }
         if {$nb > 1} {
            set mean [::math::statistics::mean $tab_mag]
            set stdev [::math::statistics::stdev $tab_mag]
         }
         set mean [format "%0.4f" $mean]
         set stdev [format "%0.4f" $stdev]
         set ::bdi_tools_cdl::table_data_source($name) [lreplace $::bdi_tools_cdl::table_data_source($name) 4 4 $mean]
         set ::bdi_tools_cdl::table_data_source($name) [lreplace $::bdi_tools_cdl::table_data_source($name) 5 5 $stdev]
         #gren_info "Star $ids : nb = $nb :  mag = $mean stdev = $stdev \n"
      }

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Calcul des sciences en $tt sec \n"
}


#----------------------------------------------------------------------------
## Calcul de la photometrie des objets rejetes
#  \return void
#
proc ::bdi_tools_cdl::calcul_rejected { } {

   set tt0 [clock clicks -milliseconds]
      # Maj des magnitudes des etoiles de references
      array unset mag_rejected

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
         #if { $id_superstar !=1 } { continue }
         set ids 0
         foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
            incr ids
            if {$y != 0} {continue}
            #gren_info "=> $::bdi_tools_cdl::table_data_source($name)\n"
            if {![info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {continue}
            set ::bdi_tools_cdl::id_to_name($ids) $name
            set ::bdi_tools_cdl::name_to_id($name) $ids
            set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set flux [::bdi_tools_psf::get_val othf "flux"]
            if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0 } {
               #gren_info "flux = $flux\n"
               set mag [expr $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) -2.5 * log10(1.0 * $flux / $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata)) ]

               #gren_info "mag = $idcata $mag\n"
               if {![info exists mag_rejected($ids)]} {
                  set mag_rejected($ids) [list $mag]
               } else {
                  lappend mag_rejected($ids) $mag
               }
            }
         }
      }

      foreach {ids tab_mag} [array get mag_rejected] {
         set name $::bdi_tools_cdl::id_to_name($ids)
         if {![info exists tab_mag]} {
            continue
         }
         set nb [llength $tab_mag]
         if {$nb == 0} {
            continue
         }
         if {$nb == 1} {
            set mean  [lindex $tab_mag 0]
            set stdev 0
         }
         if {$nb > 1} {
            set mean [::math::statistics::mean $tab_mag]
            set stdev [::math::statistics::stdev $tab_mag]
         }
         set mean [format "%0.4f" $mean]
         set stdev [format "%0.4f" $stdev]
         set ::bdi_tools_cdl::table_data_source($name) [lreplace $::bdi_tools_cdl::table_data_source($name) 4 4 $mean]
         set ::bdi_tools_cdl::table_data_source($name) [lreplace $::bdi_tools_cdl::table_data_source($name) 5 5 $stdev]
         #gren_info "Star $ids : nb = $nb :  mag = $mean stdev = $stdev \n"
      }

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Calcul des sources rejetees en $tt sec \n"
}






#----------------------------------------------------------------------------
## Prepare cata_list pour une sauvegarde
# met a jour les magnitudes des sources qui contienne le catalogue ASTROID
# met a jour les flag photometriques
#  \param list_name_R : Liste des sources de reference
#  \param list_name_S : Liste des sources sciences
#  \return void
#
proc ::bdi_tools_cdl::export_photom_to_gestion { list_name_R list_name_S } {

   set othf_null [::bdi_tools_psf::get_astroid_null]

   # On flag Rejetee sur toutes les sources
   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} { incr ::tools_cata::id_current_image } {

      set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
      set fields  [lindex  $::tools_cata::current_listsources 0]
      set sources [lindex  $::tools_cata::current_listsources 1]

      set ids -1
      set newsources $sources
      foreach s $sources {
         incr ids
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         if {$othf==$othf_null} {continue}
         set fp_av [::bdi_tools_psf::get_val othf flagphotom]
         ::bdi_tools_psf::set_by_key othf flagphotom ""
         ::bdi_tools_psf::set_by_key othf cataphotom ""
         set fp_ap [::bdi_tools_psf::get_val othf flagphotom]
         
         # 
         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($::tools_cata::id_current_image)]} {
            continue
         }
         
         # Maj des magnitudes
         set flux [::bdi_tools_psf::get_val othf "flux"]
         if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {

            if {![info exists ::bdi_tools_cdl::table_superstar_idcata($::tools_cata::id_current_image)]} {
               continue
            }
            set id_superstar   $::bdi_tools_cdl::table_superstar_idcata($::tools_cata::id_current_image)
            set mag_superstar  $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag)
            set flux_superstar $::bdi_tools_cdl::table_superstar_flux($id_superstar,$::tools_cata::id_current_image)
            set mag [expr $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) -2.5 * log10(1.0 * $flux / $::bdi_tools_cdl::table_superstar_flux($id_superstar,$::tools_cata::id_current_image)) ]
            set err_mag -1
            set err_flux [::bdi_tools_psf::get_val othf "err_flux"]
            if {$err_flux!="" && [string is double $err_flux] && $err_flux+1 != $err_flux && $err_flux > 0} {
               set magmax [expr $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) \
                              -2.5 * log10(1.0 * ($flux + $err_flux) / $::bdi_tools_cdl::table_superstar_flux($id_superstar,$::tools_cata::id_current_image)) ]
               set err_mag [expr $mag - $magmax]
            }
            ::bdi_tools_psf::set_by_key othf "mag" $mag
            ::bdi_tools_psf::set_by_key othf "err_mag" $err_mag
         }

         # Recombine la source
         ::bdi_tools_psf::set_astroid_in_source s othf
         set newsources [lreplace $newsources $ids $ids $s]
      }
      set ::tools_cata::current_listsources [list $fields $newsources]
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   }

   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} { incr ::tools_cata::id_current_image } {

      set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
      set fields  [lindex  $::tools_cata::current_listsources 0]
      set sources [lindex  $::tools_cata::current_listsources 1]


      # On boucle sur les nom des sources a flagger Reference
      foreach name $list_name_R {
         set ids [::manage_source::name2ids $name ::tools_cata::current_listsources]
         set s [lindex $sources $ids]
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         if {$othf==$othf_null} {continue}
         ::bdi_tools_psf::set_by_key othf flagphotom "R"
         ::bdi_tools_psf::set_astroid_in_source s othf
         set sources [lreplace $sources $ids $ids $s]
      }
      # On boucle sur les nom des sources a flagger Science
      foreach name $list_name_S {
         set ids [::manage_source::name2ids $name ::tools_cata::current_listsources]
         set s [lindex $sources $ids]
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         if {$othf==$othf_null} {continue}
         ::bdi_tools_psf::set_by_key othf flagphotom "S"
         ::bdi_tools_psf::set_astroid_in_source s othf
         set sources [lreplace $sources $ids $ids $s]
      }
      set ::tools_cata::current_listsources [list $fields $sources]
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   }

   return
}


#----------------------------------------------------------------------------
## Avancement de la barre de progression lors de la sauvegarde des
# @param cur real Valeur courante
# @param max real Valeur maximum de la barre de progression
# @return void
proc ::bdi_tools_cdl::set_savprogress { cur max } {

   set ::bdi_tools_cdl::savprogress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update

}


#----------------------------------------------------------------------------
## Sauvegarde des images et des catas a la suite de la reduction photometrique
# @return void
proc ::bdi_tools_cdl::save_images { } {

   global audace bddconf

   gren_info "Sauvegarde des images en cours...\n"

   # reflag les source dans les cata_list
   set list_name_R ""
   set list_name_S ""

   set ids 0
   foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$y == 1} {
         lappend list_name_R $name
         continue
      }
      if {$y == 2} {
         lappend list_name_S $name
         continue
      }
   }

   # Preparation de catalist
   ::bdi_tools_cdl::export_photom_to_gestion $list_name_R $list_name_S


   # on sauve les cata et les images
   set id_current_image 0
   foreach current_image $::tools_cata::img_list {

      incr id_current_image
      gren_info "."

      # Progression
      ::bdi_tools_cdl::set_savprogress $id_current_image $::tools_cata::nb_img_list
      if { $::bdi_tools_cdl::savannul } { break }

      # Tabkey
      set idbddimg    [::bddimages_liste::lget $current_image "idbddimg"]
      set tabkey      [::bddimages_liste::lget $current_image "tabkey"]
      set imgfilename [::bddimages_liste::lget $current_image filename]

      # Noms des fichiers
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      # buf$::audace(bufNo) setkwd [list $kwd $val $type $unit $comment]

      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]

      # intialise les variables pour le header
      if {![info exists ::bdi_tools_cdl::table_superstar_idcata($id_current_image)]} { continue }
      set id_superstar       $::bdi_tools_cdl::table_superstar_idcata($id_current_image)
      set mag_superstar      $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag)
      set flux_superstar     $::bdi_tools_cdl::table_superstar_flux($id_superstar,$id_current_image)

      # Maj du buffer
      buf$::audace(bufNo) load $fileimg

      ::bdi_tools_astrometry::set_fits_key "IAU_CODE" $::bdi_tools_cdl::rapport_uai_code "string" "Observatory IAU Code" ""
      ::bdi_tools_astrometry::set_fits_key "OBSERVER" $::bdi_tools_cdl::rapport_observ "string" "Observer name" ""
      ::bdi_tools_astrometry::set_fits_key "INSTRUME" $::bdi_tools_cdl::rapport_instru "string" "Instrument" ""

      ::bdi_tools_astrometry::set_fits_key "BDDIMAGES NBREF" [llength $::bdi_tools_cdl::list_of_stars] "int" "Nb photometric ref stars" ""
      ::bdi_tools_astrometry::set_fits_key "BDDIMAGES CM_REF_MAG" $mag_superstar "double" "Magnitude of synthetic reference star" "ADU"
      ::bdi_tools_astrometry::set_fits_key "BDDIMAGES CM_REF_FLUX" $flux_superstar "double" "Integrated Flux of synthetic reference star" "ADU"
      ::bdi_tools_astrometry::set_fits_key "BDDIMAGES PHOTOMETRY" "FINAL" "string" "Photometry performed" ""

      # TODO : fwhm_mean
      # TODO : fwhm_std
      # TODO : seeing (fwhm * facteur d echelle)
      # TODO : CATAPHOTOM liste unique  de l'ensemble des catalogues dont on puise la valeur de magnitude pour les etoiles de reference

      # Creation de l image temporaire
      set fichtmpunzip [unzipedfilename $fileimg]
      set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
      set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]
      createdir_ifnot_exist $bddconf(dirtmp)
      buf$::audace(bufNo) save $filetmp
      lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg

      # efface l image dans la base et le disque
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      # insere l image dans la base
      set err [catch {set idbddimg [insertion_solo $filefinal]} msg]
      if {$err} {
         gren_info "Erreur Insertion (ERR=$err) (MSG=$msg) (RESULT=$idbddimg) \n"
      }

      # Effacement de l image du repertoire tmp
      set errnum [catch {file delete $filetmp} msg]

      # insere le cata dans la base
      set tabkey [::bdi_tools_image::get_tabkey_from_buffer]
      ::tools_cata::save_cata $::bdi_gui_cata::cata_list($id_current_image) $tabkey $cataxml

      # Maj  ::tools_cata::img_list
      set current_image [::bddimages_liste::lupdate $current_image idbddimg $idbddimg]
      set current_image [::bddimages_liste::lupdate $current_image tabkey $tabkey]
      set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $id_current_image - 1] [expr $id_current_image - 1] $current_image]

      #return

   }
      gren_info "\n"

   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]

}


#----------------------------------------------------------------------------
## Enregistrement des resultats en vue d'une diffusion ou d'un stockage
#
#----------------------------------------------------------------------------
proc ::bdi_tools_cdl::save_reports { } {

   global bddconf


   set tt0 [clock clicks -milliseconds]
   # Verfifie les repertoires


   # Prepare les entetes
   set ::bdi_tools_cdl::rapport_batch [::bdi_tools_reports::get_batch]

   # Prepare la table
   array unset ::bdi_tools_cdl::results_table

   set ids 0
   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$o != 2} {continue}

      set tab_mag ""
      set tab_err_mag ""
      set tab_ra  ""
      set tab_dec ""
      set tab_jd ""
      set tab_exposure ""
      set tab_binning ""
      set cpt 0
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
         set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)

         set midexpo_iso [mc_date2iso8601 $::bdi_tools_cdl::table_jdmidexpo($idcata)]
         set midexpo_jd  $::bdi_tools_cdl::table_jdmidexpo($idcata)
         set mag         $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
         set fwhm        [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) fwhm      ]
         set ra          [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) ra        ]
         set dec         [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) dec       ]
         set flux        [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) flux      ]
         set err_flux    [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) err_flux  ]
         set psf_method  [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) psf_method]
         set globale     [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) globale   ]
         set radius      [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($name,$idcata,othf) radius    ]

         # Filtre
         set current_image [lindex $::tools_cata::img_list [expr $idcata-1]]
         set tabkey      [::bddimages_liste::lget $current_image "tabkey"]
         set filter      [string trim [lindex [::bddimages_liste::lget $tabkey "FILTER"]   1] ]
         set exposure    [string trim [lindex [::bddimages_liste::lget $tabkey "EXPOSURE"] 1] ]
         lappend tab_exposure $exposure
         set bin         [string trim [lindex [::bddimages_liste::lget $tabkey "BIN1"] 1] ]
         lappend tab_binning $bin
         
         set midexpo_iso [format "%23s"   $midexpo_iso ]
         set midexpo_jd  [format "%0.10f" $midexpo_jd  ]
         set mag         [format "%7.4f"  $mag         ]
         set fwhm        [format "%5.2f"  $fwhm        ]
         set filter      [format "%-10s"  $filter      ]
         set exposure    [format "%7.2f"  $exposure    ]
         set ra          [format "%10.6f" $ra          ]
         set dec         [format "%10.6f" $dec         ]
         set radius      [format "%5s"    $radius      ]
         set globale     [format "%8s"    $globale     ]
         set psf_method  [format "%-32s"  $psf_method  ]

         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)]} {
            set err_mag     "-     "
         } else {
            set err_mag     [format "%0.4f" $::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)]
            lappend tab_err_mag $err_mag
         }
         if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {
            set flux [format "%15.2f" $flux ]
         } else {
            set flux [format "%17s" "Nan"]
         }
         if {$err_flux!="" && [string is double $err_flux] && $err_flux+1 != $err_flux && $err_flux > 0} {
            #gren_erreur "err_flux = $err_flux \n"
            set err_flux [format "%15.2f" $err_flux ]
         } else {
            set err_flux [format "%15s" "Nan"]
         }

         incr cpt
         set ::bdi_tools_cdl::results_table($name,$cpt,midexpo_iso)  $midexpo_iso
         set ::bdi_tools_cdl::results_table($name,$cpt,midexpo_jd)   $midexpo_jd
         set ::bdi_tools_cdl::results_table($name,$cpt,mag)          $mag
         set ::bdi_tools_cdl::results_table($name,$cpt,err_mag)      $err_mag
         set ::bdi_tools_cdl::results_table($name,$cpt,fwhm)         $fwhm
         set ::bdi_tools_cdl::results_table($name,$cpt,filter)       $filter
         set ::bdi_tools_cdl::results_table($name,$cpt,exposure)     $exposure
         set ::bdi_tools_cdl::results_table($name,$cpt,ra)           $ra
         set ::bdi_tools_cdl::results_table($name,$cpt,dec)          $dec
         set ::bdi_tools_cdl::results_table($name,$cpt,flux)         $flux
         set ::bdi_tools_cdl::results_table($name,$cpt,err_flux)     $err_flux
         set ::bdi_tools_cdl::results_table($name,$cpt,radius)       $radius
         set ::bdi_tools_cdl::results_table($name,$cpt,globale)      $globale
         set ::bdi_tools_cdl::results_table($name,$cpt,psf_method)   $psf_method

         lappend tab_mag $mag
         lappend tab_ra  $ra
         lappend tab_dec $dec
         lappend tab_jd $midexpo_jd
      }
      set ::bdi_tools_cdl::results_table($name,nb) $cpt
      set ::bdi_tools_cdl::results_table($name,duration) [format "%.1f" [expr ([::math::statistics::max $tab_jd]-[::math::statistics::min $tab_jd])*24.0] ]
      set ::bdi_tools_cdl::results_table($name,mag)     [format "%.3f" [::math::statistics::mean  $tab_mag] ]
      set ::bdi_tools_cdl::results_table($name,mag_std) [format "%.3f" [::math::statistics::stdev $tab_mag] ]
      set ::bdi_tools_cdl::results_table($name,mag_err) [format "%.3f" [::math::statistics::mean  $tab_err_mag] ]
      set ::bdi_tools_cdl::results_table($name,mag_amplitude) [format "%.3f" [expr [::math::statistics::max $tab_mag]-[::math::statistics::min $tab_mag]]]

      set ::bdi_tools_cdl::results_table($name,ra)      [::bdi_tools_astrometry::convert_txt_hms [::math::statistics::mean  $tab_ra] ]
      set ::bdi_tools_cdl::results_table($name,dec)     [::bdi_tools_astrometry::convert_txt_dms [::math::statistics::mean  $tab_dec] ]

      set ::bdi_tools_cdl::results_table($name,binning)     [::math::statistics::median $tab_binning]
      set ::bdi_tools_cdl::results_table($name,exposure)    [format "%.0f" [::math::statistics::mean $tab_exposure] ]

   }

   # Fichier de log
   set filename [file join $bddconf(dirlog) photom_mag_prec.csv]
   if {![file exists $filename]} {
      set f [open $filename w]
      puts $f "name,mag,mag_prec,fwhm,exposure,binning"
   } else {
      set f [open $filename a+]
   }

   set date    [string range $::bdi_tools_cdl::table_date(1) 0 9]
   set ids 0
   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$o != 2} {continue}

      set obj $name
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      set dir [file join $dir $date]

      # on efface tous les rapport qui pourraient exister et qui ont le meme batch
      set liste [globr $dir]
      foreach file $liste {
         set pos [string first ${::bdi_tools_cdl::rapport_batch} $file]
         if {$pos !=-1} {
            gren_info "Delete: $file\n"
            set err [catch {file delete -force $file} msg]
            if {$err} {gren_erreur $msg}
         }
      }

      # On cree une entree dans le fichier de log
      if {![info exists ::bdi_gui_cdl::widget(famous,stats,$obj,residuals_std)]} {
         set mag_prec ""
      } else {
         set mag_prec [format "%.3f" $::bdi_gui_cdl::widget(famous,stats,$obj,residuals_std)]
      }
      set line $obj
      append line ",$::bdi_tools_cdl::results_table($obj,mag)"
      append line ",$mag_prec"
      append line ",$::bdi_tools_cdl::fwhm"
      append line ",$::bdi_tools_cdl::results_table($name,exposure)"
      append line ",$::bdi_tools_cdl::results_table($name,binning)"
      
      puts $f $line

   }
   close $f

   # QUESTION : Calcul des FWHM a partir des sources de reference uniquement ?
   # si oui c est a ecrire ici
   # actuellement la fwhm globale est calculee a partir de toutes les sources de toutes les images.

   # Enregistre les rapports

   ::bdi_tools_cdl::create_report_txt
   ::bdi_tools_cdl::create_report_xml

   array unset ::bdi_tools_cdl::results_table

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Sauvegarde des resultats en $tt sec \n"

}



proc ::bdi_tools_cdl::get_info_list { obj firstdate } {

   set type              "photom"
   set batch             ${::bdi_tools_cdl::rapport_batch}
   set submit_mpc        "no"
   set iau_code          ${::bdi_tools_cdl::rapport_uai_code}
   set subscriber        ${::bdi_tools_cdl::rapport_rapporteur}
   set address           ${::bdi_tools_cdl::rapport_adresse}
   set mail              ${::bdi_tools_cdl::rapport_mail}
   set software          "Audela Bddimages Photometry v4"
   set observers         ${::bdi_tools_cdl::rapport_observ}
   set reduction         ${::bdi_tools_cdl::rapport_reduc}
   set instrument        ${::bdi_tools_cdl::rapport_instru}
   set nb_dates          $::bdi_tools_cdl::results_table($obj,nb)
   set duration          $::bdi_tools_cdl::results_table($obj,duration)
   set mag_mean          $::bdi_tools_cdl::results_table($obj,mag)
   set mag_std           $::bdi_tools_cdl::results_table($obj,mag_std)
   set mag_amp           $::bdi_tools_cdl::results_table($obj,mag_amplitude)
   # le resultat de famous
   #set mag_prec          $::bdi_tools_cdl::results_table($obj,mag_err)
   if {![info exists ::bdi_gui_cdl::widget(famous,stats,$obj,residuals_std)]} {
      set mag_prec "-"
   } else {
      set mag_prec [format "%.3f" $::bdi_gui_cdl::widget(famous,stats,$obj,residuals_std)]
   }
  set cm_var_max        ${::bdi_tools_cdl::var_constmag_max}
   set cm_var_moy        ${::bdi_tools_cdl::var_constmag_moy}
   set cm_var_med        ${::bdi_tools_cdl::var_constmag_med}
   set cm_var_std        ${::bdi_tools_cdl::var_constmag_std}
   set fwhm_mean         $::bdi_tools_cdl::fwhm
   set fwhm_std          $::bdi_tools_cdl::fwhm_std
   set ra_mean           $::bdi_tools_cdl::results_table($obj,ra)
   set dec_mean          $::bdi_tools_cdl::results_table($obj,dec)
   set nb_ref_stars      [llength $::bdi_tools_cdl::list_of_stars]
   set comment           ${::bdi_tools_cdl::rapport_comment}

   return [list obj $obj type $type firstdate $firstdate batch $batch submit_mpc $submit_mpc iau_code $iau_code \
                subscriber $subscriber address $address mail $mail software $software observers $observers reduction $reduction \
                instrument $instrument nb_dates $nb_dates duration $duration \
                mag_mean $mag_mean mag_std $mag_std mag_amp $mag_amp mag_prec $mag_prec \
                cm_var_max $cm_var_max cm_var_moy $cm_var_moy cm_var_med $cm_var_med cm_var_std $cm_var_std \
                fwhm_mean $fwhm_mean fwhm_std $fwhm_std ra_mean $ra_mean dec_mean $dec_mean \
                nb_ref_stars $nb_ref_stars comment $comment]
}


#----------------------------------------------------------------------------
## Creation d'un rapport sous forme de fichier texte tabule.
#  \return void
#
proc ::bdi_tools_cdl::create_report_txt { } {

   global bddconf

   set batch ${::bdi_tools_cdl::rapport_batch}

   set firstdate    [string range $::bdi_tools_cdl::table_date(1) 0 9]

   set ids 0
   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {

      incr ids
      if {$o != 2} {continue}
      set obj $name

      # Creation des repertoires
      set dir_obj [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      createdir_ifnot_exist $dir_obj
      set dir_firstdate [file join $dir_obj $firstdate]
      createdir_ifnot_exist $dir_firstdate
      set dir_batch [file join $dir_firstdate $batch]
      createdir_ifnot_exist $dir_batch

      # Sauvegarde du fichier info
      set outfile [::bdi_tools_reports::build_filename $obj $firstdate $batch "info" "txt"]
      set rootfile [file join $dir_batch $outfile]
      gren_info "  - Rapport INFO : $rootfile\n"
      set info_list [::bdi_tools_cdl::get_info_list $obj $firstdate]
      ::bdi_tools_reports::list_to_file_info $rootfile info_list

      set outfile [::bdi_tools_reports::build_filename $obj $firstdate $batch photom txt]
      set rootfile [file join $dir_batch $outfile]

      set chan [open $rootfile w]

      puts $chan "#$+---------------------------------------------------------------------------"
      puts $chan "# OBJECT            = $name"
      puts $chan "# IAU code          = ${::bdi_tools_cdl::rapport_uai_code}"
      puts $chan "# Subscriber        = ${::bdi_tools_cdl::rapport_rapporteur}"
      puts $chan "# Address           = ${::bdi_tools_cdl::rapport_adresse}"
      puts $chan "# Mail              = ${::bdi_tools_cdl::rapport_mail}"
      puts $chan "# Software          = Audela Bddimages Photometry v3"
      puts $chan "# Observers         = ${::bdi_tools_cdl::rapport_observ}"
      puts $chan "# Reduction         = ${::bdi_tools_cdl::rapport_reduc}"
      puts $chan "# Instrument        = ${::bdi_tools_cdl::rapport_instru}"
      puts $chan "# Batch             = ${::bdi_tools_cdl::rapport_batch}"
      puts $chan "# Nb of dates       = $::bdi_tools_cdl::results_table($name,nb)"
      puts $chan "# Duration (h)      = $::bdi_tools_cdl::results_table($name,duration)"
      puts $chan "# Magnitude         = $::bdi_tools_cdl::results_table($name,mag)"
      puts $chan "# Magnitude STD     = $::bdi_tools_cdl::results_table($name,mag_std)"
      puts $chan "# Magnitude Ampl    = $::bdi_tools_cdl::results_table($name,mag_amplitude)"
      puts $chan "# Variation Max CM  = $::bdi_tools_cdl::var_constmag_max"
      puts $chan "# Variation Moy CM  = $::bdi_tools_cdl::var_constmag_moy"
      puts $chan "# Variation Med CM  = $::bdi_tools_cdl::var_constmag_med"
      puts $chan "# Variation STD CM  = $::bdi_tools_cdl::var_constmag_std"
      puts $chan "# Magnitude Err     = $::bdi_tools_cdl::results_table($name,mag_err)"
      puts $chan "# FWHM (arcsec)     = $::bdi_tools_cdl::fwhm"
      puts $chan "# FWHM STD (arcsec) = $::bdi_tools_cdl::fwhm_std"
      puts $chan "# Right Asc. (hms)  = $::bdi_tools_cdl::results_table($name,ra)"
      puts $chan "# Declination (dms) = $::bdi_tools_cdl::results_table($name,dec)"
      puts $chan "# Nb Star Ref       = [llength $::bdi_tools_cdl::list_of_stars]"
      puts $chan "#$----------------------------------------------------------------------------"

      set line ""

      append line "#\n"
      append line "#Description of columns   :\n"
      append line "# col  1 : Date ISO    : ISO-Date at mid-exposure \n"
      append line "# col  2 : Julian Date : Julian Date at mid-exposure\n"
      append line "# col  3 : Mag         : Measured magnitude\n"
      append line "# col  4 : ErrMag      : Uncertainty on measured magnitude\n"
      append line "# col  5 : FWHM        : Full width at half maximum\n"
      append line "# col  6 : Filter      : Image filter\n"
      append line "# col  7 : Exposure    : Exposure time of Image in second\n"
      append line "# col  8 : RA          : Astrometric J2000 right ascension\n"
      append line "# col  9 : DEC         : Astrometric J2000 declination\n"
      append line "# col 10 : Flux        : Integrated Flux\n"
      append line "# col 11 : Err Flux    : Uncertainty on integrated Flux\n"
      append line "# col 12 : Radius      : Radius inside which the PSF where fitted\n"
      append line "# col 13 : Globale     : The set of radius where Globale method processed\n"
      append line "# col 14 : PSF_Model   : PSF model\n"

      append line "#\n"
      append line "#Date ISO               Julian Date        Mag     ErrMag  FWHM    Filter Exposure   RA         DEC             Flux          Err_Flux   Radius Global  PSF_Model\n"
      append line "#---------------------------------------------------------------------------------------------------------------------------------------------------------------\n"

      for {set cpt 1} {$cpt <= $::bdi_tools_cdl::results_table($name,nb)} { incr cpt } {

         append line $::bdi_tools_cdl::results_table($name,$cpt,midexpo_iso) ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,midexpo_jd)  ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,mag)         ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,err_mag)     ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,fwhm)        ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,filter)      ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,exposure)    ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,ra)          ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,dec)         ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,flux)        ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,err_flux)    ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,radius)      ; append line " "
         append line $::bdi_tools_cdl::results_table($name,$cpt,globale)     ; append line "  "
         append line $::bdi_tools_cdl::results_table($name,$cpt,psf_method)  ; append line "\n"

      }

      puts $chan $line
      close $chan
      gren_info "  - Rapport TXT : $rootfile\n"
   }


   return -code 0 ""
}


#----------------------------------------------------------------------------
## Creation d'un rapport sous forme de fichier XML VOTABLE
#  \return void
#
proc ::bdi_tools_cdl::create_report_xml {  } {

   global bddconf

   set batch ${::bdi_tools_cdl::rapport_batch}
   set firstdate    [string range $::bdi_tools_cdl::table_date(1) 0 9]
   set ids 0

   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {

      incr ids
      if {$o != 2} {continue}
      set obj $name

      # Creation des repertoires
      set dir_obj [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      createdir_ifnot_exist $dir_obj
      set dir_firstdate [file join $dir_obj $firstdate]
      createdir_ifnot_exist $dir_firstdate
      set dir_batch [file join $dir_firstdate $batch]
      createdir_ifnot_exist $dir_batch

      set outfile [::bdi_tools_reports::build_filename $obj $firstdate $batch photom xml]
      set rootfile [file join $dir_batch $outfile]

      # Init VOTable: defini la version et le prefix (mettre "" pour supprimer le prefixe)
      ::votable::init "1.1" ""
      # Ouvre une VOTable
      set votable [::votable::openVOTable]
      # Ajoute l'element INFO pour definir le QUERY_STATUS = "OK" | "ERROR"
      append votable [::votable::addInfoElement "status" "QUERY_STATUS" "OK"] "\n"
      # Ouvre l'element RESOURCE
      append votable [::votable::openResourceElement {} ] "\n"

      # Definition des champs PARAM
      set votParams ""
      set description "Observatory IAU code"
      set p [ list "$::votable::Field::ID \"iaucode\"" \
                   "$::votable::Field::NAME \"IAUCode\"" \
                   "$::votable::Field::UCD \"meta.code\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"3\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_cdl::rapport_uai_code}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Subscriber"
      set p [ list "$::votable::Field::ID \"subscriber\"" \
                   "$::votable::Field::NAME \"Subscriber\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_rapporteur}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Address"
      set p [ list "$::votable::Field::ID \"address\"" \
                   "$::votable::Field::NAME \"Address\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_adresse}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mail"
      set p [ list "$::votable::Field::ID \"mail\"" \
                   "$::votable::Field::NAME \"Mail\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_mail}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Software"
      set p [ list "$::votable::Field::ID \"software\"" \
                   "$::votable::Field::NAME \"Software\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"Audela Bddimages\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Observers"
      set p [ list "$::votable::Field::ID \"observers\"" \
                   "$::votable::Field::NAME \"Observers\"" \
                   "$::votable::Field::UCD \"obs.observer\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_observ}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Reduction"
      set p [ list "$::votable::Field::ID \"reduction\"" \
                   "$::votable::Field::NAME \"Reduction\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_reduc}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Instrument"
      set p [ list "$::votable::Field::ID \"instrument\"" \
                   "$::votable::Field::NAME \"Instrument\"" \
                   "$::votable::Field::UCD \"meta.id;instr\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_instru}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Batch"
      set p [ list "$::votable::Field::ID \"batch\"" \
                   "$::votable::Field::NAME \"Batch\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_cdl::rapport_batch}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "NumberOfPositions"
      set p [ list "$::votable::Field::ID \"numbdate\"" \
                   "$::votable::Field::NAME \"NumberOfDates\"" \
                   "$::votable::Field::UCD \"meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_cdl::results_table($name,nb)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Object Name"
      set p [ list "$::votable::Field::ID \"object\"" \
                   "$::votable::Field::NAME \"Object\"" \
                   "$::votable::Field::UCD \"meta.id;meta.name\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      lappend p "$::votable::Param::VALUE ${obj}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      # Ajoute les params a la votable
      append votable $votParams

      # Definition des champs FIELDS
      set description "ISO-Date at mid-exposure"
      set f [ list "$::votable::Field::ID \"isodate\"" \
                   "$::votable::Field::NAME \"ISO-Date\"" \
                   "$::votable::Field::UCD \"time.epoch\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"24\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Julian date at mid-exposure"
      set f [ list "$::votable::Field::ID \"jddate\"" \
                   "$::votable::Field::NAME \"JD-Date\"" \
                   "$::votable::Field::UCD \"time.epoch\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"16\"" \
                   "$::votable::Field::PRECISION \"8\"" \
                   "$::votable::Field::UNIT \"d\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Measured magnitude"
      set f [ list "$::votable::Field::ID \"mag\"" \
                   "$::votable::Field::NAME \"Magnitude\"" \
                   "$::votable::Field::UCD \"phot.mag\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"13\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"mag\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Uncertainty on measured magnitude"
      set f [ list "$::votable::Field::ID \"mag_err\"" \
                   "$::votable::Field::NAME \"Err Mag\"" \
                   "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"13\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"mag\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Full width at half maximum"
      set f [ list "$::votable::Field::ID \"fwhm\"" \
                   "$::votable::Field::NAME \"fwhm\"" \
                   "$::votable::Field::UCD \"obs.param;phys.angSize\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"4\"" \
                   "$::votable::Field::UNIT \"px\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Image filter"
      set f [ list "$::votable::Field::ID \"filter\"" \
                   "$::votable::Field::NAME \"Filter\"" \
                   "$::votable::Field::UCD \"meta.id;instr.filter\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Exposure time of Image in second"
      set f [ list "$::votable::Field::ID \"exposure\"" \
                   "$::votable::Field::NAME \"Exposure\"" \
                   "$::votable::Field::UCD \"time.duration;obs.exposure\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"7\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"sec\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Astrometric J2000 right ascension"
      set f [ list "$::votable::Field::ID \"ra\"" \
                   "$::votable::Field::NAME \"RA\"" \
                   "$::votable::Field::UCD \"pos.eq.ra;meta.main\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"6\"" \
                   "$::votable::Field::UNIT \"deg\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Astrometric J2000 declination"
      set f [ list "$::votable::Field::ID \"dec\"" \
                   "$::votable::Field::NAME \"DEC\"" \
                   "$::votable::Field::UCD \"pos.eq.dec;meta.main\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"6\"" \
                   "$::votable::Field::UNIT \"deg\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Integrated Flux"
      set f [ list "$::votable::Field::ID \"flux\"" \
                   "$::votable::Field::NAME \"Flux\"" \
                   "$::votable::Field::UCD \"phot.flux\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"adu\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Uncertainty on integrated Flux"
      set f [ list "$::votable::Field::ID \"err_flux\"" \
                   "$::votable::Field::NAME \"Err Flux\"" \
                   "$::votable::Field::UCD \"stat.error;phot.flux\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"adu\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Radius inside which the PSF where fitted"
      set f [ list "$::votable::Field::ID \"radius\"" \
                   "$::votable::Field::NAME \"Radius\"" \
                   "$::votable::Field::UCD \"phys.size.radius;instr.pixel\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"6\"" \
                   "$::votable::Field::UNIT \"px\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "The set of radius where Globale method processed"
      set f [ list "$::votable::Field::ID \"globale\"" \
                   "$::votable::Field::NAME \"Globale\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "PSF model"
      set f [ list "$::votable::Field::ID \"psf_method\"" \
                   "$::votable::Field::NAME \"PSF Model\"" \
                   "$::votable::Field::UCD \"stat.fit;instr.det.psf\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"*\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"


      # Construit la table des donnees

      set nrows 0
      set votSources ""

      for {set cpt 1} {$cpt <= $::bdi_tools_cdl::results_table($name,nb)} { incr cpt } {

         append votSources [::votable::openElement $::votable::Element::TR {}]

         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,midexpo_iso) ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,midexpo_jd)  ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,mag)         ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,err_mag)     ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,fwhm)        ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,filter)      ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,exposure)    ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,ra)          ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,dec)         ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,flux)        ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,err_flux)    ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,radius)      ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,globale)     ] ]
         append votSources [::votable::addElement $::votable::Element::TD {} [string trim $::bdi_tools_cdl::results_table($name,$cpt,psf_method)  ] ]

         append votSources [::votable::closeElement $::votable::Element::TR] "\n"

      }

      set zname [lrange [split $name "_"] 2 end]
      # Ouvre l'element TABLE
      append votable [::votable::openTableElement [list "$::votable::Table::NAME \"Photometric results for $zname\"" "$::votable::Table::NROWS $::bdi_tools_cdl::results_table($name,nb)"]] "\n"
      #  Ajoute un element de description de la table
      append votable [::votable::addElement $::votable::Element::DESCRIPTION {} "Photometric measures of science object $zname obtained by Audela/Bddimages"] "\n"
      #  Ajoute les definitions des colonnes
      append votable $votFields
      #  Ouvre l'element DATA
      append votable [::votable::openElement $::votable::Element::DATA {}] "\n"
      #   Ouvre l'element TABLEDATA
      append votable [::votable::openElement $::votable::Element::TABLEDATA {}] "\n"
      #    Ajoute les sources
      append votable $votSources
      #   Ferme l'element TABLEDATA
      append votable [::votable::closeElement $::votable::Element::TABLEDATA] "\n"
      #  Ferme l'element DATA
      append votable [::votable::closeElement $::votable::Element::DATA] "\n"
      # Ferme l'element TABLE
      append votable [::votable::closeTableElement] "\n"

      # Ferme l'element RESOURCE
      append votable [::votable::closeResourceElement] "\n"
      # Ferme la VOTable
      append votable [::votable::closeVOTable]

      # ecrit le fichier
      set chan [open $rootfile w]
      puts $chan $votable
      close $chan
      gren_info "  - Rapport XML : $rootfile\n"

   }

   return

}




# ::bddimages::ressource ; ::bdi_tools_cdl::load_report_xml mydata "/bddimages/bdi_t60_les_makes/reports/SKYBOT_666_Desdemona/2017-11-29/Audela_BDI_2017-11-30T08:43:53_CET/SKYBOT_666_Desdemona.2017-11-29.Audela_BDI_2017-11-30T08:43:53_CET.photom.xml"
#----------------------------------------------------------------------------
## Lecture d'un rapport sous forme de fichier XML VOTABLE
#  \return void
#
proc ::bdi_tools_cdl::load_report_xml { p_data file } {

   upvar $p_data data

   array unset data

   set xmldoc ""
   set f [open $file r]
   while {![eof $f]} {
      append xmldoc [gets $f]
   }
   close $f

   # Analyse du doc XML pour charger la config dans xmlConfig
   set xml [::dom::parse $xmldoc]
   
   set data(list,param) ""
   foreach n [::dom::selectNode $xml {descendant::PARAM}] {
      if { [catch {::dom::node stringValue [::dom::selectNode $n {attribute::ID}]} id] == 0 } {
         if { [catch {::dom::node stringValue [::dom::selectNode $n {attribute::value}]} value] == 0 } {
            set data(param,$id) $value
            lappend data(list,param) $id
         }
      }
   }

   set data(list,field) ""
   foreach n [::dom::selectNode $xml {descendant::FIELD/attribute::ID}] {
      lappend data(list,field) [::dom::node stringValue $n]
   }

   set id 0
   foreach tr [::dom::selectNode $xml {descendant::TR}] {
      set cpt 0
      foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
         set data(table,$id,[lindex $data(list,field) $cpt]) [::dom::node stringValue $td]
         incr cpt
      }
      incr id
   }
   set data(nbrows) $id
   return
}
