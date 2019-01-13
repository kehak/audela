## @file bdi_tools_astrometry.tcl
#  @brief     Outils des m&eacute;thodes de r&eacute;duction astrom&eacute;triquee des images
#  @author    Frederic Vachier & Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_astrometry.tcl]
#  @endcode

# $Id: bdi_tools_astrometry.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_astrometry
# @brief Outils des m&eacute;thodes de r&eacute;duction astrom&eacute;triquee des images
# @warning Outil en d&eacute;veloppement
# @todo Sauver les infos MPC dans le header de l'image
#
namespace eval ::bdi_tools_astrometry {

   variable science
   variable reference

   variable threshold
   variable delta
   variable imagelimit

   # @var Orientation de l'image (e.g. wn)
   variable orient
   # @var Degres du polynome pour la reduction astrometrique
   variable polydeg
   # @var Prise en compte ou non de la refraction dans la reduction astrometrique
   variable use_refraction
   # @var Prise en compte ou non des EOP dans la reduction astrometrique
   variable use_eop
   # @var Prise en compte ou non du debiaisage des positions astrometriques mesurees (Farnocchia et al, Icarus 245, 2015)
   variable use_debias
   # @var Nom du fichier contenant les positions a debiaiser
   variable fileposdebias debias.pos
   # @var Nom du fichier contenant les resultats de l'appel au debiasage
   variable fileresdebias debias.pos.res
   # @var Nom du fichier contenant l'appel au debiasage
   variable filecmddebias cmd.debias
   # @var Valeur du mot cle BDI ASTROMETRY
   variable update_bdi_astrom_key
   # @var Utilisation des conditions d'observation depuis le header de l'image (1) ou depuis des cstes (0)
   variable cndobs_from_header
   # @var cnd obs: temperature en degre C
   variable tempair
   # @var cnd obs: pression atmospherique en hPa
   variable airpress
   # @var cnd obs: humidity en %
   variable hydro
   # @var cnd obs: longueur d'onde de l'observation en micron-metre
   variable bandwidth
   # @var Chemin vers la librairie ifort (e.g. /opt/ifort/lib/intel64)
   variable ifortlib
   # @var Chemin vers la librairie local de l'utilisateur (e.g. /usr/local/lib)
   variable locallib
   # @var Utilisation ou non (0|1) des ephemerides IMCCE (eproc.ephemcc)
   variable use_ephem_imcce
   variable imcce_ephemcc
   variable ephemcc_options
   array set ephem_imcce {}

   # @var Utilisation ou non (0|1) des ephemerides JPL
   variable use_ephem_jpl
   array set ephem_jpl {}

   variable rapport_uai_code
   variable rapport_uai_location
   variable rapport_rapporteur
   variable rapport_adresse
   variable rapport_mail
   variable rapport_observ
   variable rapport_reduc
   variable rapport_instru
   variable rapport_cata

}

#----------------------------------------------------------------------------
# CONFIG
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Initialisation des variables de namespace
# @details Si la variable n'existe pas alors on va chercher dans la variable globale \c conf
# @return void
proc ::bdi_tools_astrometry::inittoconf { } {

   global conf

   set ::bdi_tools_astrometry::science "SKYBOT"
   set ::bdi_tools_astrometry::reference "UCAC2"
   set ::bdi_tools_astrometry::ephemcc_options ""

   if {! [info exists ::bdi_tools_astrometry::orient] } {
      if {[info exists conf(bddimages,astrometry,orient)]} {
         set ::bdi_tools_astrometry::orient $conf(bddimages,astrometry,orient)
      } else {
         set ::bdi_tools_astrometry::orient "wn"
      }
   }
   if {! [info exists ::bdi_tools_astrometry::polydeg] } {
      if {[info exists conf(bddimages,astrometry,polydeg)]} {
         set ::bdi_tools_astrometry::polydeg $conf(bddimages,astrometry,polydeg)
      } else {
         set ::bdi_tools_astrometry::polydeg 0
      }
   }
   if {! [info exists ::bdi_tools_astrometry::use_refraction] } {
      if {[info exists conf(bddimages,astrometry,use_refraction)]} {
         set ::bdi_tools_astrometry::use_refraction $conf(bddimages,astrometry,use_refraction)
      } else {
         set ::bdi_tools_astrometry::use_refraction 1
      }
   }
   if {! [info exists ::bdi_tools_astrometry::use_eop] } {
      if {[info exists conf(bddimages,astrometry,use_eop)]} {
         set ::bdi_tools_astrometry::use_eop $conf(bddimages,astrometry,use_eop)
      } else {
         set ::bdi_tools_astrometry::use_eop 0
      }
   }
   if {! [info exists ::bdi_tools_astrometry::use_debias] } {
      if {[info exists conf(bddimages,astrometry,use_debias)]} {
         set ::bdi_tools_astrometry::use_debias $conf(bddimages,astrometry,use_debias)
      } else {
         set ::bdi_tools_astrometry::use_debias 0
      }
   }
   if {! [info exists ::bdi_tools_astrometry::update_bdi_astrom_key] } {
      if {[info exists conf(bddimages,astrometry,update_bdi_astrom_key)]} {
         set ::bdi_tools_astrometry::update_bdi_astrom_key $conf(bddimages,astrometry,update_bdi_astrom_key)
      } else {
         set ::bdi_tools_astrometry::update_bdi_astrom_key 1
      }
   }
   if {! [info exists ::bdi_tools_astrometry::cndobs_from_header] } {
      if {[info exists conf(bddimages,astrometry,cndobs_from_header)]} {
         set ::bdi_tools_astrometry::cndobs_from_header $conf(bddimages,astrometry,cndobs_from_header)
      } else {
         set ::bdi_tools_astrometry::cndobs_from_header 1
      }
   }
   if {! [info exists ::bdi_tools_astrometry::tempair] } {
      if {[info exists conf(bddimages,astrometry,tempair)]} {
         set ::bdi_tools_astrometry::tempair $conf(bddimages,astrometry,tempair)
      } else {
         set ::bdi_tools_astrometry::tempair 20.00
      }
   }
   if {! [info exists ::bdi_tools_astrometry::airpress] } {
      if {[info exists conf(bddimages,astrometry,airpress)]} {
         set ::bdi_tools_astrometry::airpress $conf(bddimages,astrometry,airpress)
      } else {
         set ::bdi_tools_astrometry::airpress 1013.500
      }
   }
   if {! [info exists ::bdi_tools_astrometry::hydro] } {
      if {[info exists conf(bddimages,astrometry,hydro)]} {
         set ::bdi_tools_astrometry::hydro $conf(bddimages,astrometry,hydro)
      } else {
         set ::bdi_tools_astrometry::hydro 35.00
      }
   }
   if {! [info exists ::bdi_tools_astrometry::bandwidth] } {
      if {[info exists conf(bddimages,astrometry,bandwidth)]} {
         set ::bdi_tools_astrometry::bandwidth $conf(bddimages,astrometry,bandwidth)
      } else {
         set ::bdi_tools_astrometry::bandwidth 0.570
      }
   }
   if {! [info exists ::bdi_tools_astrometry::ifortlib] } {
      if {[info exists conf(bddimages,astrometry,ifortlib)]} {
         set ::bdi_tools_astrometry::ifortlib $conf(bddimages,astrometry,ifortlib)
      } else {
         set ::bdi_tools_astrometry::ifortlib "/opt/intel/lib/intel64"
      }
   }
   if {! [info exists ::bdi_tools_astrometry::locallib] } {
      if {[info exists conf(bddimages,astrometry,locallib)]} {
         set ::bdi_tools_astrometry::locallib $conf(bddimages,astrometry,locallib)
      } else {
         set ::bdi_tools_astrometry::locallib "/usr/local/lib"
      }
   }
   if {! [info exists ::bdi_tools_astrometry::use_ephem_imcce] } {
      if {[info exists conf(bddimages,astrometry,use_ephem_imcce)]} {
         set ::bdi_tools_astrometry::use_ephem_imcce $conf(bddimages,astrometry,use_ephem_imcce)
      } else {
         set ::bdi_tools_astrometry::use_ephem_imcce 1
      }
   }
   if {! [info exists ::bdi_tools_astrometry::imcce_ephemcc] } {
      if {[info exists conf(bddimages,astrometry,imcce_ephemcc)]} {
         set ::bdi_tools_astrometry::imcce_ephemcc $conf(bddimages,astrometry,imcce_ephemcc)
      } else {
         set ::bdi_tools_astrometry::imcce_ephemcc "/usr/local/bin/ephemcc"
      }
   }
   if {! [info exists ::bdi_tools_astrometry::use_ephem_jpl] } {
      if {[info exists conf(bddimages,astrometry,use_ephem_jpl)]} {
         set ::bdi_tools_astrometry::use_ephem_jpl $conf(bddimages,astrometry,use_ephem_jpl)
      } else {
         set ::bdi_tools_astrometry::use_ephem_jpl 0
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_uai_code] } {
      if {[info exists conf(bddimages,astrometry,rapport,uai_code)]} {
         set ::bdi_tools_astrometry::rapport_uai_code $conf(bddimages,astrometry,rapport,uai_code)
      } else {
         set ::bdi_tools_astrometry::rapport_uai_code ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_uai_location] } {
      if {[info exists conf(bddimages,astrometry,rapport,uai_location)]} {
         set ::bdi_tools_astrometry::rapport_uai_location $conf(bddimages,astrometry,rapport,uai_location)
      } else {
         set ::bdi_tools_astrometry::rapport_uai_location ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_rapporteur] } {
      if {[info exists conf(bddimages,astrometry,rapport,rapporteur)]} {
         set ::bdi_tools_astrometry::rapport_rapporteur $conf(bddimages,astrometry,rapport,rapporteur)
      } else {
         set ::bdi_tools_astrometry::rapport_rapporteur ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_adresse] } {
      if {[info exists conf(bddimages,astrometry,rapport,adresse)]} {
         set ::bdi_tools_astrometry::rapport_adresse $conf(bddimages,astrometry,rapport,adresse)
      } else {
         set ::bdi_tools_astrometry::rapport_adresse ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_mail] } {
      if {[info exists conf(bddimages,astrometry,rapport,mail)]} {
         set ::bdi_tools_astrometry::rapport_mail $conf(bddimages,astrometry,rapport,mail)
      } else {
         set ::bdi_tools_astrometry::rapport_mail ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_observ] } {
      if {[info exists conf(bddimages,astrometry,rapport,observ)]} {
         set ::bdi_tools_astrometry::rapport_observ $conf(bddimages,astrometry,rapport,observ)
      } else {
         set ::bdi_tools_astrometry::rapport_observ ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_reduc] } {
      if {[info exists conf(bddimages,astrometry,rapport,reduc)]} {
         set ::bdi_tools_astrometry::rapport_reduc $conf(bddimages,astrometry,rapport,reduc)
      } else {
         set ::bdi_tools_astrometry::rapport_reduc ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_instru] } {
      if {[info exists conf(bddimages,astrometry,rapport,instru)]} {
         set ::bdi_tools_astrometry::rapport_instru $conf(bddimages,astrometry,rapport,instru)
      } else {
         set ::bdi_tools_astrometry::rapport_instru ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_cata] } {
      if {[info exists conf(bddimages,astrometry,rapport,cata)]} {
         set ::bdi_tools_astrometry::rapport_cata $conf(bddimages,astrometry,rapport,cata)
      } else {
         set ::bdi_tools_astrometry::rapport_cata ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_mpc_dir] } {
      if {[info exists conf(bddimages,astrometry,rapport,mpc_dir)]} {
         set ::bdi_tools_astrometry::rapport_mpc_dir $conf(bddimages,astrometry,rapport,mpc_dir)
      } else {
         set ::bdi_tools_astrometry::rapport_mpc_dir ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_imc_dir] } {
      if {[info exists conf(bddimages,astrometry,rapport,imc_dir)]} {
         set ::bdi_tools_astrometry::rapport_imc_dir $conf(bddimages,astrometry,rapport,imc_dir)
      } else {
         set ::bdi_tools_astrometry::rapport_imc_dir ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::rapport_xml_dir] } {
      if {[info exists conf(bddimages,astrometry,rapport,xml_dir)]} {
         set ::bdi_tools_astrometry::rapport_xml_dir $conf(bddimages,astrometry,rapport,xml_dir)
      } else {
         set ::bdi_tools_astrometry::rapport_xml_dir ""
      }
   }

   if {[info exists conf(bddimages,astrometry,reports,mail)]} {
      set ::bdi_tools_astrometry::rapport_desti $conf(bddimages,astrometry,reports,mail)
   } else {
      set ::bdi_tools_astrometry::rapport_desti ""
   }

   set ::bdi_tools_astrometry::rapport_mpc_submit 0
}

