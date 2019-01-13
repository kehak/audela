## @file bdi_tools_priam.tcl
#  @brief     Reduction astrom&eacute;trique &agrave; l'aide de Priam
#  @author    J. Berthier <berthier@imcce.fr> et F. Vachier <fv@imcce.fr>
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_priam.tcl]
#  @endcode

# $Id: bdi_tools_priam.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_priam
# @brief Reduction astrom&eacute;trique &agrave; l'aide de Priam
# @pre Requiert la librairie Eproc et le programme priam
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_priam {

   # @var Nom du fichier de conditions observationnelles (e.g. /rep/cmd.priam)
   variable cmdpriam "cmd.priam"

   # @var Nom de base du fichier de conditions observationnelles (e.g. cnd.obs)
   variable filecnd "cnd.obs"

   # @var Nom de base du fichier des sources a reduire (e.g. science.mes)
   variable filemes "science.mes"

   # @var Nom de base du fichier du fichier local des etoiles de reference (e.g. local.cat)
   variable filecat "local.cat"

   # @var Nom de base du fichier des resultats astrometriques (e.g. science.mes.bdi.last)
   variable fileres "science.mes.bdi.last"

}

#----------------------------------------------------------------------------
## Execution du programme priam
# @details Les fichiers necessaires a l'execution de Priam doivent deja etre crees (cnd.obs, local.cat, cmd.priam)
# @return Le nom du fichier resultat, ou le code d'erreur -1 avec un message
proc ::bdi_tools_priam::launch_priam { } {

   global bddconf
   set err [catch {exec sh [file join $bddconf(dirtmp) $::bdi_tools_priam::cmdpriam]} msg]
   if {$err || $msg != 0} {
      gren_erreur "Priam error #$err: $msg\n"
      return -code -1 $msg
   }

   # Affichage du log de Priam dans la console:
   set chan [open [file join $bddconf(dirtmp) "priam.log"] r]
   #gren_info "LOG Priam ---------------------------\n"
   #while {[gets $chan line] >= 0} {
   #   gren_info "$line\n"
   #}
   #gren_info "-------------------------------------\n"

   return -code 0 [file join $bddconf(dirtmp) $::bdi_tools_priam::fileres]

}


#----------------------------------------------------------------------------
## Ecriture du fichier de commande pour priam
# @param nb int Nombre d'images a reduire
# @param polydeg int Degres du polynome de la reduction astrometrique
# @param use_refraction int Prise en compte ou non de la refraction dans la reduction astrometrique
# @param use_eop int Prise en compte ou non des EOP dans la reduction astrometrique
# @return void
proc ::bdi_tools_priam::create_cmdpriam {nb polydeg use_refraction use_eop} {

   global bddconf

   set arg_refrac "-norefraction"
   if {$use_refraction == 1} { set arg_refrac "" }

   set arg_eop "-noeop"
   if {$use_eop == 1} { set arg_eop "" }

   set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_priam::cmdpriam] w]
   puts $chan0 "#!/bin/sh"
   #puts $chan0 "LD_LIBRARY_PATH=$::bdi_tools_astrometry::locallib:$::bdi_tools_astrometry::ifortlib"
   puts $chan0 "LD_LIBRARY_PATH=$::bdi_tools_astrometry::locallib"
   puts $chan0 "export LD_LIBRARY_PATH"
   puts $chan0 "priam -lang en -ifmt priam -ofmt fichier:bddimages -m $nb -deg $polydeg $arg_refrac $arg_eop -te 1 \
                      -r $bddconf(dirtmp) -fc $::bdi_tools_priam::filecnd -fm $::bdi_tools_priam::filemes \
                      -fcat $::bdi_tools_priam::filecat -rcat $bddconf(dirtmp) -f $::bdi_tools_priam::fileres -map \
                      > [file join $bddconf(dirtmp) "priam.log"] 2>&1; echo $?"
   close $chan0

}


#----------------------------------------------------------------------------
## Ecriture du catalogue (local.cat) des corps celeste de reference astrometrique
# @param p_tabsources pointeur Tableau des sources de reference a ecrire dans le fichier
# @return void
proc ::bdi_tools_priam::create_localcat {p_tabsources} {

   upvar $p_tabsources tabsources
   global bddconf

   # Re-initialise le fichier
   set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_priam::filecat] w] 
   close $chan0

   # Ecriture des donnees de chaque sources dans le local.cat
   foreach {key s} [array get tabsources] {
      ::bdi_tools_priam::add_source2localcat $key $s
   }

}