#----------------------------------------------------------------------------
## Sauvegarde des variables de namespace
# @return void
#
proc ::bdi_tools_astrometry::closetoconf {  } {

   global conf
   set conf(bddimages,astrometry,orient)                $::bdi_tools_astrometry::orient
   set conf(bddimages,astrometry,polydeg)               $::bdi_tools_astrometry::polydeg
   set conf(bddimages,astrometry,use_refraction)        $::bdi_tools_astrometry::use_refraction
   set conf(bddimages,astrometry,use_eop)               $::bdi_tools_astrometry::use_eop
   set conf(bddimages,astrometry,use_debias)            $::bdi_tools_astrometry::use_debias
   set conf(bddimages,astrometry,update_bdi_astrom_key) $::bdi_tools_astrometry::update_bdi_astrom_key
   set conf(bddimages,astrometry,cndobs_from_header)    $::bdi_tools_astrometry::cndobs_from_header
   set conf(bddimages,astrometry,tempair)               $::bdi_tools_astrometry::tempair
   set conf(bddimages,astrometry,airpress)              $::bdi_tools_astrometry::airpress
   set conf(bddimages,astrometry,hydro)                 $::bdi_tools_astrometry::hydro
   set conf(bddimages,astrometry,bandwidth)             $::bdi_tools_astrometry::bandwidth
   set conf(bddimages,astrometry,ifortlib)              $::bdi_tools_astrometry::ifortlib
   set conf(bddimages,astrometry,locallib)              $::bdi_tools_astrometry::locallib
   set conf(bddimages,astrometry,use_ephem_imcce)       $::bdi_tools_astrometry::use_ephem_imcce
   set conf(bddimages,astrometry,imcce_ephemcc)         $::bdi_tools_astrometry::imcce_ephemcc
   set conf(bddimages,astrometry,use_ephem_jpl)         $::bdi_tools_astrometry::use_ephem_jpl
   set conf(bddimages,astrometry,rapport,uai_code)      $::bdi_tools_astrometry::rapport_uai_code
   set conf(bddimages,astrometry,rapport,uai_location)  $::bdi_tools_astrometry::rapport_uai_location
   set conf(bddimages,astrometry,rapport,rapporteur)    $::bdi_tools_astrometry::rapport_rapporteur
   set conf(bddimages,astrometry,rapport,adresse)       $::bdi_tools_astrometry::rapport_adresse
   set conf(bddimages,astrometry,rapport,mail)          $::bdi_tools_astrometry::rapport_mail
   set conf(bddimages,astrometry,rapport,observ)        $::bdi_tools_astrometry::rapport_observ
   set conf(bddimages,astrometry,rapport,reduc)         $::bdi_tools_astrometry::rapport_reduc
   set conf(bddimages,astrometry,rapport,instru)        $::bdi_tools_astrometry::rapport_instru
   set conf(bddimages,astrometry,rapport,cata)          $::bdi_tools_astrometry::rapport_cata
   set conf(bddimages,astrometry,rapport,mpc_dir)       $::bdi_tools_astrometry::rapport_mpc_dir
   set conf(bddimages,astrometry,rapport,imc_dir)       $::bdi_tools_astrometry::rapport_imc_dir
   set conf(bddimages,astrometry,rapport,xml_dir)       $::bdi_tools_astrometry::rapport_xml_dir

}


#----------------------------------------------------------------------------
# SETTER
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Defini les champs astrometriques d'une image
# @param p_astrom pointeur vers le tableau des champs astrometriques: astrom(kwds,units,types,comments)
# @return void
#
proc ::bdi_tools_astrometry::set_fields_astrom { p_astrom } {

   upvar $p_astrom astrom

   set astrom(kwds)     {RA       DEC       CRPIX1      CRPIX2      CRVAL1       CRVAL2       CDELT1      CDELT2      CROTA1    CROTA2      CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN       PIXSIZE1       PIXSIZE2        CATA_PVALUE        EQUINOX       CTYPE1        CTYPE2      LONPOLE                                        CUNIT1                       CUNIT2                       }
   set astrom(units)    {deg      deg       pixel       pixel       deg          deg          deg/pixel   deg/pixel   deg       deg         deg/pixel     deg/pixel     deg/pixel     deg/pixel     m            mum            mum             percent            no            no            no          deg                                            no                           no                           }
   set astrom(types)    {double   double    double      double      double       double       double      double      double    double      double        double        double        double        double       double         double          double             string        string        string      double                                         string                       string                       }
   set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Rotation of coordinate" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included" "Pvalue of astrometric reduction" "System of equatorial coordinates" "Gnomonic projection" "Gnomonic projection" "Long. of the celest.NP in native coor.syst."  "Angles are degrees always"  "Angles are degrees always"  }
   return

}


#----------------------------------------------------------------------------
##
# @return yyy
# Structure ASTROID:
#   "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux"
#   "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff"
#   "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name"
#   "flagastrom" "flagphotom" "cataastrom" "cataphotom"
# @todo définir le brief et les param
proc ::bdi_tools_astrometry::set_astrom_to_source { s ra dec res_ra res_dec omc_ra omc_dec name} {

   set pass "no"

   set stmp {}
   foreach cata $s {
      if {[lindex $cata 0] == "ASTROID"} {
         set pass "yes"
         set astroid [lindex $cata 2]
         set astroid [lreplace $astroid 16 21 $ra $dec $res_ra $res_dec $omc_ra $omc_dec]
         set astroid [lreplace $astroid 24 24 $name]
         lappend stmp [list "ASTROID" {} $astroid]
      } else {
         lappend stmp $cata
      }
   }
   return $stmp

}


#----------------------------------------------------------------------------
# GETTER
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Retourne la liste des objets science a partir du tableau \::bdi_tools_astrometry::listscience
# @return liste des objets science
#
proc ::bdi_tools_astrometry::get_object_list { } {

   set object_list ""
   foreach {name y} [array get ::bdi_tools_astrometry::listscience] {
      lappend object_list $name
   }

   return $object_list

}


#----------------------------------------------------------------------------
# ASTROMETRIE
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Astrometrie: Initialisations de Priam
# @details Creation des fichiers de donnees necessaires a la reduction astrometrique avec eproc.priam
# @return void
proc ::bdi_tools_astrometry::init_priam { } {

   global bddconf

   # Premiere image comme modele
   set firstimg [lindex $::tools_cata::img_list 0]
   # Creation du fichier de conditions observationnelles: cnd.obs
   ::bdi_tools_priam::create_cndobs firstimg

   # Recupere les sources de reference
   array unset tabsources_ref
   ::manage_source::extract_tabsources_by_flagastrom "R" tabsources_ref
   # Creation du catalogue local: local.cat
   ::bdi_tools_priam::create_localcat tabsources_ref

   # Recupere les sources science pour ajouter les etoiles dans le local.cat
   array unset tabsources_sci
   ::manage_source::extract_tabsources_by_flagastrom "S" tabsources_sci
   # Maj du catalogue local: local.cat
   ::bdi_tools_priam::update_localcat tabsources_sci

   # Creation du fichier de mesures: science.mes
   ::bdi_tools_priam::create_sciencemes

   # Creation de chaque bloc de science+ref pour chaque image
   set id_current_image 0
   array unset tabsources_img
   foreach current_image $::tools_cata::img_list {
      incr id_current_image
      ::manage_source::extract_tabsources_by_idimg $id_current_image tabsources_img
      ::bdi_tools_priam::add_newsciencemes current_image tabsources_img
   }

   # Creation du fichier de commande Priam: cmd.priam
   ::bdi_tools_priam::create_cmdpriam [llength $::tools_cata::img_list] $::bdi_tools_astrometry::polydeg \
                                                                        $::bdi_tools_astrometry::use_refraction \
                                                                        $::bdi_tools_astrometry::use_eop

}


#----------------------------------------------------------------------------
## Astrometrie: Execution de Priam
# @details Creation des fichiers de donnees necessaires a la reduction astrometrique
#          realisee avec eproc.priam
# @return void
proc ::bdi_tools_astrometry::exec_priam { } {

   # Exec priam
   set ::bdi_tools_astrometry::last_results_file [::bdi_tools_priam::launch_priam]
   ::bdi_tools_astrometry::extract_priam_results $::bdi_tools_astrometry::last_results_file

   ## Rotate the name of the result file
   #set newfile "[file rootname $::bdi_tools_astrometry::last_results_file].last"
   #::bdi_tools_astrometry::rotate_results_file $::bdi_tools_astrometry::last_results_file $newfile
   #set ::bdi_tools_astrometry::last_results_file $newfile

}



#----------------------------------------------------------------------------
## Astrometrie: Renommage du fichier resultat de Priam
# @param file string Nom du fichier contenant les resultats generes par Priam
# @return void
proc ::bdi_tools_astrometry::rotate_results_file { file newfile } {

   file rename -force -- $file $newfile

}



#----------------------------------------------------------------------------
## Astrometrie: Extraction des resultats astrometriques obtenus avec Priam
# @param file string Nom du fichier contenant les resultats generes par Priam
# @return void
proc ::bdi_tools_astrometry::extract_priam_results { file } {

   set chan [open $file r]

   ::bdi_tools_astrometry::set_fields_astrom astrom
   set n [llength $astrom(kwds)]
   set id_current_image 0
   set nberr 0

   # Lecture du fichier en continue

   while {[gets $chan line] >= 0} {

      set a [split $line "="]
      set key [lindex $a 0]
      set val [lindex $a 1]

      if {$key == "BEGIN"} {

         # Lecture 1ere ligne => nom de l'image
         set filename $val
         incr id_current_image
         set catascience($id_current_image) ""
         set cataref($id_current_image) ""
         set ::tools_cata::new_astrometry($id_current_image) ""

         # Lecture de la 2e ligne => SUCCESS ou FAILED
         gets $chan success
         if {$success != "SUCCESS"} {
            incr nberr
            gren_info "ASTROMETRY FAILED: $file\n"
            continue
         }

      }

      if {$key == "END"} {
         continue
      }

      for {set k 0 } { $k<$n } {incr k} {
         set kwd [lindex $astrom(kwds) $k]
         if {$kwd == $key} {
            set type [lindex $astrom(types) $k]
            set unit [lindex $astrom(units) $k]
            set comment [lindex $astrom(comments) $k]
            # gren_info "KWD: $key \n"
            # buf$::audace(bufNo) setkwd [list $kwd $val $type $unit $comment]
            # TODO ::bdi_tools_astrometry::extract_priam_results :: Modif du tabkey de chaque image de img_list
            foreach kk [list FOCLEN RA DEC CRVAL1 CRVAL2 CROTA1 CROTA2 ] {
               if {$kk == $key } {
                  set val [format "%.10f" $val]
               }
            }
            foreach kk [list CDELT1 CDELT2 CD1_1 CD1_2 CD2_1 CD2_2 ] {
               if {$kk == $key } {
                  set val [format "%.10e" $val]
               }
            }
            foreach kk [list CRPIX1 CRPIX2] {
               if {$kk == $key } {
                  set val [format "%.3f" $val]
               }
            }
            if {$val != ""} {
               lappend ::tools_cata::new_astrometry($id_current_image) [list $kwd $val $type $unit $comment]
            }
         }
      }

      if {$key == "CATA_VALUES"} {
         set name  [lindex $val 0]
         set sour  [lindex $val 1]
         lappend catascience($id_current_image) [list $name $sour]
      }

      if {$key == "CATA_REF"} {
         set name  [lindex $val 0]
         set sour  [lindex $val 1]
         lappend cataref($id_current_image) [list $name $sour]
      }

   }
   close $chan

   if {$id_current_image == $nberr} {
      return -code 1 "ASTROMETRY FAILURE: no valid result provided by Priam"
   }

   # Insertion des resultats dans cata_list

   #  fieldsastroid [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "flux" "err_flux" "pixmax" \
   #                      "intensity" "sky" "err_sky" "snint" "radius" "rdiff" "err_psf" "psf_method" "globale" "ra" "dec" \
   #                      "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name" "flagastrom" "flagphotom" \
   #                      "cataastrom" "cataphotom"]

   set id_current_image 0

   foreach current_image $::tools_cata::img_list {

      incr id_current_image

      set ex [::bddimages_liste::lexist $current_image "listsources"]
      if {$ex != 0} {
         gren_erreur "Attention listsources existe dans img_list et ce n'est plus necessaire\n"
      }

      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)
      set fields [lindex $current_listsources 0]
      set sources [lindex $current_listsources 1]
      set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]

      foreach l $list_id_science {
         set id     [lindex $l 0]
         set idcata [lindex $l 1]
         set ar     [lindex $l 2]
         set ac     [lindex $l 3]
         set name   [lindex $l 4]

         set x [lsearch -index 0 $catascience($id_current_image) $name]
         if {$x >= 0} {
            set data [lindex [lindex $catascience($id_current_image) $x] 1]
            set ra      [lindex $data 0]
            set dec     [lindex $data 1]
            set res_ra  [lindex $data 2]
            set res_dec [lindex $data 3]
            set s [lindex $sources $id]
            set omc_ra  ""
            set omc_dec ""

            set x [lsearch -index 0 $s $ac]
            if {$x >= 0} {
               set cata [lindex $s $x]
               set omc_ra  [expr ($ra  - [lindex [lindex $cata 1] 0])*3600.0]
               set omc_dec [expr ($dec - [lindex [lindex $cata 1] 1])*3600.0]
            }

            set astroid [lindex $s $idcata]
            set othf [lindex $astroid 2]

            ::bdi_tools_psf::set_by_key othf "ra"      $ra
            ::bdi_tools_psf::set_by_key othf "dec"     $dec
            ::bdi_tools_psf::set_by_key othf "res_ra"  $res_ra
            ::bdi_tools_psf::set_by_key othf "res_dec" $res_dec
            ::bdi_tools_psf::set_by_key othf "omc_ra"  $omc_ra
            ::bdi_tools_psf::set_by_key othf "omc_dec" $omc_dec

            set astroid [lreplace $astroid 2 2 $othf]
            set s [lreplace $s $idcata $idcata $astroid]
            set sources [lreplace $sources $id $id $s]
         }
      }

      set list_id_ref [::tools_cata::get_id_astrometric "R" current_listsources]

      foreach l $list_id_ref {
         set id     [lindex $l 0]
         set idcata [lindex $l 1]
         set ar     [lindex $l 2]
         set ac     [lindex $l 3]
         set name   [lindex $l 4]

         set x  [lsearch -index 0 $cataref($id_current_image) $name]
         if {$x>=0} {
            set data [lindex [lindex $cataref($id_current_image) $x] 1]
            set res_ra  [lindex $data 0]
            set res_dec [lindex $data 1]

            set s [lindex $sources $id]

            set ra  ""
            set dec ""
            set x [lsearch -index 0 $s $ac]
            if {$x>=0} {
               set cata [lindex $s $x]
               set ra  [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
            }

            set astroid [lindex $s $idcata]
            set othf [lindex $astroid 2]
            ::bdi_tools_psf::set_by_key othf "ra"      $ra
            ::bdi_tools_psf::set_by_key othf "dec"     $dec
            ::bdi_tools_psf::set_by_key othf "res_ra"  $res_ra
            ::bdi_tools_psf::set_by_key othf "res_dec" $res_dec
            set astroid [lreplace $astroid 2 2 $othf]
            set s [lreplace $s $idcata $idcata $astroid]
            set sources [lreplace $sources $id $id $s]
         }
      }

      set ::bdi_gui_cata::cata_list($id_current_image) [list $fields $sources]

   }

}