#----------------------------------------------------------------------------
## Ecriture du catalogue (local.cat) des corps celeste de reference astrometrique
# @param p_tabsources pointeur Tableau des sources de reference a ecrire dans le fichier
# @return void
proc ::bdi_tools_priam::update_localcat {p_tabsources} {

   upvar $p_tabsources tabsources

   # Ecriture des donnees de chaque sources dans le local.cat
   foreach {key s} [array get tabsources] {
      ::bdi_tools_priam::add_source2localcat $key $s
   }

}


#----------------------------------------------------------------------------
## Insere une source dans le catalogue (local.cat) des corps celeste de reference astrometrique
# @param key string Cle designant la source
# @param onesource list Liste des donnees d'une source extraites d'un tabsources
# @return void
proc ::bdi_tools_priam::add_source2localcat {key onesource} {

   global bddconf

   # Nom du cata
   set cata [lindex $onesource 0]
   # Otherfields de la source s
   set otherfields [lindex $onesource 2]

   # Recupere les donnees a ecrire
   switch $cata {
      "IMG" {
         # Uniquement pour faire un wcs avec priam (cf creation cata - Manuel)
         set ra  [mc_angle2hms [lindex $otherfields 8]]
         set dec [mc_angle2dms [lindex $otherfields 9] 90]
         set mag        0
         set ra_err     10
         set dec_err    10
         set ra_pm      0
         set dec_pm     0
         set ra_pm_err  0
         set dec_pm_err 0
         set refepoch   2451545.50
         set typeS      "?"
         set paral      0
         set vitrad     0
         set skip 0
      }
      "UCAC2" {
         # 1 = ra_deg, 2 = dec_deg, 3 = U2Rmag_mag
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 3]
         # 4 = e_RAm_deg, 5 = e_DEm_deg
         set ra_err  [expr [lindex $otherfields 4] * 3600000]
         set dec_err [expr [lindex $otherfields 5] * 3600000]
         # 12 = pmRA_masperyear, 13 = pmDEC_masperyear
         set ra_pm  [expr [lindex $otherfields 12] / 15000.0]
         set dec_pm [expr [lindex $otherfields 13] / 1000.0]
         # 14 = e_pmRA_masperyear, 15 = e_pmDE_masperyear
         set ra_pm_err  [lindex $otherfields 14]
         set dec_pm_err [lindex $otherfields 15]
         # Autres champs non fournis par le catalogue
         set refepoch 2451545.50
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "UCAC3" {
         # 1 = ra_deg, 2 = dec_deg, 3 = im1_mag
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 3]
         # 8 = sigra_deg, 9 = sigdc_deg
         set ra_err  [expr [lindex $otherfields 8] * 3600000]
         set dec_err [expr [lindex $otherfields 9] * 3600000]
         # 16 = pmrac_masperyear, 17 = pmdc_masperyear
         set ra_pm  [expr [lindex $otherfields 16] / 15000.0]
         set dec_pm [expr [lindex $otherfields 17] / 1000.0]
         # 18 = sigpmr_masperyear, 19 = sigpmd_masperyear
         set ra_pm_err  [lindex $otherfields 18]
         set dec_pm_err [lindex $otherfields 19]
         # Autres champs non fournis par le catalogue
         set refepoch 2451545.50
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "UCAC4" {
         # 1 = ra_deg, 2 = dec_deg, 3 = im1_mag
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 3]
         # 8 = sigra_deg, 9 = sigdc_deg
         set ra_err  [expr [lindex $otherfields 8] * 3600000]
         set dec_err [expr [lindex $otherfields 9] * 3600000]
         # 15 = pmrac_masperyear, 16 = pmdc_masperyear
         set ra_pm  [expr [lindex $otherfields 15] / 15000.0]
         set dec_pm [expr [lindex $otherfields 16] / 1000.0]
         # 17 = sigpmr_masperyear, 18 = sigpmd_masperyear
         set ra_pm_err  [lindex $otherfields 17]
         set dec_pm_err [lindex $otherfields 18]
         # Autres champs non fournis par le catalogue
         set refepoch 2451545.50
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "TYCHO2" {
         # 5 = ra_deg, 6 = dec_deg, 22 = mag
         set ra  [mc_angle2hms [lindex $otherfields 5]]
         set dec [mc_angle2dms [lindex $otherfields 6] 90]
         set mag [lindex $otherfields 22]
         # 9 = e_mRA, 10 = e_mDE
         set ra_err  [lindex $otherfields 9]
         set dec_err [lindex $otherfields 10]
         # 7 = pmRA, 8 = pmDE
         set ra_pm  [expr [lindex $otherfields 7] / 15000.0]
         set dec_pm [expr [lindex $otherfields 8] / 1000.0]
         # 11 = e_pmRA, 12 = e_pmDE
         set ra_pm_err  [lindex $otherfields 11]
         set dec_pm_err [lindex $otherfields 12]
         # Autres champs non fournis par le catalogue
         set refepoch 2451545.50
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "USNOA2" {
         # 1 = ra_deg, 2 = dec_deg, 7 = magR
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 7]
         # Autres champs non fournis par le catalogue
         set refepoch 2451545.50
         set ra_pm 0
         set dec_pm 0
         set ra_err 500
         set dec_err 500
         set ra_pm_err  0
         set dec_pm_err 0
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "PPMX" {
         # 1 = RAJ2000, 2 = DECJ2000, 10 = Rmag
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 10]
         # 3 = errRa, 4 = errDec
         set ra_err  [expr [lindex $otherfields 3] * 3600000]
         set dec_err [expr [lindex $otherfields 4] * 3600000]
         # 5 = pmRA, 6 = pmDE
         set ra_pm  [expr [lindex $otherfields 5] / 15000.0]
         set dec_pm [expr [lindex $otherfields 6] / 1000.0]
         # 7 = errPmRa, 8 = errPmDec
         set ra_pm_err  [lindex $otherfields 7]
         set dec_pm_err [lindex $otherfields 8]
         # Autres champs non fournis par le catalogue
         set refepoch 2451545.50
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "PPMXL" {
         # 1 = RAJ2000, 2 = DECJ2000, 10 = Rmag
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 14]
         # 3 = errRa, 4 = errDec
         set ra_err  [expr [lindex $otherfields 3] * 3600000]
         set dec_err [expr [lindex $otherfields 4] * 3600000]
         # 5 = pmRA, 6 = pmDE
         set ra_pm  [expr [lindex $otherfields 5] / 15000.0]
         set dec_pm [expr [lindex $otherfields 6] / 1000.0]
         # 7 = errPmRa, 8 = errPmDec
         set ra_pm_err  [lindex $otherfields 7]
         set dec_pm_err [lindex $otherfields 8]
         # 9 = epochRa (year -> jd)
         set refepoch [lindex $otherfields 9]
         # Autres champs non fournis par le catalogue
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "2MASS" {
         # 1 = ra_deg, 2 = dec_deg, 10 = Rmag
         set ra  [mc_angle2hms [lindex $otherfields 1]]
         set dec [mc_angle2dms [lindex $otherfields 2] 90]
         set mag [lindex $otherfields 10]
         # 3 = err_ra, 4 = err_de
         set ra_err  [lindex $otherfields 3]
         set dec_err [lindex $otherfields 4]
         # 11 = jd
         set refepoch [lindex $otherfields 11]
         # Autres champs non fournis par le catalogue
         set ra_pm 0
         set dec_pm 0
         set ra_pm_err  0
         set dec_pm_err 0
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "NOMAD1" {
         # 2 = RAJ2000, 3 = DECJ2000, 7 = magR
         set ra  [mc_angle2hms [lindex $otherfields 2]]
         set dec [mc_angle2dms [lindex $otherfields 3] 90]
         set mag [lindex $otherfields 7]
         # 4 = errRa, 5 = errDe
         set ra_err  [lindex $otherfields 4]
         set dec_err [lindex $otherfields 5]
         # 6 = pmRA, 7 = pmDE
         set ra_pm  [expr [lindex $otherfields 6] / 15000.0]
         set dec_pm [expr [lindex $otherfields 7] / 1000.0]
         # 8 = errPmRa, 9 = errPmDec
         set ra_pm_err  [lindex $otherfields 8]
         set dec_pm_err [lindex $otherfields 9]
         # 10 = epochRa (year -> jd)
         set refepoch [lindex $otherfields 10]
         # Autres champs non fournis par le catalogue
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "WFIBC" {
         # 1 = ra_deg, 2 = dec_deg, 10 = magR
         set ra  [mc_angle2hms [lindex $otherfields 0]]
         set dec [mc_angle2dms [lindex $otherfields 1] 90]
         set mag [lindex $otherfields 9]
         # 3 = err_ra, 4 = err_de
         set ra_err  [expr [lindex $otherfields 2] * 1000.0]
         set dec_err [expr [lindex $otherfields 3] * 1000.0]
         # 11 = jd
         set refepoch [lindex $otherfields 4]
         # Autres champs non fournis par le catalogue
         set ra_pm  [expr [lindex $otherfields 5] / 15.0]
         if {[expr [lindex $otherfields 5] / 99.999] == 1} { set ra_pm 0.0 }
         set dec_pm [lindex $otherfields 6]
         if {[expr [lindex $otherfields 6] / 99.999] == 1} { set dec_pm 0.0 }
         set ra_pm_err 0.0
         set dec_pm_err 0.0
         set typeS "?"
         set paral 0
         set vitrad 0
         set skip 0
      }
      "GAIA1" {
         # 1 = ra_deg, 2 = dec_deg, 10 = magR
         set ra  [mc_angle2hms [lindex $otherfields 2]]
         set dec [mc_angle2dms [lindex $otherfields 4] 90]
         set mag [lindex $otherfields 16]
         # 3 = err_ra, 4 = err_de
         set ra_err  [expr [lindex $otherfields 3] * 1000.0]
         set dec_err [expr [lindex $otherfields 5] * 1000.0]
         # 11 = jd
         set refepoch [lindex $otherfields 1]
         # Autres champs non fournis par le catalogue
         set ra_pm 0.0
         if {[string length [string trim [lindex $otherfields 8]]] > 1} { 
            set ra_pm [expr [lindex $otherfields 8] / 15.0 / 1000.0]
         }
         set dec_pm 0.0
         if {[string length [string trim [lindex $otherfields 10]]] > 1} { 
            set dec_pm [expr [lindex $otherfields 10] / 1000.0] 
         }
         set ra_pm_err 0.0
         if {[string length [string trim [lindex $otherfields 9]]] > 1} { 
            set ra_pm_err [expr [lindex $otherfields 9] / 15.0]
         }
         set dec_pm_err 0.0
         if {[string length [string trim [lindex $otherfields 11]]] > 1} { 
            set dec_pm_err [lindex $otherfields 11] 
         }
         set typeS "?"
         set paral 0.0
         if {[string length [string trim [lindex $otherfields 6]]] > 1} { 
            set paral [lindex $otherfields 6] 
         }
         set vitrad 0
         set skip 0
      }
      default {
         set skip 1
      }
   }

   # Ecriture de la source
   if {$skip == 0} {
      set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_priam::filecat] a] 
      puts $chan0 "$key $ra $dec $ra_pm $dec_pm $refepoch $ra_err $dec_err $ra_pm_err $dec_pm_err $mag $typeS $paral $vitrad"
      close $chan0
   }

}


#----------------------------------------------------------------------------
## Ecriture du fichier des objets scientifiques et de reference astrometrique
# @return void
proc ::bdi_tools_priam::create_sciencemes { } {

   global bddconf

   set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_priam::filemes] w] 
   puts $chan0 "#? Centroid measures formatted for Priam"
   puts $chan0 "#? Source: ASTROID from bddimages"
   puts $chan0 "#? Object: Science"
   puts $chan0 "#"
   puts $chan0 "#> orientation: $::bdi_tools_astrometry::orient"
   puts $chan0 "#"
   close $chan0

}