#----------------------------------------------------------------------------
## Astrometrie: Debiaisage des positions observees d'apres Farnocchia et al., Icarus 245, 2015
# @details Correction du biais sur les positions observees des asteroides en fonction du cata
# @return void
proc ::bdi_tools_astrometry::apply_debias { } {

   global bddconf

   # Creation du fichier de positions a debiaiser: debias.pos
   set chan0 [open [file join $bddconf(dirtmp) $::bdi_tools_astrometry::fileposdebias] w]
   set id_current_image 0
   array unset tabsources_ref
   array unset tabsources_img
   foreach current_image $::tools_cata::img_list {

      incr id_current_image

      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set exposure [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"] 1]]
      set midexpo 0
      if {$exposure != -1} {
         set midexpo [expr ($exposure/2.0) / 86400.0]
      }
      set dateobsjd [expr [::bddimages_liste::lget $current_image "commundatejj"] + $midexpo]

      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)
      set fields [lindex $current_listsources 0]
      set sources [lindex $current_listsources 1]

      set cataref ""
      set list_id_reference [::tools_cata::get_id_astrometric "R" current_listsources]
      foreach l $list_id_reference {
         set cataref [lindex $l 3]
      }
      # DEBIAS_CATA_LIST : USNO-A1.0 USNO-SA1.0 USNO-A2.0 USNO-SA2.0 UCAC-1 Tycho-2 GSC-1.1 GSC-1.2 ACT GSC-ACT USNO-B1.0 PPM UCAC-4 UCAC-2 UCAC-3 NOMAD CMC-14 2MASS SDSS-DR7
      set apply_bias "yes"
      switch $cataref {
         "UCAC2"  { set cataref "UCAC-2" }
         "UCAC3"  { set cataref "UCAC-3" }
         "UCAC4"  { set cataref "UCAC-4" }
         "TYCHO2" { set cataref "Tycho-2" }
         "NOMAD1" { set cataref "NOMAD" }
         "USNOA2" { set cataref "USNO-A2.0" }
         "2MASS"  { set cataref "2MASS" }
         "SDSS"   { set cataref "SDSS" }
         default  { set apply_bias "no" }
      }

      if {$apply_bias == "yes"} {

         set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]
         foreach l $list_id_science {
            set id   [lindex $l 0]
            set ac   [lindex $l 3]
            set name [lindex $l 4]
            if {$ac == "SKYBOT"} {
               set astroid [lindex [lindex $sources $id] 1]
               set comastroid [lindex $astroid 1]
               set ra  [lindex $comastroid 0]
               set dec [lindex $comastroid 1]
               puts $chan0 "$dateobsjd $ra $dec $cataref $id $ac $name $id_current_image"
            }
         }

      }

   }
   close $chan0

   # Execution de la correction de biais
   set cmdfile [file join $bddconf(dirtmp) $::bdi_tools_astrometry::filecmddebias]
   set resfile [file join $bddconf(dirtmp) $::bdi_tools_astrometry::fileresdebias]
   set errfile [file join $bddconf(dirtmp) ${::bdi_tools_astrometry::fileresdebias}.err]
   set chan0 [open $cmdfile w]
   puts $chan0 "#!/bin/sh"
   puts $chan0 "LD_LIBRARY_PATH=$::bdi_tools_astrometry::locallib:$::bdi_tools_astrometry::ifortlib"
   puts $chan0 "export LD_LIBRARY_PATH"
   puts $chan0 "debias_multi -bdi -f [file join $bddconf(dirtmp) $::bdi_tools_astrometry::fileposdebias] >$resfile 2>$errfile"
   close $chan0

   set err [catch {exec sh $cmdfile} msg]
   if {$err} {
      gren_info "Debias: error #$err: $msg\n"
   }

   # Extraction des resultats
   ::bdi_tools_astrometry::extract_debias_results $resfile

}


#----------------------------------------------------------------------------
## Astrometrie: Extraction des resultats astrometriques du DEBIAS
# @param file string Nom du fichier contenant les resultats generes par Debias
# @return void
proc ::bdi_tools_astrometry::extract_debias_results { file } {

   ::bdi_tools_astrometry::set_fields_astrom astrom
   set n [llength $astrom(kwds)]
   set id_current_image 0
   set nberr 0

   # Lecture du fichier en continue
   set chan [open $file r]
   while {[gets $chan line] >= 0} {
      set val [regexp -all -inline {\S+} $line]
      set id_current_image [lindex $val 12]
      set key "[lindex $val 9]_[lindex $val 11]"
      set catascience($id_current_image) ""
      lappend catascience($id_current_image) [ list $key [ list EPOCH [lindex $val 0] RA [lindex $val 1] DEC [lindex $val 2] \
                                                                RA_CORR [lindex $val 3] DEC_CORR [lindex $val 4] \
                                                                DEBIAS [list RA [lindex $val 5] DEC [lindex $val 6]] \
                                                                CATAREF [lindex $val 7] HEALPIX [lindex $val 8] ]]
   }
   close $chan

   # Insertion des resultats dans cata_list
   set id_current_image 0

   foreach current_image $::tools_cata::img_list {

      incr id_current_image

      set ex [::bddimages_liste::lexist $current_image "listsources"]
      if {$ex != 0} {
         gren_erreur "Attention listsources existe dans img_list et ce n'est plus necessaire\n"
      }

      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)
      set fields [lindex $current_listsources 0]
      set sources [lindex $current_listsources 1]
      set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]

      foreach l $list_id_science {
         set id     [lindex $l 0]
         set idcata [lindex $l 1]
         set ar     [lindex $l 2]
         set ac     [lindex $l 3]
         set name   [lindex $l 4]

         set x [lsearch -index 0 $catascience($id_current_image) "${id}_$name"]
         if {$x >= 0} {
            set data [lindex [lindex $catascience($id_current_image) $x] 1]
            set ra_corr    [lindex $data 7]
            set dec_corr   [lindex $data 9]
            set valdebias  [lindex $data 11]
            set debias_ra  [expr [lindex $valdebias 1]*1000.0]
            set debias_dec [expr [lindex $valdebias 3]*1000.0]
            set healpix    [lindex $data 15]
            gren_info "   DEBIAS: healpix=$healpix ; debias_ra=$debias_ra mas ; debias_dec=$debias_dec mas\n"

            set s [lindex $sources $id]
            set astroid [lindex $s $idcata]
            set othf [lindex $astroid 2]

            ::bdi_tools_psf::set_by_key othf "ra"  $ra_corr
            ::bdi_tools_psf::set_by_key othf "dec" $dec_corr

            set astroid [lreplace $astroid 2 2 $othf]
            set s [lreplace $s $idcata $idcata $astroid]
            set sources [lreplace $sources $id $id $s]
         }
      }

      set ::bdi_gui_cata::cata_list($id_current_image) [list $fields $sources]

   }

}


#----------------------------------------------------------------------------
## Astrometrie: Copie du fichier de config sextractor dans outdir/config.sex
#  apres substitution des chemins vers les fichiers pour pointer dans outdir
# @param sexfile string nom du fichier template de la config sextractor
# @param outdir string nom du repertoire dans lequel sera copie la conf sous le nom config.sex
# @return void
proc ::bdi_tools_astrometry::copy_sextractor_config_file { sexfile outdir } {

   global bddconf

   set inf [open $sexfile r]
   set ouf [open [file join $outdir config.sex] "w"]
   while {[gets $inf line] >= 0 } {
      regsub -- {TMP_DIR} $line $outdir line
      puts $ouf $line
   }
   close $inf
   close $ouf

}


#----------------------------------------------------------------------------
## Astrometrie: Composition du mail a envoyer au MPC pour soumettre le resultat astrometrique
# @return void
proc ::bdi_tools_astrometry::send_to_mpc { } {

   ::bdi_tools::sendmail::compose_with_thunderbird \
         $::bdi_tools_astrometry::rapport_desti \
         $::bdi_tools_astrometry::rapport_batch \
         [$::bdi_gui_astrometry::rapport_mpc get 0.0 end]

}


#----------------------------------------------------------------------------
# EPHEMERIDES
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Ephemerides: Initialisation des calculs des ephemerides
# @details Creation du fichier de dates pour lesquelles on veut calculer des ephemerides,
#          et creation du fichier de commande shell pour executer Eproc.ephemcc
# @param name string nom de l'objet
# @param list_dates array des dates au format list_dates(jd) = isodate
# @return nom du fichier de commande pour calculer l'ephemeride de l'objet
proc ::bdi_tools_astrometry::init_ephem_imcce { name list_dates } {

   upvar $list_dates ldates
   global bddconf

   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

   # Tri dans l'ordre croissant des dates
   set tridates {}
   foreach d [array names ldates] {
      lappend tridates $d
   }
   set tridates [lsort -real $tridates]

   # Creation du fichier des dates de toutes les images selectionnees
   # pour lesquelles on veut calculer les ephemerides des objets
   set filedate [file join $bddconf(dirtmp) "datephem_$name.dat"]
   set chan0 [open $filedate w]
   foreach d $tridates {
      puts $chan0 "$d"
   }
   close $chan0

   # Extraction des num et nom de l'objet science dont on veut calculer l'ephem
   set n [split $name "_"]
   set cata [lindex $n 0]
   set num [string trim [lindex $n 1]]
   set nom [string trim [lrange $n 2 end]]
   set ephnom "-n $num"
   if {$num == "" || $num == "-"} {
      set ephnom "-nom \"$nom\""
   }

   # Creation du fichier de cmde pour executer ephemcc
   set cmdfile [file join $bddconf(dirtmp) cmdephem_$name.sh]
   set chan0 [open $cmdfile w]
   puts $chan0 "#!/bin/sh"
   puts $chan0 "LD_LIBRARY_PATH=$::bdi_tools_astrometry::locallib:$::bdi_tools_astrometry::ifortlib"
   puts $chan0 "export LD_LIBRARY_PATH"
   switch $cata {
      "SKYBOT" {
         set cmd "$::bdi_tools_astrometry::imcce_ephemcc asteroide $ephnom -j $filedate 1 -tp 1 -te 1 -tc 5 -uai $::bdi_tools_astrometry::rapport_uai_code -d 1 -e utc --julien"
      }
      "IMG" -
      "USER" -
      "ASTROID" {
         set cmd ""
      }
      default {
         # Recup et ecrit les infos du cata de cette etoile dans un fichier local.cat.tmp
         ::manage_source::extract_tabsources_by_flagastrom "S" tabsources
         ::bdi_tools_priam::add_source2localcat $name $tabsources($name)
         set starnum "${num}_[string map {" " "_"} ${nom}]"
         set cmd "$::bdi_tools_astrometry::imcce_ephemcc etoile -a $cata -n $starnum -r ./ -j $filedate 1 -tp 1 -te 1 -tc 5 -uai $::bdi_tools_astrometry::rapport_uai_code -d 1 -e utc --julien"
      }
   }
   puts $chan0 $cmd
   close $chan0

   # Retourne le nom du fichier de cmde
   if {$cmd == "" } {
      return -code 1 "No ephemeris for this target"
   } else {
      return $cmdfile
   }
}





#----------------------------------------------------------------------------
## Ephemerides: Calcul des ephemerides IMCCE pour tous les objets SCIENCE pour toutes les dates
# @return code 0
proc ::bdi_tools_astrometry::get_ephem_imcce {  } {

   # Initialisation
   array unset ::bdi_tools_astrometry::ephem_imcce

   # Pour chaque objet
   foreach {name y} [array get ::bdi_tools_astrometry::listscience] {

      # Collecte des dates pour l'objet courant
      array unset list_dates
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {
         set midepoch $::tools_cata::date2midate($dateimg)
         set list_dates([format "%18.10f" $midepoch]) $dateimg
      }

      # Test l'existence de dates de calcul
      if {[array size list_dates] == 0} {
         gren_erreur "WARNING: Aucune date de calcul pour l'objet $name\n"
         continue
      }

      # Initialise les calculs d'ephemerides pour l'objet
      set err [ catch {set cmdfile [::bdi_tools_astrometry::init_ephem_imcce $name list_dates] } msg ]
      if {$err} {
         gren_erreur "Erreur init_ephem_imcce : $msg\n"
         foreach {midepoch dateimg} [array get list_dates] {
            set ::bdi_tools_astrometry::ephem_imcce($name,$dateimg) [list $midepoch "-" "-" "-" "-"]
         }
         return -code 0 $msg
      }

      # Calcul des ephemerides de l'objet
      gren_info " - Calcul des ephemerides (IMCCE) de l'objet $name ... "
      set tt0 [clock clicks -milliseconds]
      set err [catch {exec sh $cmdfile} msg]
      gren_info "en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"
      #gren_info "err = $err\n"
      #gren_info "msg = $msg\n"
      #gren_info "cmdfile = $cmdfile\n"
      if { $err } {
         gren_info "dateimg = $name $dateimg $midepoch\n"
         gren_erreur "ERROR ephemcc #$err: $msg\n"
         foreach {midepoch dateimg} [array get list_dates] {
            set ::bdi_tools_astrometry::ephem_imcce($name,$dateimg) [list $midepoch "-" "-" "-" "-"]
         }
      } else {
         array unset ephem
         set cata [lindex [split $name "_"] 0]
         foreach line [split $msg "\n"] {
            set line [string trim $line]
            set c [string index $line 0]
            if {$c == "#"} {
               continue
            }

            set rd [regexp -inline -all -- {\S+} $line]
            set tab [split $rd " "]
            switch $cata {
               "SKYBOT" {
                  set jd [lindex $tab 0]
                  set ra [::bdi_tools::sexa2dec [list [lindex $tab  2] [lindex $tab 3] [lindex $tab 4]] 15.0]
                  set ra_audela "[lindex $tab  2]h[lindex $tab  3]m[lindex $tab  4]s"
                  set ra_audela [mc_angle2deg $ra_audela]
                  set ra_diff [expr ($ra_audela-$ra)*3600000.0]

                  set dec [::bdi_tools::sexa2dec [list [lindex $tab  5] [lindex $tab  6] [lindex $tab  7]] 1.0]
                  set dec_audela "[lindex $tab  5]d[lindex $tab  6]m[lindex $tab  7]s"
                  set dec_audela [mc_angle2deg $dec_audela]
                  set dec_diff [expr ($dec_audela-$dec)*3600000.0]

                  #gren_info "---> $jd [mc_date2iso8601 $jd] RA = [lindex $tab  2] [lindex $tab  3] [lindex $tab  4] -> $ra :: $ra_audela\n"
                  #gren_info "---> $jd [mc_date2iso8601 $jd] diff ra = $ra_diff ; diff dec = $dec_diff\n"

                  set h [::bdi_tools::sexa2dec [list [lindex $tab 17] [lindex $tab 18] [lindex $tab 19]] 1.0]
                  set am [lindex $tab 20]
                  if {$am == "---"} { set am "" }
               }
               "IMG" -
               "USER" -
               "ASTROID" {
                  set jd "-"
                  set ra "-"
                  set dec "-"
                  set h "-"
                  set am ""
               }
               default {
                  set jd [lindex $tab 0]
                  set ra [::bdi_tools::sexa2dec [list [lindex $tab  2] [lindex $tab  3] [lindex $tab  4]] 15.0]
                  set dec [::bdi_tools::sexa2dec [list [lindex $tab  5] [lindex $tab  6] [lindex $tab  7]] 1.0]
                  set h [::bdi_tools::sexa2dec [list [lindex $tab 17] [lindex $tab 18] [lindex $tab 19]] 1.0]
                  set am [lindex $tab 21]
                  if {$am == "---"} { set am "" }
               }
            }
            set ephem([format "%18.10f" $jd]) [list $jd $ra $dec $h $am]
         }

         # Sauvegarde des ephemerides de l'objet courant
         array set ::bdi_tools_astrometry::ephemsav [array get ephem]
         #gren_info "ephem = [array get ephem]\n"
         set a [array get ephem]
         if {$a==""} {
            gren_erreur "No ephemeris for this body\n"
            continue
         }
         foreach {midepoch dateimg} [array get list_dates] {
            set ::bdi_tools_astrometry::ephem_imcce($name,$dateimg) $ephem($midepoch)
         }
      }

   }
   return 0

}


#----------------------------------------------------------------------------
## Ephemerides: Preparation du job pour calculer les ephemerides JPL des objets SCIENCE pour toutes les dates
# @details Cette fonction compose le mail pour soumettre un job a Horizon\@jpl.
#          L'envoie du mail est a effectuer par l'utilisateur.
# @return code 0
proc ::bdi_tools_astrometry::compose_ephem_jpl {  } {

   # Le Sso concerne est celui selectionne dans la combo liste
# TODO : tester que c bien un objet skybot
   set fname $::bdi_gui_astrometry::combo_list_object
   set cataname [lindex [split $fname "_"] 0]
   if {[string compare $cataname "SKYBOT"] != 0} {
      gren_erreur "WARNING: La source n'est pas un corps du systeme solaire.\n"
      return
   }
   set sso_name [lrange [split $fname "_"] 2 end]
   if {[string length $sso_name] < 1} {
      gren_erreur "WARNING: Aucun Sso n'a ete selectionne\n"
      return
   }

   # Initialisations
   array unset ::bdi_tools_astrometry::ephem_jpl
   array unset list_dates

   # Collecte des infos
   foreach {name y} [array get ::bdi_tools_astrometry::listscience] {
      if {[string compare $name $fname] != 0} {
         continue
      }
      # Collecte des dates pour l'objet selectionne
      set ldates {}
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {
         set midepoch $::tools_cata::date2midate($dateimg)
         set list_dates([format "%18.9f" $midepoch]) $dateimg
      }
   }

   # Test l'existence de dates de calcul
   if {[array size list_dates] == 0} {
      gren_erreur "WARNING: Aucune date de calcul pour l'objet $name\n"
      return
   }

   # Creation du msg pour Horizons@JPL
   gren_info " - Calcul des ephemerides (JPL) de l'objet $fname ...\n"
   set jpl_job [::bdi_tools_jpl::create $sso_name list_dates $::bdi_tools_astrometry::rapport_uai_code]

   # Composition du mail a envoyer a Horizons@JPL
   ::bdi_tools::sendmail::compose_with_thunderbird $::bdi_tools_jpl::destinataire $::bdi_tools_jpl::sujet $jpl_job

   # Mode manuel ...
   gren_info "     * Verifiez le message puis envoyez le\n"
   gren_info "     * Copier/coller la reponse de Horizons@JPL dans la gui\n"
   gren_info "     * Charger les ephemerides en cliquant sur le bouton READ\n"

   # A ce stade, les ephemerides du JPL n'existe pas et on prepare la structure
   # de donnees pour quand meme pouvoir generer le rapport (sans les donnees JPL).
   foreach {midepoch dateimg} [array get list_dates] {
      set ::bdi_tools_astrometry::ephem_jpl($fname,$dateimg) [list $midepoch "" ""]
   }

   return 0

}


#----------------------------------------------------------------------------
## Ephemerides: Lecture et chargement des ephemerides JPL depuis la zone de texte dediee dans la GUI
# @return code 0
proc ::bdi_tools_astrometry::read_ephem_jpl {  } {

   # Sanity check: le bouton ephemerides doit deja avoir ete active
   if {[array size ::bdi_tools_astrometry::ephem_jpl] < 1} {
      gren_erreur "Veuillez initialiser les ephemerides en cliquant sur le bouton 'Ephemerides'"
      return
   }

   gren_info "Lecture des ephemerides JPL depuis la zone de texte ...\n"

   # Lecture des ephemerides JPL dans la zone de texte
   array unset ephem
   ::bdi_tools_jpl::read [$::bdi_gui_astrometry::getjpl_recev get 0.0 end] ephem

   # Sauvegarde des ephemerides de l'objet calcule
   if {[array size ephem] > 0} {
      foreach {key val} [array get ::bdi_tools_astrometry::ephem_jpl] {
         set midepoch [lindex $val 0]
         set ::bdi_tools_astrometry::ephem_jpl($key) $ephem($midepoch)
      }
   } else {
      gren_info "WARNING: aucune ephemeride a charger\n"
   }

   gren_info "done"
   return 0

}


#----------------------------------------------------------------------------
# STRUCTURE DE DONNEES
#----------------------------------------------------------------------------
# Structure de tabval :
#  0  id
#  1  field
#  2  ar
#  3  rho
#  4  res_ra
#  5  res_dec
#  6  ra
#  7  dec
#  8  mag
#  9  err_mag
# 10  err_xsm
# 11  err_ysm
# 12  fwhmx
# 13  fwhmy
# 14  debias_ra
# 15 debias_dec