#----------------------------------------------------------------------------
## Ecriture du fichier des objets scientifiques et de reference astrometrique
# @param p_img pointeur Structure decrivant une image
# @param p_tabsources pointeur Tableau des sources de reference et de science d'une image a ecrire dans le fichier
# @return void
proc ::bdi_tools_priam::add_newsciencemes {p_img p_tabsources} {

   upvar $p_img img
   upvar $p_tabsources tabsources
   global bddconf

   set imagefilename [::bddimages_liste::lget $img "filename"]
   set tabkey [::bddimages_liste::lget $img "tabkey"]

   set midexpo 0
   set exposure [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"] 1]]
   if {$exposure != -1} { set midexpo [expr ($exposure/2.0) / 86400.0] }
   set dateobsjd [expr [::bddimages_liste::lget $img "commundatejj"] + $midexpo]

   set temperature 20.00
   set humidity 35.0
   set pression 1013.500
   set bandwith 0.57000

   if {$::bdi_tools_astrometry::cndobs_from_header == 0} {
      set temperature $::bdi_tools_astrometry::tempair
      set pression    $::bdi_tools_astrometry::airpress
      set humidity    $::bdi_tools_astrometry::hydro
      set bandwidth   $::bdi_tools_astrometry::bandwidth
   } else {
      if {[::bddimages_liste::lexist $tabkey "TEMP"] == 1} {
         set temperature [lindex [::bddimages_liste::lget $tabkey "TEMP"] 1] 
      }
      if {[::bddimages_liste::lexist $tabkey "HUMIDITY"] == 1} {
         set humidity [lindex [::bddimages_liste::lget $tabkey "HUMIDITY"] 1 ]
      }
      if {[::bddimages_liste::lexist $tabkey "PRESSURE"] == 1} {
         set pression [lindex [::bddimages_liste::lget $tabkey "PRESSURE"] 1 ]
      }
      if {[::bddimages_liste::lexist $tabkey "BANDWID"] == 1} {
         set bandwith [lindex [::bddimages_liste::lget $tabkey "BANDWID"] 1 ]
      }
   }

   set err [catch {set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_priam::filemes] a]} msg]

   # Entete de la nouvelle image
   puts $chan0 "!$imagefilename"
   puts $chan0 "$dateobsjd $temperature $pression $humidity $bandwith"
   # Ecrit chaque sources ...
   foreach {key s} [array get tabsources] {
      # flagastrom
      set ar [lindex $s 0]
      # Otherfields de la source s
      set otherfields [lindex $s 2]
      # Champs requis
      set xsm     [lindex $otherfields 0]
      set ysm     [lindex $otherfields 1]
      set err_xsm [lindex $otherfields 2]
      set err_ysm [lindex $otherfields 3]
      set fwhmx   [lindex $otherfields 4]
      set fwhmy   [lindex $otherfields 5]
      set flux    [lindex $otherfields 7]
      if {$err_xsm==""||$err_xsm=="-"||$err_xsm=="-1"||$err_xsm eq "nan"||$err_xsm eq "-nan"} {set err_xsm 0.1}
      if {$err_ysm==""||$err_ysm=="-"||$err_ysm=="-1"||$err_ysm eq "nan"||$err_ysm eq "-nan"} {set err_ysm 0.1}
      if {$err_xsm<0.001} {set err_xsm 0.001}
      if {$err_ysm<0.001} {set err_ysm 0.001}
      
      if {$flux==""} {set flux 0}
      # Ecriture de la source -> science.mes
      puts $chan0 "$ar $xsm $err_xsm $ysm $err_ysm $fwhmx $fwhmy $flux $key"
   }
   close $chan0

}