#----------------------------------------------------------------------------
## Initialisation de la structure des donnees d'astrometrie
# @return void
proc ::bdi_tools_astrometry::create_vartab { } {

   if {[info exists ::bdi_tools_astrometry::tabval]}      {unset ::bdi_tools_astrometry::tabval}
   if {[info exists ::bdi_tools_astrometry::listref]}     {unset ::bdi_tools_astrometry::listref}
   if {[info exists ::bdi_tools_astrometry::listscience]} {unset ::bdi_tools_astrometry::listscience}
   if {[info exists ::bdi_tools_astrometry::listdate]}    {unset ::bdi_tools_astrometry::listdate}

   set id_current_image 0

   foreach current_image $::tools_cata::img_list {

      incr id_current_image
      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)

      set tabkey  [::bddimages_liste::lget $current_image "tabkey"]
      set dateiso [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]

      gren_info "-- IMG : $id_current_image / [llength $::tools_cata::img_list] :: $dateiso "

      # REFERENCES

      set list_id_ref [::tools_cata::get_id_astrometric "R" current_listsources]

      foreach l $list_id_ref {

         set id     [lindex $l 0]
         set idcata [lindex $l 1]
         set ar     [lindex $l 2]
         set ac     [lindex $l 3]
         set name   [string trim [lindex $l 4]]

         if {$name == ""} {
            gren_info "Lect Ref = $id $idcata $ar $ac $name\n"
         }

         set s        [lindex [lindex $current_listsources 1] $id]
         set astroid  [lindex $s $idcata]
         set othf     [lindex $astroid 2]

         set ra       [::bdi_tools_psf::get_val othf "ra"]
         set dec      [::bdi_tools_psf::get_val othf "dec"]
         set res_ra   [::bdi_tools_psf::get_val othf "res_ra"]
         set res_dec  [::bdi_tools_psf::get_val othf "res_dec"]
         set omc_ra   [::bdi_tools_psf::get_val othf "omc_ra"]
         set omc_dec  [::bdi_tools_psf::get_val othf "omc_dec"]
         set mag      [::bdi_tools_psf::get_val othf "mag"]
         set err_mag  [::bdi_tools_psf::get_val othf "err_mag"]
         set err_xsm  [::bdi_tools_psf::get_val othf "err_xsm"]
         set err_ysm  [::bdi_tools_psf::get_val othf "err_ysm"]
         set fwhmx    [::bdi_tools_psf::get_val othf "fwhmx"]
         set fwhmy    [::bdi_tools_psf::get_val othf "fwhmy"]
         set debias_a [::bdi_tools_psf::get_val othf "debias_ra"]
         set debias_d [::bdi_tools_psf::get_val othf "debias_dec"]

         if { $res_ra == "" || $res_dec == "" } {
            set rho     ""
            set res_ra  ""
            set res_dec ""
         } else {
            set rho     [format "%.4f" [expr sqrt((pow($res_ra,2)+pow($res_dec,2))/2.)]]
            set res_ra  [format "%.4f" $res_ra ]
            set res_dec [format "%.4f" $res_dec]
         }
         if { $err_xsm != "" && $err_xsm != "-" } {
            set err_xsm   [format  "%.4f" $err_xsm]
         }
         if { $err_ysm != "" && $err_ysm != "-" } {
            set err_ysm   [format  "%.4f" $err_ysm]
         }
         if { $mag != "" && $mag != "-" } {
            set mag [format  "%.3f" $mag]
         }
         if { $err_mag != "" && $err_mag != "-" } {
            set err_mag [format  "%.3f" $err_mag]
         }


         set ::bdi_tools_astrometry::tabval($name,$dateiso) [list [expr $id + 1] field $ar $rho $res_ra $res_dec $ra $dec $mag $err_mag $err_xsm $err_ysm $fwhmx $fwhmy $debias_a $debias_d]

         lappend ::bdi_tools_astrometry::listref($name)     $dateiso
         lappend ::bdi_tools_astrometry::listdate($dateiso) $name
         set ::bdi_tools_astrometry::date_to_id($dateiso)   $id_current_image

      }

      # SCIENCES

      set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]
      foreach l $list_id_science {

         set id     [lindex $l 0]
         set idcata [lindex $l 1]
         set ar     [lindex $l 2]
         set ac     [lindex $l 3]
         set name   [lindex $l 4]

         if {$name == ""} {
            gren_info "Lect Science = $id $idcata $ar $ac $name\n"
         }

         set s        [lindex [lindex $current_listsources 1] $id]
         set astroid  [lindex $s $idcata]
         set othf     [lindex $astroid 2]

         set ra       [::bdi_tools_psf::get_val othf "ra"]
         set dec      [::bdi_tools_psf::get_val othf "dec"]
         set res_ra   [::bdi_tools_psf::get_val othf "res_ra"]
         set res_dec  [::bdi_tools_psf::get_val othf "res_dec"]
         set omc_ra   [::bdi_tools_psf::get_val othf "omc_ra"]
         set omc_dec  [::bdi_tools_psf::get_val othf "omc_dec"]
         set mag      [::bdi_tools_psf::get_val othf "mag"]
         set err_mag  [::bdi_tools_psf::get_val othf "err_mag"]
         set err_xsm  [::bdi_tools_psf::get_val othf "err_xsm"]
         set err_ysm  [::bdi_tools_psf::get_val othf "err_ysm"]
         set fwhmx    [::bdi_tools_psf::get_val othf "fwhmx"]
         set fwhmy    [::bdi_tools_psf::get_val othf "fwhmy"]
         set debias_a [::bdi_tools_psf::get_val othf "debias_ra"]
         set debias_d [::bdi_tools_psf::get_val othf "debias_dec"]

         if { $res_ra == "" || $res_dec == "" } {
            set rho  ""
            set res_ra  ""
            set res_dec ""
         } else {
            set rho     [format "%.4f" [expr sqrt((pow($res_ra,2)+pow($res_dec,2))/2.)]]
            set res_ra  [format "%.4f" $res_ra ]
            set res_dec [format "%.4f" $res_dec]
         }
         if { $err_xsm != "" && $err_xsm != "-" } {
            set err_xsm   [format  "%.4f" $err_xsm]
         }
         if { $err_ysm != "" && $err_ysm != "-" } {
            set err_ysm   [format  "%.4f" $err_ysm]
         }
         if { $mag != "" && $mag != "-" } {
            set mag [format  "%.3f" $mag]
         }
         if { $err_mag != "" && $err_mag != "-" } {
            set err_mag [format  "%.3f" $err_mag]
         }

         set ::bdi_tools_astrometry::tabval($name,$dateiso) [list [expr $id + 1] "field" $ar $rho $res_ra $res_dec $ra $dec $mag $err_mag $err_xsm $err_ysm $fwhmx $fwhmy $debias_a $debias_d]

#   0  ids        : id source
#   1  champ      :
#   2  cata       :
#   3  rho        : rho =  rayon des residu
#   4  res_ra     : residu alpha
#   5  res_dec    : residu delta
#   6  ra         : alpha
#   7  dec        : delta
#   8  mag        : magnitude
#   9  err_mag    : erreur sur magnitude
#   10 err_xsm    : erreur sur position X pixel
#   11 err_ysm    : erreur sur position X pixel
#   12 fwhmx      : fwhm en X
#   13 fwhmy      : fwhm en Y
#   14 debias_a   : correction debias en alpha
#   15 debias_d   : correction debias en delta

         lappend ::bdi_tools_astrometry::listscience($name) $dateiso
         lappend ::bdi_tools_astrometry::listdate($dateiso) $name
      }

      gren_info "date = $dateiso "
      gren_info "nb science = [llength $list_id_science] "
      gren_info "nb ref = [llength $list_id_ref] \n"

   }

}




#----------------------------------------------------------------------------
# CALCUL DES STATISTIQUES
#----------------------------------------------------------------------------
#   0  nb        : nb d element
#   1  mrho      : moyenne sur rho =  rayon des residu
#   2  stdev_rho : stdev sur rho
#   3  mra       : moyenne sur residu alpha
#   4  mrd       : moyenne sur residu delta
#   5  sra       : stdev sur residu alpha
#   6  srd       : stdev sur residu delta
#   7  ma        : moyenne sur alpha
#   8  md        : moyenne sur delta
#   9  sa        : stdev sur alpha
#   10 sd        : stdev sur delta
#   11 mm        : moyenne sur la magnitude
#   12 sm        : stdev sur la magnitude

#----------------------------------------------------------------------------
## Calcul des statistiques sur les donnees d'astrometrie
# @return void
proc ::bdi_tools_astrometry::calcul_statistique { } {

   package require math::statistics

   if {[info exists ::bdi_tools_astrometry::tabdate]}    {unset ::bdi_tools_astrometry::tabdate}
   if {[info exists ::bdi_tools_astrometry::tabref]}     {unset ::bdi_tools_astrometry::tabref}
   if {[info exists ::bdi_tools_astrometry::tabscience]} {unset ::bdi_tools_astrometry::tabscience}

   # STAT sur la liste des references

   set cpt 0
   foreach name [array names ::bdi_tools_astrometry::listref] {

      incr cpt

      set rho ""
      set a   ""
      set d   ""
      set ra  ""
      set rd  ""
      set m   ""

      foreach date $::bdi_tools_astrometry::listref($name) {
         set tmp [lindex $::bdi_tools_astrometry::tabval($name,$date)  3]
         if {$tmp != ""} {
            lappend rho $tmp
         }
         lappend ra    [lindex $::bdi_tools_astrometry::tabval($name,$date)  4]
         lappend rd    [lindex $::bdi_tools_astrometry::tabval($name,$date)  5]
         lappend a     [lindex $::bdi_tools_astrometry::tabval($name,$date)  6]
         lappend d     [lindex $::bdi_tools_astrometry::tabval($name,$date)  7]
         lappend m     [lindex $::bdi_tools_astrometry::tabval($name,$date)  8]
         lappend err_x [lindex $::bdi_tools_astrometry::tabval($name,$date) 10]
         lappend err_y [lindex $::bdi_tools_astrometry::tabval($name,$date) 11]
         #gren_info "tabval($name,$date) = $::bdi_tools_astrometry::tabval($name,$date)\n"

         set ids     [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
         set r       [lindex $::bdi_tools_astrometry::tabval($name,$date) 3]
         set res_ra  [lindex $::bdi_tools_astrometry::tabval($name,$date) 4]
         set res_dec [lindex $::bdi_tools_astrometry::tabval($name,$date) 5]
         set mag     [lindex $::bdi_tools_astrometry::tabval($name,$date) 8]
         set err_xsm [lindex $::bdi_tools_astrometry::tabval($name,$date) 10]
         set err_ysm [lindex $::bdi_tools_astrometry::tabval($name,$date) 11]
         set fwhmx   [lindex $::bdi_tools_astrometry::tabval($name,$date) 12]
         set fwhmy   [lindex $::bdi_tools_astrometry::tabval($name,$date) 13]

         if {$r == ""}       { set r inf }
         if {$res_ra == ""}  { set res_ra inf }
         if {$res_dec == ""} { set res_dec inf }

         set ::bdi_tools_astrometry::tabref($name,$date) [list $ids $name $date $r $res_ra $res_dec $mag $err_xsm $err_ysm $fwhmx $fwhmy ]

         #   0  ids        : id source
         #   1  name       :
         #   2  date       :
         #   3  rho        : rho =  rayon des residu
         #   4  res_ra     : residu alpha
         #   5  res_dec    : residu delta
         #   6  mag        : magnitude
         #   7  err_xsm    : erreur sur position X pixel
         #   8  err_ysm    : erreur sur position X pixel
         #   9  fwhmx      : fwhm en X
         #   10 fwhmy      : fwhm en Y
      }

      #gren_info "nb a : [llength $a] ($a)\n"

      set nb    [llength $::bdi_tools_astrometry::listref($name)]
      set nbm   [llength $m]
      set nbrho [llength $rho]

      set mrho ""
      set mra  ""
      set mrd  ""
      if {$nbrho > 0} {
         #gren_erreur "Reference ($date): rho = $rho ; ra = $ra ; rd = $rd\n"
         if {[llength $rho] > 0} { set mrho [format "%.3f" [::math::statistics::mean $rho]] }
         if {[llength $ra]  > 0} { set mra  [format "%.3f" [::math::statistics::mean $ra ]] }
         if {[llength $rd]  > 0} { set mrd  [format "%.3f" [::math::statistics::mean $rd ]] }
      }

      set srho     ""
      set sra      ""
      set srd      ""
      if {$nbrho > 1} {
         if {[llength $rho] > 0} { set srho [format "%.3f" [::math::statistics::stdev $rho]] }
         if {[llength $ra]  > 0} { set sra  [format "%.3f" [::math::statistics::stdev $ra ]] }
         if {[llength $rd]  > 0} { set srd  [format "%.3f" [::math::statistics::stdev $rd ]] }
      }

      set ma ""
      set md ""
      if {$nb > 1} {
         #gren_erreur "Reference ($date): a = $a ; d = $d\n"
         if {[llength $a] > 0} { set ma [format "%.6f" [::math::statistics::mean $a]] }
         if {[llength $d] > 0} { set md [format "%.5f" [::math::statistics::mean $d]] }
      }

      set sa ""
      set sd ""
      if {$nb > 1} {
         if {[llength $a] > 0} { set sa [format "%.3f" [::math::statistics::stdev $a]] }
         if {[llength $d] > 0} { set sd [format "%.3f" [::math::statistics::stdev $d]] }
      }

      set err [ catch {set merr_x [format "%.3f" [::math::statistics::mean $err_x]]} msg ]
      if {$err} {
         set merr_x ""
      }

      set err [ catch {set merr_y [format "%.3f" [::math::statistics::mean $err_y]]} msg ]
      if {$err} {
         set merr_y ""
      }

      set err [ catch {set mm [format "%.3f" [::math::statistics::mean $m]]} msg ]
      if {$err} {
         set mm ""
      }

      set err [ catch {set sm [format "%.3f" [::math::statistics::stdev $m]]} msg ]
      if {$err} {
         set sm ""
      }

      set ::bdi_tools_astrometry::tabref($name) [list $name $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm $merr_x $merr_y]
   }

   # STAT sur la liste des sciences

   foreach name [array names ::bdi_tools_astrometry::listscience] {

      set rho ""
      set a ""
      set d ""
      set ra ""
      set rd ""
      set m ""

      foreach date $::bdi_tools_astrometry::listscience($name) {
         set tmp [lindex $::bdi_tools_astrometry::tabval($name,$date)  3]
         if {$tmp != ""} {
            lappend rho $tmp
         }

         lappend ra    [lindex $::bdi_tools_astrometry::tabval($name,$date) 4]
         lappend rd    [lindex $::bdi_tools_astrometry::tabval($name,$date) 5]
         lappend a     [lindex $::bdi_tools_astrometry::tabval($name,$date) 6]
         lappend d     [lindex $::bdi_tools_astrometry::tabval($name,$date) 7]
         lappend m     [lindex $::bdi_tools_astrometry::tabval($name,$date) 8]
         lappend err_x [lindex $::bdi_tools_astrometry::tabval($name,$date) 10]
         lappend err_y [lindex $::bdi_tools_astrometry::tabval($name,$date) 11]

         set ids     [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
         set r       [lindex $::bdi_tools_astrometry::tabval($name,$date) 3]
         set res_ra  [lindex $::bdi_tools_astrometry::tabval($name,$date) 4]
         set res_dec [lindex $::bdi_tools_astrometry::tabval($name,$date) 5]
         set mag     [lindex $::bdi_tools_astrometry::tabval($name,$date) 8]
         set err_xsm [lindex $::bdi_tools_astrometry::tabval($name,$date) 10]
         set err_ysm [lindex $::bdi_tools_astrometry::tabval($name,$date) 11]
         set fwhmx   [lindex $::bdi_tools_astrometry::tabval($name,$date) 12]
         set fwhmy   [lindex $::bdi_tools_astrometry::tabval($name,$date) 13]

         if {$r == ""}       { set r inf }
         if {$res_ra == ""}  { set res_ra inf }
         if {$res_dec == ""} { set res_dec inf }

         set ::bdi_tools_astrometry::tabscience($name,$date) [list $ids $name $date $r $res_ra $res_dec $mag $err_xsm $err_ysm $fwhmx $fwhmy ]

         #   0  ids        : id source
         #   1  name       :
         #   2  date       :
         #   3  rho        : rho =  rayon des residu
         #   4  res_ra     : residu alpha
         #   5  res_dec    : residu delta
         #   6  mag        : magnitude
         #   7  err_xsm    : erreur sur position X pixel
         #   8  err_ysm    : erreur sur position X pixel
         #   9  fwhmx      : fwhm en X
         #   10 fwhmy      : fwhm en Y

      }

      set nb    [llength $::bdi_tools_astrometry::listscience($name)]
      set nbrho [llength $rho]
      set nba   [llength $a]

      set mrho ""
      set mra  ""
      set mrd  ""
      if {$nbrho > 0} {
         #gren_erreur "Science ($date): rho = $rho ; ra = $ra ; rd = $rd\n"
         if {[llength $rho] > 0} { set mrho [format "%.3f" [::math::statistics::mean  $rho]] }
         if {[llength $ra]  > 0} { set mra  [format "%.3f" [::math::statistics::mean  $ra ]] }
         if {[llength $rd]  > 0} { set mrd  [format "%.3f" [::math::statistics::mean  $rd ]] }
      }

      set srho ""
      set sra  ""
      set srd  ""
      if {$nbrho > 1} {
         if {[llength $rho] > 0} { set srho [format "%.3f" [::math::statistics::stdev $rho]] }
         if {[llength $ra]  > 0} { set sra  [format "%.3f" [::math::statistics::stdev $ra ]] }
         if {[llength $rd]  > 0} { set srd  [format "%.3f" [::math::statistics::stdev $rd ]] }
      }

      set ma ""
      set md ""
      if {$nb > 1} {
         #gren_erreur "Science ($date): a = $a ; d = $d\n"
         if {[llength $a] > 0} { set ma [format "%.6f" [::math::statistics::mean $a]] }
         if {[llength $d] > 0} { set md [format "%.5f" [::math::statistics::mean $d]] }
      }

      set sa ""
      set sd ""
      if {$nb > 1} {
         if {[llength $a] > 0} { set sa [format "%.3f" [::math::statistics::stdev $a]] }
         if {[llength $d] > 0} { set sd [format "%.3f" [::math::statistics::stdev $d]] }
      }

      set err [ catch {set merr_x [format "%.3f" [::math::statistics::mean $err_x]]} msg ]
      if {$err} {
         set merr_x ""
      }

      set err [ catch {set merr_y [format "%.3f" [::math::statistics::mean $err_y]]} msg ]
      if {$err} {
         set merr_y ""
      }

      set err [ catch {set mm [format "%.3f" [::math::statistics::mean $m]]} msg ]
      if {$err} {
         set mm ""
      }

      set err [ catch {set sm [format "%.3f" [::math::statistics::stdev $m]]} msg ]
      if {$err} {
         set sm ""
      }

      set ::bdi_tools_astrometry::tabscience($name) [list $name $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm $merr_x $merr_y ]
   }

   # STAT sur la liste des dates

   foreach date [array names ::bdi_tools_astrometry::listdate] {

      set rho ""
      set a   ""
      set d   ""
      set ra  ""
      set rd  ""
      set m   ""

      set nb 0
      foreach name $::bdi_tools_astrometry::listdate($date) {
         if {[lindex $::bdi_tools_astrometry::tabval($name,$date) 0] == "S"} {
            continue
         }
         incr nb
         set tmp [lindex $::bdi_tools_astrometry::tabval($name,$date) 3]
         if {$tmp != ""} {
            lappend rho $tmp
         }
         lappend ra [lindex $::bdi_tools_astrometry::tabval($name,$date) 4]
         lappend rd [lindex $::bdi_tools_astrometry::tabval($name,$date) 5]
         lappend a  [lindex $::bdi_tools_astrometry::tabval($name,$date) 6]
         lappend d  [lindex $::bdi_tools_astrometry::tabval($name,$date) 7]
         lappend m  [lindex $::bdi_tools_astrometry::tabval($name,$date) 8]
      }

      set nbrho [llength $rho]

      set mrho ""
      set mra  ""
      set mrd  ""
      if {$nbrho > 0} {
         if {[llength $rho] > 0} { set mrho [format "%.3f" [::math::statistics::mean $rho]] }
         if {[llength $ra]  > 0} { set mra  [format "%.3f" [::math::statistics::mean $ra ]] }
         if {[llength $rd]  > 0} { set mrd  [format "%.3f" [::math::statistics::mean $rd ]] }
      }

      set srho ""
      set sra  ""
      set srd  ""
      if {$nbrho > 1} {
         if {[llength $rho] > 0} { set srho [format "%.3f" [::math::statistics::stdev $rho]] }
         if {[llength $ra]  > 0} { set sra  [format "%.3f" [::math::statistics::stdev $ra ]] }
         if {[llength $rd]  > 0} { set srd  [format "%.3f" [::math::statistics::stdev $rd ]] }
      }

      set ma ""
      set md ""
      if {$nb > 0} {
         if {[llength $a] > 0} { set ma [format "%.6f" [::math::statistics::mean $a]] }
         if {[llength $d] > 0} { set md [format "%.5f" [::math::statistics::mean $d]] }
      } else {
      }

      set sa ""
      set sd ""
      if {$nb > 1} {
         if {[llength $a] > 0} { set sa [format "%.3f" [::math::statistics::stdev $a]] }
         if {[llength $d] > 0} { set sd [format "%.3f" [::math::statistics::stdev $d]] }
      }

      set err [ catch {set merr_x [format "%.3f" [::math::statistics::mean $err_x]]} msg ]
      if {$err} {
         set merr_x ""
      }

      set err [ catch {set merr_y [format "%.3f" [::math::statistics::mean $err_y]]} msg ]
      if {$err} {
         set merr_y ""
      }

      set err [ catch {set mm [format "%.3f" [::math::statistics::mean $m]]} msg ]
      if {$err} {
         set mm ""
      }

      set err [ catch {set sm [format "%.3f" [::math::statistics::stdev $m]]} msg ]
      if {$err} {
         set sm ""
      }

      set ::bdi_tools_astrometry::tabdate($date) [list $date $nb $mrho $srho $mra $mrd $sra $srd $ma $md $sa $sd $mm $sm]
   }

}


#----------------------------------------------------------------------------
# SAUVEGARDE GLOBALE DES INFORMATIONS (image, CATA)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Avancement de la barre de progression lors de la sauvegarde des
# @param cur real Valeur courante
# @param max real Valeur maximum de la barre de progression
# @return void
proc ::bdi_tools_astrometry::set_savprogress { cur max } {

   set ::bdi_tools_astrometry::savprogress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update

}


#----------------------------------------------------------------------------
## Sauvegarde des images et des catas a la suite de la reduction astrometrique
# @return void
proc ::bdi_tools_astrometry::save_images { } {

   global audace bddconf

   set id_current_image 0
   ::bdi_tools_astrometry::set_fields_astrom astrom
   set n [llength $astrom(kwds)]

   foreach current_image $::tools_cata::img_list {

      incr id_current_image

      # Progression
      ::bdi_tools_astrometry::set_savprogress $id_current_image $::tools_cata::nb_img_list
      if { $::bdi_tools_astrometry::savannul } { break }

      # Tabkey
      set idbddimg [::bddimages_liste::lget $current_image "idbddimg"]
      set tabkey   [::bddimages_liste::lget $current_image "tabkey"]

      # Date
      set dateiso [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]

      # Noms des fichiers
      set imgfilename [::bddimages_liste::lget $current_image filename]
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]

      # Maj du buffer
      buf$::audace(bufNo) load $fileimg

      # Ajoute au header les nouveaux kwd
      foreach vals $::tools_cata::new_astrometry($id_current_image) {
         buf$::audace(bufNo) setkwd $vals
      }

      # Mise a jour de certains kwd
      ::bdi_tools_astrometry::set_fits_key "IAU_CODE" $::bdi_tools_astrometry::rapport_uai_code "string" "Observatory IAU Code" ""
      ::bdi_tools_astrometry::set_fits_key "OBSERVER" $::bdi_tools_astrometry::rapport_observ "string" "Observer name" ""
      ::bdi_tools_astrometry::set_fits_key "INSTRUME" $::bdi_tools_astrometry::rapport_instru "string" "Instrument" ""

      # Ajout des statistiques par image de la reduction astrom dans l'entete de l'image
      set err [catch {set imgstats $::bdi_tools_astrometry::tabdate($dateiso)} msg]
      if {$err == 0} {
         # ASTROMETRY
         if {$::bdi_tools_astrometry::update_bdi_astrom_key == 1} {
            ::bdi_tools_astrometry::set_fits_key "BDDIMAGES ASTROMETRY" "FINAL" "string" "Astrometry performed" ""
         }
         # Nb Ref
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES NBREF" [lindex $imgstats 1] "int" "Nb astrometric ref stars" ""
         # Rho mean
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RES_MEAN" [lindex $imgstats 2] "float" "Mean residuals on ref stars" "arcsec"
         # Rho stdev
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RES_STDEV" [lindex $imgstats 3] "float" "Stdev residuals on ref stars" "arcsec"
         # Mean res RA
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RES_RA_MEAN" [lindex $imgstats 4] "float" "Mean residuals on RA of ref stars" "arcsec"
         # Mean res DEC
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RES_DEC_MEAN" [lindex $imgstats 5] "float" "Mean residuals on DEC of ref stars" "arcsec"
         # Stdev res RA
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RES_RA_STDEV" [lindex $imgstats 6] "float" "Stdev residuals on RA of ref stars" "arcsec"
         # Stdev res DEC
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RES_DEC_STDEV" [lindex $imgstats 7] "float" "Stdev residuals on DEC of ref stars" "arcsec"
         # Mean RA
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RA_MEAN" [lindex $imgstats 8] "float" "Mean RA of ref stars" "arcsec"
         # Mean DEC
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES DEC_MEAN" [lindex $imgstats 9] "float" "Mean DEC of ref stars" "arcsec"
         # Stdev RA
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES RA_STDEV" [lindex $imgstats 10] "float" "Stdev RA of ref stars" "arcsec"
         # Stdev DEC
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES DEC_STDEV" [lindex $imgstats 11] "float" "Stdev DEC of ref stars" "arcsec"
         # Mean mag
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES MAG_MEAN" [lindex $imgstats 12] "float" "Mean magnitude of ref stars" "arcsec"
         # Stdev mag
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES MAG_STDEV" [lindex $imgstats 13] "float" "Stdev magnitude of ref stars" "arcsec"
         # Mean err x
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES ERR_X_MEAN" [lindex $imgstats 14] "float" "Mean X error of ref stars" "arcsec"
         # Mean err y
         ::bdi_tools_astrometry::set_fits_key "BDDIMAGES ERR_Y_MEAN" [lindex $imgstats 15] "float" "Mean Y error of ref stars" "arcsec"

         # TODO : fwhm_mean
         # TODO : fwhm_std
         # TODO : seeing (fwhm * facteur d echelle)
         # TODO : CATAASTROM liste unique  de l'ensemble des catalogues dont on puise la position des etoiles de reference
      }

      # Recharge le tabkey
      set tabkey [::bdi_tools_image::get_tabkey_from_buffer]

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
      ::tools_cata::save_cata $::bdi_gui_cata::cata_list($id_current_image) $tabkey $cataxml

      # Maj  ::tools_cata::img_list
      set current_image [::bddimages_liste::lupdate $current_image idbddimg $idbddimg]
      set current_image [::bddimages_liste::lupdate $current_image tabkey $tabkey]
      set ::tools_cata::img_list [lreplace $::tools_cata::img_list [expr $id_current_image - 1] [expr $id_current_image - 1] $current_image]

      #return

   }

   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]

}