#----------------------------------------------------------------------------
## Ecriture du fichier cnd.obs decrivant les conditions observationnelles
# @param p_img pointeur Structure decrivant une image
# @return void
proc ::bdi_tools_priam::create_cndobs {p_img} {

   upvar $p_img img
   global bddconf

   set imagefilename [::bddimages_liste::lget $img "filename"]
   set tabkey [::bddimages_liste::lget $img "tabkey"]

   if {[::bddimages_liste::lexist $tabkey "OBS-LAT"] == 0} {
      set obslat 0.0
   } else {
      set obslat [lindex [::bddimages_liste::lget $tabkey "OBS-LAT"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "OBS-LONG"] == 0} {
      set obslong 0.0
   } else {
      set obslong [expr -1.0 * [lindex [::bddimages_liste::lget $tabkey "OBS-LONG"] 1 ] / 15.0]
   }

   if {[::bddimages_liste::lexist $tabkey "OBS-ELEV"] == 0} {
      set obselev 0.0
   } else {
      set obselev [lindex [::bddimages_liste::lget $tabkey "OBS-ELEV"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "TELESCOP"] == 0} {
      set telescop 0.0
   } else {
      set telescop [lindex [::bddimages_liste::lget $tabkey "TELESCOP"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "FOCLEN"] == 0} {
      set foclen 1.0
   } else {
      set foclen [lindex [::bddimages_liste::lget $tabkey "FOCLEN"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "APERTURE"] == 0} {
      set aperture 1.0
   } else {
      set aperture [lindex [::bddimages_liste::lget $tabkey "APERTURE"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "NAXIS1"] == 0} {
      set naxis1 1024
   } else {
      set naxis1 [lindex [::bddimages_liste::lget $tabkey "NAXIS1"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "NAXIS2"] == 0} {
      set naxis2 1024
   } else {
      set naxis2 [lindex [::bddimages_liste::lget $tabkey "NAXIS2"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "CROTA1"] == 0} {
      set crota1 0
   } else {
      set crota1 [lindex [::bddimages_liste::lget $tabkey "CROTA1"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "CROTA2"] == 0} {
      set crota2 0
   } else {
      set crota2 [lindex [::bddimages_liste::lget $tabkey "CROTA2"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "CDELT1"] == 0} {
      set cdelt1 1.0
   } else {
      set cdelt1 [lindex [::bddimages_liste::lget $tabkey "CDELT1"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "CDELT2"] == 0} {
      set cdelt2 1.0
   } else {
      set cdelt2 [lindex [::bddimages_liste::lget $tabkey "CDELT2"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "PIXSIZE1"] == 0} {
      set pixsize1 0.0
   } else {
      set pixsize1 [lindex [::bddimages_liste::lget $tabkey "PIXSIZE1"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "PIXSIZE2"] == 0} {
      set pixsize2 0.0
   } else {
      set pixsize2 [lindex [::bddimages_liste::lget $tabkey "PIXSIZE2"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "SITENAME"] == 0} {
      set sitename ""
   } else {
      set sitename [lindex [::bddimages_liste::lget $tabkey "SITENAME"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "OBSERVER"] == 0} {
      set observer ""
   } else {
      set observer [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "IAU_CODE"] == 0} {
      set iau_code ""
   } else {
      set iau_code [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1 ]
   }

   if {[::bddimages_liste::lexist $tabkey "OBJECT"] == 0} {
      set object ""
   } else {
      set object [lindex [::bddimages_liste::lget $tabkey "OBJECT"] 1 ]
   }
   if {[::bddimages_liste::lexist $tabkey "DATE-OBS"] == 0} {
      set dateobs ""
   } else {
      set dateobs [lindex [::bddimages_liste::lget $tabkey "DATE-OBS"] 1 ]
   }

   set echelle [expr sqrt((pow($cdelt1,2)+pow($cdelt2,2))/2.0)*3600.0]
   
   # Si le code UAI est defini
   if {$iau_code != ""} {
      set obslong 0.0 
      set obslat 0.0 
      set obselev 0.0
   }

   # creation du fichier de conditions initiales (cnd.obs)
   set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_priam::filecnd] w]
   puts $chan0 "#? Centroid measures formatted for Priam"
   puts $chan0 "# Observational conditions"
   puts $chan0 "# object : astrometry of $object from $telescop $sitename"
   puts $chan0 "# date   : $dateobs"
   puts $chan0 "#"
   puts $chan0 "code           : $iau_code"
   puts $chan0 "lieu           : $sitename"
   puts $chan0 "station        : $obslong $obslat $obselev"
   puts $chan0 "observateurs   : $observer"
   puts $chan0 "reduction      : F. Vachier & J. Berthier"
   puts $chan0 "#"
   puts $chan0 "# Instrument"
   puts $chan0 "#"
   puts $chan0 "type           : $telescop"
   puts $chan0 "focale         : $foclen"
   puts $chan0 "diametre       : $aperture"
   puts $chan0 "echelle        : $echelle"
   puts $chan0 "orientation    : $crota2"
   puts $chan0 "taille CCD     : $naxis1 $naxis2"
   puts $chan0 "pixsize        : $pixsize1 $pixsize2"
   close $chan0

}