#----------------------------------------------------------------------------
# Tools
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
## Formatage d'une cle=valeur pour ajouter a l'entete FITS d'une image
#  @return void
proc ::bdi_tools_astrometry::set_fits_key { kwd val type comment unit } {

   global audace

   # Recupere la liste des kwd
   set buflist [buf$::audace(bufNo) getkwds]

   # Efface la cle si elle existe
   if {[lsearch -exact $buflist ${kwd}] >= 0} {
      buf$::audace(bufNo) delkwd ${kwd}
   }

   # Insere la cle si sa valeur est definie
   if {[string length ${val}] > 0} {
      buf$::audace(bufNo) setkwd [list ${kwd} ${val} ${type} ${comment} ${unit}]
   }

}


#----------------------------------------------------------------------------
## Conversion d'un angle decimal exprime en heure au format sexagesimal
#  @param val real Angle decimal en heure a convertir
#  @return string Angle au format sexagesimal (h m s)
proc ::bdi_tools_astrometry::convert_txt_hms { val } {

   set h [expr $val/15.]
   set hint [expr int($h)]
   set r [expr $h - $hint]
   set m [expr $r * 60.]
   set mint [expr int($m)]
   set r [expr $m - $mint]
   set sec [format "%.4f" [expr $r * 60.]]
   if {$hint < 10.0} {set hint "0$hint"}
   if {$mint < 10.0} {set m "0$mint"}
   if {$sec  < 10.0} {set sec "0$sec"}
   return "$hint $mint $sec"

}


#----------------------------------------------------------------------------
## Conversion d'un angle decimal exprime en degres au format sexagesimal
#  @param val real Angle decimal en degres a convertir
#  @return string Angle au format sexagesimal (d m s)
proc ::bdi_tools_astrometry::convert_txt_dms { val } {

   set s "+"
   if {$val < 0} {
      set s "-"
   }
   set aval [expr abs($val)]
   set d [expr int($aval)]
   set r [expr $aval - $d]
   set m [expr $r * 60.]
   set mint [expr int($m)]
   set r [expr $m - $mint]
   set sec [format "%.3f" [expr $r * 60.]]
   if {$d    < 10.0} {set d "0$d"}
   if {$mint < 10.0} {set m "0$mint"}
   if {$sec  < 10.0} {set sec "0$sec"}
   return "$s$d $mint $sec"

}
