## @file bdi_tools_astroid_tank.tcl
#  @brief     Outils d&eacute;di&eacute;s aux mesures astrom&eacute;triques et photom&eacute;triques en mode multithread automatique et no console
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_astroid_tank.tcl]
#  @endcode

# $Id: bdi_tools_astroid_tank.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_astroid_tank
# @brief Outils d&eacute;di&eacute;s aux mesures astrom&eacute;triques et photom&eacute;triques en mode multithread automatique et no console
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_astroid_tank {
   
   variable to_insert
   variable to_insert_list

   variable astrom_mask
   variable astrom_saturation
   variable cata_science
   variable cata_ref

   variable bddname

   # Nombre max d'images pour priam
   variable MAX_IMG 300
   # Nombre max de source de reference pour priam
   variable MAX_SOURCES_REF 100 
   # Nombre max de source de reference pour priam
   variable MIN_SOURCES_REF 3 
   # Nombre max de source scientifiques pour priam
   variable MAX_SOURCES_SCIENCE 50

}



proc ::bdi_tools_astroid_tank::init_all {  } {

   global audace
   global bddconf

   set ::tcl_precision 17

   # Config audace
   source [file join $audace(rep_home) audace.ini]

   # Config external
   source [file join $audace(rep_home) tank.ini]

  ::bddimages_sql::mysql_init

   # Fichier de config XML a charger
   set ::bdi_tools_xml::xmlConfigFile [file join $audace(rep_home) bddimages_ini.xml]

   # Chargement et connection a la bdd
   set bddconf(current_config) [::bdi_tools_config::load_config $::bdi_tools_astroid_tank::bddname]

   set bddconf(bufno)    $audace(bufNo)
   set bddconf(visuno)   $audace(visuNo)
   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
   set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]
   set bddconf(extension_bdd) ".fits.gz"
   set bddconf(extension_tmp) ".fit"

   if {![info exists ::bdi_tools_appariement::skybot_wait]}                   { set ::bdi_tools_appariement::skybot_wait 0 }
   if {![info exists ::bdi_tools_astroid_tank::asteroid_listing_rootfilename]} { set ::bdi_tools_astroid_tank::asteroid_listing_rootfilename "" }
   if {![info exists ::bdi_tools_astroid_tank::image_rootfilename]}            { set ::bdi_tools_astroid_tank::image_rootfilename "" }

   # Phase de test :
   if {$::bdi_tools_astroid::test==1} {
      gren_info "#####################################"
      gren_info "### MASTER: PHASE DE TEST : ACTIF ###"
      gren_info "#####################################"
      set ::bdi_tools_astroid::nb_threads  1
      set ::bdi_tools_astroid::nb_get_list 1
      set ::bdi_tools_astroid::infini      0
      set ::bdi_tools_astroid::log         1
      set ::bdi_tools_astroid::log_wcs     1
      set ::bdi_tools_astroid::log_cata    1
   }
   

}






proc ::bdi_tools_astroid_tank::init_master {  } {

   global bddconf
   global audace

   ::bdi_tools_astroid_tank::init_all


   set ::bdi_tools_astroid_tank::tank_final_error 99

   
   if { $::bdi_tools_astroid_tank::work_mode == "CPA" } {
      set block [list {1 {BDDIMAGES TYPE} = IMG} \
                      {2 {BDDIMAGES STATE} = CORR} \
                      {3 {BDDIMAGES ASTROID} != FINAL} \
                      {4 {BDDIMAGES ASTROID} != CPA} \
                      {5 {BDDIMAGES ASTROID} != E} \
                      {6 {BDDIMAGES ASTROID} != CE} \
                      {7 {BDDIMAGES ASTROID} != CPE} \
                      {8 {BDDIMAGES ASTROID} != DISCARD} \
                ]
   }
   if { $::bdi_tools_astroid_tank::work_mode == "CP" } {
      set block [list {1 {BDDIMAGES TYPE} = IMG} \
                      {2 {BDDIMAGES STATE} = CORR} \
                      {3 {BDDIMAGES ASTROID} != FINAL} \
                      {4 {BDDIMAGES ASTROID} != CPA} \
                      {4 {BDDIMAGES ASTROID} != CP} \
                      {5 {BDDIMAGES ASTROID} != E} \
                      {6 {BDDIMAGES ASTROID} != CE} \
                      {7 {BDDIMAGES ASTROID} != CPE} \
                      {8 {BDDIMAGES ASTROID} != DISCARD} \
                ]
   }
   if { $::bdi_tools_astroid_tank::work_mode == "C" } {
      set block [list {1 {BDDIMAGES TYPE} = IMG} \
                      {2 {BDDIMAGES STATE} = CORR} \
                      {3 {BDDIMAGES ASTROID} != FINAL} \
                      {4 {BDDIMAGES ASTROID} != CPA} \
                      {4 {BDDIMAGES ASTROID} != CP} \
                      {4 {BDDIMAGES ASTROID} != C} \
                      {5 {BDDIMAGES ASTROID} != E} \
                      {6 {BDDIMAGES ASTROID} != CE} \
                      {7 {BDDIMAGES ASTROID} != CPE} \
                      {8 {BDDIMAGES ASTROID} != DISCARD} \
                ]
   }
   
   # MODE DEBUG
   if {1==0} {
      gren_info "ATTENTION MODE DEBUG REQUETE INFINIE"
      set block [list {1 {BDDIMAGES TYPE} = IMG} \
                      {2 {BDDIMAGES STATE} = CORR} \
                      {3 {BDDIMAGES ASTROID} != FINAL} \
                      {4 {BDDIMAGES ASTROID} != DISCARD} \
                ]
      
   }
   
   
   
   # Chargement liste intelligente
   set ::bdi_tools_astroid_tank::priority [list \
                     [list type intellilist] \
                     [list name tank] \
                     [list datemin {}] \
                     [list datemax {}] \
                     [list midi 12] \
                     [list type_req_check 1] \
                     [list type_requ {toutes les}] \
                     [list choix_limit_result 1] \
                     [list limit_result $::bdi_tools_astroid::nb_get_list] \
                     [list type_result elements] \
                     [list type_select DATE-OBS] \
                     [list reqlist [list {1 {BDDIMAGES TYPE} = IMG} \
                                         {2 {BDDIMAGES STATE} = CORR} \
                                         {3 {BDDIMAGES ASTROID} = P} \
                                   ] \
                     ]   ]

   set ::bdi_tools_astroid_tank::intellilists [list \
                     [list type intellilist] \
                     [list name tank] \
                     [list datemin {}] \
                     [list datemax {}] \
                     [list midi 12] \
                     [list type_req_check 1] \
                     [list type_requ {toutes les}] \
                     [list choix_limit_result 1] \
                     [list limit_result $::bdi_tools_astroid::nb_get_list] \
                     [list type_result elements] \
                     [list type_select DATE-OBS] \
                     [list reqlist $block ]   ]

   #gren_info "MASTER: intellilist = $::bdi_tools_astroid_tank::intellilists"

   gren_info "MASTER: nb_threads = $::bdi_tools_astroid::nb_threads"

   gren_info "MASTER: On entre dans $bddconf(dirtmp)"
   cd $bddconf(dirtmp)

   set f [open [file join $bddconf(dirtmp) "files_inserted.txt"] "w"]
   close $f

  # Sauvegarde d un listing asteroide
  if {$::bdi_tools_astroid_tank::asteroid_listing_rootfilename != ""} {
     if {![file exists $::bdi_tools_astroid_tank::asteroid_listing_rootfilename]} {
        set chan [open $::bdi_tools_astroid_tank::asteroid_listing_rootfilename a+]
        set char ", "
        set line "dateobs"
        foreach key [::bdi_tools_psf::get_otherfields_astroid] {
           append line "${char}${key}"
        }
        append line "${char}exposure"
        append line "${char}bin"
        append line "${char}fwhmx_arcsec"
        append line "${char}fwhmy_arcsec"
        append line "${char}fwhm_arcsec"
        puts $chan $line
        close $chan
     }
  }

  # Sauvegarde des wcs des images
  if {$::bdi_tools_astroid_tank::wcs_rootfilename != ""} {
     set ::bdi_tools_astroid_tank::wcs_listkey [list DATE-OBS NAXIS1 NAXIS2 BIN1 BIN2 PIXSIZE1 PIXSIZE2 CDELT1 CDELT2 CROTA1 CROTA2 FOCLEN TELESCOP]
     if {![file exists $::bdi_tools_astroid_tank::wcs_rootfilename]} {
         set chan [open $::bdi_tools_astroid_tank::wcs_rootfilename a+]
         set cpt 0
         set line ""
         foreach key $::bdi_tools_astroid_tank::wcs_listkey {
            append line [expr {$cpt == 0 ? "$key" : ", $key"}]
            incr cpt
         }
         puts $chan $line
        close $chan
     }
  }
  
  

   if {![info exists ::bdi_tools_astroid_tank::ftp]}      { set ::bdi_tools_astroid_tank::ftp 0 }
   if {![info exists ::bdi_tools_astroid_tank::host]}     { set ::bdi_tools_astroid_tank::ftp 0 }
   if {![info exists ::bdi_tools_astroid_tank::host]}     { set ::bdi_tools_astroid_tank::ftp 0 }
   if {![info exists ::bdi_tools_astroid_tank::login]}    { set ::bdi_tools_astroid_tank::ftp 0 }
   if {![info exists ::bdi_tools_astroid_tank::password]} { set ::bdi_tools_astroid_tank::ftp 0 }
   if {![info exists ::bdi_tools_astroid_tank::distdir]}  { set ::bdi_tools_astroid_tank::ftp 0 }

}





proc ::bdi_tools_astroid_tank::init_slave { threadId } {

   global conf
   global private
   global audace
   global bddconf
   
   package require math::statistics

   ::bdi_tools_astroid_tank::init_all
   
   ::tools_cata::inittoconf
   ::bdi_tools_appariement::inittoconf

   # ici on ne veut pas inserer le cata lors de l appel a get_cata
   # on prefere l inserer a la fin une fois tout termine pour que 
   # son header soit conforme
   set ::tools_cata::create_cata 0 

   set refcatalist {}
   if {$::tools_cata::use_usnoa2    == 1} { lappend refcatalist [list USNOA2    $conf(bddimages,catfolder,usnoa2)]   }
   if {$::tools_cata::use_ucac2     == 1} { lappend refcatalist [list UCAC2     $conf(bddimages,catfolder,ucac2)]    }
   if {$::tools_cata::use_ucac3     == 1} { lappend refcatalist [list UCAC3     $conf(bddimages,catfolder,ucac3)]    }
   if {$::tools_cata::use_ucac4     == 1} { lappend refcatalist [list UCAC4     $conf(bddimages,catfolder,ucac4)]    }
   if {$::tools_cata::use_ppmx      == 1} { lappend refcatalist [list PPMX      $conf(bddimages,catfolder,ppmx)]     }
   if {$::tools_cata::use_ppmxl     == 1} { lappend refcatalist [list PPMXL     $conf(bddimages,catfolder,ppmxl)]    }
   if {$::tools_cata::use_tycho2    == 1} { lappend refcatalist [list TYCHO2    $conf(bddimages,catfolder,tycho2)]   }
   if {$::tools_cata::use_nomad1    == 1} { lappend refcatalist [list NOMAD1    $conf(bddimages,catfolder,nomad1)]   }
   if {$::tools_cata::use_2mass     == 1} { lappend refcatalist [list 2MASS     $conf(bddimages,catfolder,2mass)]    }
   if {$::tools_cata::use_wfibc     == 1} { lappend refcatalist [list WFIBC     $conf(bddimages,catfolder,wfibc)]    }
   if {$::tools_cata::use_sdss      == 1} { lappend refcatalist [list SDSS      $conf(bddimages,catfolder,sdss)]     }
   if {$::tools_cata::use_panstarrs == 1} { lappend refcatalist [list PANSTARRS $conf(bddimages,catfolder,panstarrs)]}
   if {$::tools_cata::use_gaia1     == 1} { lappend refcatalist [list GAIA1     $conf(bddimages,catfolder,gaia1)]    }
   set ::bdi_tools_appariement::calibwcs_param(catalist) $refcatalist

   # On fait la mesure des photocentres dans TANK et non dans get_cata
   set ::bdi_tools_psf::use_psf 0

   # Creation buffer
   set audace(bufNo) [::buf::create]
   # No visu
   set audace(visuNo) 0

   ::audace::psf_init $audace(visuNo)

   set private(psf_toolbox,$audace(visuNo),radius)               $::bdi_tools_astroid_tank::radius             
   set private(psf_toolbox,$audace(visuNo),globale,min)          $::bdi_tools_astroid_tank::globale_min        
   set private(psf_toolbox,$audace(visuNo),globale,max)          $::bdi_tools_astroid_tank::globale_max        
   set private(psf_toolbox,$audace(visuNo),globale,confidence)   $::bdi_tools_astroid_tank::globale_confidence 
   set private(psf_toolbox,$audace(visuNo),saturation)           $::bdi_tools_astroid_tank::saturation         
   set private(psf_toolbox,$audace(visuNo),threshold)            $::bdi_tools_astroid_tank::threshold          
   set private(psf_toolbox,$audace(visuNo),globale)              $::bdi_tools_astroid_tank::globale            
   set private(psf_toolbox,$audace(visuNo),ecretage)             $::bdi_tools_astroid_tank::ecretage           
   set private(psf_toolbox,$audace(visuNo),methode)              $::bdi_tools_astroid_tank::methode            
   set private(psf_toolbox,$audace(visuNo),photom,r1)            $::bdi_tools_astroid_tank::photom_r1          
   set private(psf_toolbox,$audace(visuNo),photom,r2)            $::bdi_tools_astroid_tank::photom_r2          
   set private(psf_toolbox,$audace(visuNo),photom,r3)            $::bdi_tools_astroid_tank::photom_r3          
   set private(psf_toolbox,$audace(visuNo),globale,arret)        $::bdi_tools_astroid_tank::globale_arret      
   set private(psf_toolbox,$audace(visuNo),globale,nberror)      $::bdi_tools_astroid_tank::globale_nberror    
   set private(psf_toolbox,$audace(visuNo),read_out_noise)       $::bdi_tools_astroid_tank::read_out_noise             
   set private(psf_toolbox,$audace(visuNo),beta)                 $::bdi_tools_astroid_tank::beta             
   set private(psf_toolbox,$audace(visuNo),ajust_beta)           $::bdi_tools_astroid_tank::ajust_beta             

   ::bdi_tools_astroid_tank::change_tmp $threadId

   # Creation du fichier de conf sextractor s'il n'existe pas, a partir de la version template bddimages/config/config.sex.template
   set sex_config_file [file join $audace(rep_home) tank_config.sex]
   if {![file exists $sex_config_file]} {
     file copy -force [file join $audace(rep_plugin) tool bddimages config config.sex.template] $sex_config_file
   }
   # Copie du fichier de conf sextractor depuis audace(rep_home)/tank_config.sex vers bddconf(dirtmp)/config.sex
   ::bdi_tools_astrometry::copy_sextractor_config_file $sex_config_file $bddconf(dirtmp)

}






proc ::bdi_tools_astroid_tank::set_master_env {  } {

   set ::bddimages::nogui 1




}








proc ::bdi_tools_astroid_tank::set_own_env {  } {

   global audace

   set ::bddimages::nogui 1
   ::bdi_tools_astroid::set_own_env
   # Outils WCS
   puts "Outils WCS"
   uplevel #0 "source \"[file join $audace(rep_install) gui audace wcs_tools.tcl]\""
   # Outils FOCAS
   puts "Outils FOCAS"
   uplevel #0 "source \"[file join $audace(rep_install) gui audace focas.tcl]\""
   # Outils Sextractor
   puts "Outils Sextractor"
   uplevel #0 "source \"[file join $audace(rep_install) gui audace sextractor.tcl]\""
   # Bddimages GO
   puts "Outils Bddimages"
   uplevel #0 "source \"[file join $audace(rep_plugin) tool bddimages bddimages_go.tcl]\""
   ::bddimages::ressource_tools

}






proc ::bdi_tools_astroid_tank::get_list { p_list } {

   upvar $p_list img_list
   global bddconf

   set result [::bddimages_define::get_list_box_champs]

   set type [::bddimages_liste_gui::get_val_intellilist $::bdi_tools_astroid_tank::priority "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $::bdi_tools_astroid_tank::priority]
   if {[llength $img_list]>0} {return}      

   set type [::bddimages_liste_gui::get_val_intellilist $::bdi_tools_astroid_tank::intellilists "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $::bdi_tools_astroid_tank::intellilists]

}




proc ::bdi_tools_astroid_tank::extract_tabsources_by_flagastrom { flagastrom p_tabsources } {

   global threadId
   upvar $p_tabsources tabsources
   array unset tabsources
   set nbts 0
   foreach s [lindex $::tools_cata::current_listsources 1] {
      set p [lsearch -index 0 $s "ASTROID"]
      if {$p != -1} {
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set ar [::bdi_tools_psf::get_val othf "flagastrom"]
         if {$ar == $flagastrom} {
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set p [lsearch -index 0 $s $ac]
            if {$p!=-1 && $err_psf == "-"} {
               set obj [lindex $s $p]
               set name [::manage_source::naming $s $ac]
               set tabsources($name) $obj
               incr nbts
            } else {
               gren_info "p / err_psf = $p / $err_psf\n"
               # y a pas forcement d erreur
               #gren_erreur "trouver l'erreur...\n"
            }
         }
      }
   }
   #gren_info "tabsources = [array get tabsources]\n"
   gren_info "[gren_date] SLAVE \[$threadId\]:\[$::bdi_tools_astroid_tank::work_mode\] Nb references stars for astrometry = $nbts\n"

   return $nbts
}





proc ::bdi_tools_astroid_tank::extract_tabsources_by_flagastrom_obsolete { flagastrom p_tabsources } {

   global threadId
   upvar $p_tabsources tabsources
   array unset tabsources

   set sources [lindex $::tools_cata::current_listsources 1]

   # tri dans le sens des etoiles les plus brillantes
   set id -1
   array unset sort_sources
   foreach s $sources {
      incr id
      set p [lsearch -index 0 $s "ASTROID"]
      if {$p != -1} {
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set mag [::bdi_tools_psf::get_val othf "mag"]
         lappend sort_sources [list $id $mag]
      }
   }
   set sort_sources [lsort -real -increasing -index 1 $sort_sources]

   # Selection des MAX_SOURCES_REF etoiles les plus brillantes
   set cptRef 0 
   foreach l $sort_sources {
      if {$cptRef <= $::bdi_tools_astroid_tank::MAX_SOURCES_REF} {
         set id [lindex $l 0]
         set s [lindex $sources $id]
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set ar [::bdi_tools_psf::get_val othf "flagastrom"]
         if {$ar == $flagastrom} {
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set p [lsearch -index 0 $s $ac]
            if {$p!=-1 && $err_psf == "-"} {
               set obj [lindex $s $p]
               set name [::manage_source::naming $s $ac]
               set tabsources($name) $obj
               incr cptRef
            } else {
               gren_info "p / err_psf = $p / $err_psf\n"
               # y a pas forcement d erreur
               #gren_erreur "trouver l'erreur...\n"
            }
         }
      } else {
        break
      }
   }
   
   #gren_info "tabsources = [array get tabsources]\n"
   set nb [expr [llength [array get tabsources]]/ 2]
   gren_info "[gren_date] SLAVE \[$threadId\]:\[$::bdi_tools_astroid_tank::work_mode\] Nb referencse stars for astrometry = $nb\n"
   return
}





proc ::bdi_tools_astroid_tank::extract_tabsources_by_idimg { p_tabsources } {
   
   upvar $p_tabsources tabsources
   array unset tabsources

   set cpt 0
   foreach s [lindex $::tools_cata::current_listsources 1] {
      incr cpt
      set p [lsearch -index 0 $s "ASTROID"]
      if {$p != -1} {
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set ar [::bdi_tools_psf::get_val othf "flagastrom"]
         if {$ar == "R" || $ar == "S"} {
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set p [lsearch -index 0 $s $ac]
            if {$p != -1 && $err_psf == "-"} {
               set obj [lindex $s $p]
               set name [::manage_source::naming $s $ac]
               set tabsources($name) [list $ar $ac $othf]
            } else {
               gren_info "p / err_psf = $p / $err_psf\n"
               # y a pas forcement d erreur
               #gren_erreur "trouver l'erreur...\n"
            } 
         }
      } else {
         #gren_info "La source $cpt n'est pas un objet ASTROID \n"
      }
   }
   return
}



proc ::bdi_tools_astroid_tank::extract_priam_results { file } {

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
         # Debut image
         set filename $val
         incr id_current_image
         set catascience($id_current_image) ""
         set cataref($id_current_image) ""
         set ::tools_cata::new_astrometry($id_current_image) ""
         gets $chan success
         if {$success != "SUCCESS"} {
            incr nberr
            continue
         }
      }

      if {$key == "END"} {
      }

      for {set k 0 } { $k<$n } {incr k} {
         set kwd [lindex $astrom(kwds) $k]
         if {$kwd == $key} {
            set type [lindex $astrom(types) $k]
            set unit [lindex $astrom(units) $k]
            set comment [lindex $astrom(comments) $k]
            # TODO ::bdi_tools_astrometry::extract_priam_results :: Modif du tabkey de chaque image de img_list
            foreach kk [list FOCLEN RA DEC CRVAL1 CRVAL2 CROTA1 CROTA2] {
               if {$kk == $key } {
                  set val [format "%.10f" $val]
               }
            }
            foreach kk [list CDELT1 CDELT2 CD1_1 CD1_2 CD2_1 CD2_2] {
               if {$kk == $key } {
                  set val [format "%.10e" $val]
               }
            }
            foreach kk [list CRPIX1 CRPIX2] {
               if {$kk == $key } {
                  set val [format "%.3f" $val]
               }
            }
            lappend ::tools_cata::new_astrometry($id_current_image) [list $kwd $val $type $unit $comment]
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
   #                      "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" "name" "flagastrom" \
   #                      "flagphotom" "cataastrom" "cataphotom"]

   set ex [::bddimages_liste::lexist $::tools_cata::current_image "listsources"]
   if {$ex != 0} {
      gren_erreur "Attention listsources existe dans img_list et ce n'est plus necessaire\n"
   }

   set id_current_image 1
   set current_listsources $::tools_cata::current_listsources
   set n [llength $catascience($id_current_image)]
   set fields [lindex $current_listsources 0]
   set sources [lindex $current_listsources 1]

   set list_id_science [::tools_cata::get_id_astrometric "S" current_listsources]
   foreach l $list_id_science {
      set id     [lindex $l 0]
      set idcata [lindex $l 1]
      set ar     [lindex $l 2]
      set ac     [lindex $l 3]
      set name   [lindex $l 4]
      set x  [lsearch -index 0 $catascience($id_current_image) $name]
      if {$x>=0} {
         set data [lindex [lindex $catascience($id_current_image) $x] 1]
         set ra      [lindex $data 0]
         set dec     [lindex $data 1]
         set res_ra  [lindex $data 2]
         set res_dec [lindex $data 3]
         set s [lindex $sources $id]
         set omc_ra  ""
         set omc_dec ""
         set x [lsearch -index 0 $s $ac]
         if {$x>=0} {
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

   set ::tools_cata::current_listsources [list $fields $sources]

}







proc ::bdi_tools_astroid_tank::waiting_skybot { date } {
   
   global threadId
   set cpt 0

   while { 1 == 1 } {

      set erreur [ catch { vo_skybotstatus text [mc_date2iso8601 $date ]} statut ]
      set flag [lindex $statut 1]
# flag 1 ticket 1434977209935 result {# Status | Date_start | Date_end | obj_aster | obj_planet | obj_satel | obj_comet | Last_update ; uptodate | 2010-02-12 12:00:00 | 2020-02-20 12:00:00 | 681493 | 8 | 33 | 0 | 2015-06-04 14:55:03 }
# flag -1 ticket 1434977259535 result {SkyBoT status -> The SkyBoT database does not cover this epoch (1600-04-04 00:00:00)}
# flag == 1 et c est bon
      set rep []
      # Ca marche
      if {$flag == 1} { break }
      
      # Ca marche pas mais on ne veut pas attendre
      if { $::bdi_tools_appariement::skybot_wait == 0 } { break }
      
      # on attend que ca marche : 5 secondes
      if {$cpt == 0} {
         gren_info "[gren_date] SLAVE \[$threadId\]:\[$::bdi_tools_astroid_tank::work_mode\] En attente de Skybot..."
      }
      after 5000
      incr cpt
      
   }   

}






proc ::bdi_tools_astroid_tank::verif_key_wcs { p_local_work_mode tabkey key } {

   upvar $p_local_work_mode local_work_mode 
   
   if {$local_work_mode == "E"} {return}  
   if {![::bddimages_liste::lexist $tabkey $key]} {
      set local_work_mode "E"
      return -code 1 "$key not exist"
   }
   set xkey [lindex [::bddimages_liste::lget $tabkey $key] 1]
   if {![string is double $xkey]} {
      set local_work_mode "E" 
      return -code 1 "$key not double = $xkey"
   }
   
}







# procedure lancee par les esclaves qui lance le travail a faire
# Cas du programme autonome de traitement automatique
# multithread no GUI
proc ::bdi_tools_astroid_tank::launch_on_slave {  } {

   global audace
   global bddconf
   global threadId
   global threadDispo


   tsv::set dispo $threadId 0

   set local_work_mode $::bdi_tools_astroid_tank::work_mode

   set ::tools_cata::current_listsources ""
   set filename [::bddimages_liste::lget $::tools_cata::current_image "filename"]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set file [file join $dirfilename $filename]
   set idbddimg [::bddimages_liste::lget $::tools_cata::current_image idbddimg]

   if {$::bdi_tools_astroid::log} {gren_info "----------------------------------------"}
   gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] id=$idbddimg PID=[pid] filename=$file"

   
   if {$::bdi_tools_astroid::log} {
      set tt_load   0
      set tt_wcs    0
      set tt_cata   0
      set tt_psf    0
      set tt_priam  0
      set tt_insf   0
      set tt_insc   0

      set mem_load  0
      set mem_wcs   0
      set mem_cata  0
      set mem_psf   0
      set mem_priam 0
      set mem_insf  0
      set mem_insc  0
   }
   set bdi_photometry ""
   set bdi_astrometry ""
   set bdi_cataastrom ""
   set img_fwhm ""
   set img_zmag ""

   if {$::bdi_tools_astroid::log} {set tt0 [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem0 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

   set ::tools_cata::file [file join $bddconf(dirbase) $dirfilename $filename]

   set ::tools_cata::ra       [lindex [::bddimages_liste::lget $tabkey RA]       1]
   set ::tools_cata::dec      [lindex [::bddimages_liste::lget $tabkey DEC]      1]
   set ::tools_cata::dateobs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
   set ::tools_cata::crota1   [lindex [::bddimages_liste::lget $tabkey CROTA1]   1]
   set ::tools_cata::crota2   [lindex [::bddimages_liste::lget $tabkey CROTA2]   1]
   set ::tools_cata::cdelt1   [lindex [::bddimages_liste::lget $tabkey CDELT1]   1]
   set ::tools_cata::cdelt2   [lindex [::bddimages_liste::lget $tabkey CDELT2]   1]
   set ::tools_cata::pixsize1 [lindex [::bddimages_liste::lget $tabkey PIXSIZE1] 1]
   set ::tools_cata::pixsize2 [lindex [::bddimages_liste::lget $tabkey PIXSIZE2] 1]
   set ::tools_cata::foclen   [lindex [::bddimages_liste::lget $tabkey FOCLEN]   1]
   set ::tools_cata::exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
   set ::tools_cata::naxis1   [lindex [::bddimages_liste::lget $tabkey NAXIS1]   1]
   set ::tools_cata::naxis2   [lindex [::bddimages_liste::lget $tabkey NAXIS2]   1]
   set ::tools_cata::xcent    [expr $::tools_cata::naxis1/2.0]
   set ::tools_cata::ycent    [expr $::tools_cata::naxis2/2.0]

   buf$audace(bufNo) load $::tools_cata::file

   # Duree et memoire
   if {$::bdi_tools_astroid::log} {set tt_load [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_load [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}



# -----------------------------------------------------------------------------



   # Verification des champs pour WCS
   set err [catch {::bdi_tools_astroid_tank::verif_key_wcs local_work_mode $tabkey RA       } msg_ra      ]
   set err [catch {::bdi_tools_astroid_tank::verif_key_wcs local_work_mode $tabkey DEC      } msg_dec     ]
   set err [catch {::bdi_tools_astroid_tank::verif_key_wcs local_work_mode $tabkey PIXSIZE1 } msg_pixsize1]
   set err [catch {::bdi_tools_astroid_tank::verif_key_wcs local_work_mode $tabkey PIXSIZE2 } msg_pixsize2]
   set err [catch {::bdi_tools_astroid_tank::verif_key_wcs local_work_mode $tabkey FOCLEN   } msg_foclen  ]
   if {$local_work_mode == "E"} {
      gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Erreur champs ra dec pixsize1 pixsize2 foclen : $msg_ra $msg_dec $msg_pixsize1 $msg_pixsize2 $msg_foclen"
   }

   if {![info exists ::bdi_tools_astroid::limit_foclen]} {
      gren_info "******************************************************************"
      gren_info "* La variable ::bdi_tools_astroid::limit_foclen n est pas definie."
      gren_info "* veuillez ajouter la ligne suivante dans le fichier .ini"
      gren_info "* set ::bdi_tools_astroid::limit_foclen {3 20}"
      gren_info "******************************************************************"
   }

   if { $::tools_cata::foclen < [lindex $::bdi_tools_astroid::limit_foclen 0] } { 
      set local_work_mode "E"
      gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Erreur champs foclen trop petit $::tools_cata::foclen < Limit [lindex $::bdi_tools_astroid::limit_foclen 0]"
   }
   if { $::tools_cata::foclen > [lindex $::bdi_tools_astroid::limit_foclen 1] } { 
      set local_work_mode "E"
      gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Erreur champs foclen trop grnad $::tools_cata::foclen > Limit [lindex $::bdi_tools_astroid::limit_foclen 1]"
   }

   if {$local_work_mode != "E"} {
      gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Keys verified : RA=$::tools_cata::ra DEC=$::tools_cata::dec PS1=$::tools_cata::pixsize1 PS2=$::tools_cata::pixsize2 FOCLEN=$::tools_cata::foclen DATE-OBS=$::tools_cata::dateobs"
   }

   # -----------------------------------------------------------------------------
   # Creation du CATA ?
   if {$::tools_cata::use_cata_if_exist == 1} {
      set local_create_cata 0
      set err [catch {set nb_sources_cata [::bdi_gui_cata::load_cata]} msg]
      if {$err==0 && $nb_sources_cata>0} {
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:      Lecture du CATA existant: $msg"}
         gren_info "[gren_date] SLAVE \[$threadId\]:      ROLLUP = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
      } else {
         set local_create_cata 1
      }
      
   } else { 
      set local_create_cata 1
   }

   if {$local_create_cata == 1} {

      # -----------------------------------------------------------------------------
      # Creation du WCS
      if {$local_work_mode == "CPA" \
       || $local_work_mode == "CP"  \
       || $local_work_mode == "C" } {

         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Creation du WCS "}
         set err [catch { ::tools_cata::get_wcs $threadId $::bdi_tools_astroid::log_wcs} msg ]
         if {$err} {
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs : err = $err"
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs : msg = $msg"
            set local_work_mode "E"
         }
      }

      # Duree et memoire
      if {$::bdi_tools_astroid::log} {set tt_wcs [clock clicks -milliseconds]}
      if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_wcs [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

      # -----------------------------------------------------------------------------
      # Existance de skybot
      if {$::tools_cata::use_skybot == 1} {
         ::bdi_tools_astroid_tank::waiting_skybot $::tools_cata::dateobs
      }

      # -----------------------------------------------------------------------------
      # Creation du CATA
      if {$local_work_mode == "CPA" \
       || $local_work_mode == "CP"  \
       || $local_work_mode == "C" } {

         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Creation du CATA ? "}
         set err [catch { ::tools_cata::get_cata $threadId $::bdi_tools_astroid::log_cata} msg ]
         if {$err} {
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata : err = $err"
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata : msg = $msg"
            set local_work_mode "E"
         }
         gren_info "[gren_date] SLAVE \[$threadId\]:      ROLLUP = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

      }

      # Duree et memoire
      if {$::bdi_tools_astroid::log} {set tt_cata [clock clicks -milliseconds]}
      if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_cata [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   }



   # -----------------------------------------------------------------------------
   # Mesure des Photocentres
   if {$local_work_mode == "CPA" \
    || $local_work_mode == "CP" } {

      if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Mesure des Photocentres ? $::bdi_tools_astroid_tank::methode"}

      set err [catch { ::bdi_tools_psf::get_psf_listsources ::tools_cata::current_listsources } msg ]
      
      if {$err} {
         gren_info "[gren_date] SLAVE \[$threadId\]:      Photocentre : err = $err"
         gren_info "[gren_date] SLAVE \[$threadId\]:      Photocentre : msg = $msg"
         set local_work_mode "CE"
      } else {
         set bdi_photometry $::bdi_tools_astroid_tank::methode
         # mesure de la fwhm de l image
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Mesure de la FWHM et ZMAG de l image"}
         set r [::bdi_tools_astroid_tank::get_info_sky ::tools_cata::current_listsources $::tools_cata::exposure $::tools_cata::cdelt1 $::tools_cata::cdelt2]
         lassign $r img_fwhm img_zmag
      }

      # Enregistrement de la liste listsources
      #if {$::bdi_tools_astroid::log} {
      #   set f [open [file join $bddconf(dirtmp) "listsources.tcl"] "a"]
      #   puts $f "set listsources \[list $::tools_cata::current_listsources \]"
      #   close $f
      #}

   }

   # Duree et memoire
   if {$::bdi_tools_astroid::log} {set tt_psf [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_psf [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}



# -----------------------------------------------------------------------------



   # Lancement de Priam
   if { $local_work_mode == "CPA" } {

      if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Mesure Astrometrique ? "}

      # Definition du mask
      set mx_min $::bdi_tools_astroid_tank::astrom_mask
      set mx_max [expr $::tools_cata::naxis1 - $::bdi_tools_astroid_tank::astrom_mask]
      set my_min $::bdi_tools_astroid_tank::astrom_mask
      set my_max [expr $::tools_cata::naxis2 - $::bdi_tools_astroid_tank::astrom_mask]

      # Defini les champs et les sources de l'image courante
      set fields [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:      ASTROMETRY : [llength $sources]"}

      # Flag des sources comme SCIENCE ou REFERENCE
      set sort_ref_sources ""
      set ids -1
      set cptSci 1
      foreach s $sources {
         incr ids
         set posastroid [lsearch -index 0 $s "ASTROID"]
         if {$posastroid != -1} {
            set astroid [lindex $s $posastroid]
            set othf    [lindex $astroid 2]
            set px      [::bdi_tools_psf::get_val othf "xsm"]
            set py      [::bdi_tools_psf::get_val othf "ysm"]
            set pixmax  [::bdi_tools_psf::get_val othf "pixmax"]
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            
            set accept 1

            # Applique le mask si demande
            if {$px <= $mx_min || $px >= $mx_max || $py <= $my_min || $py >= $my_max} { set accept 0 }
            # Applique la limite de saturation si demande
            if {$pixmax > $::bdi_tools_astroid_tank::astrom_saturation} { set accept 0 }
            
            if {$accept} {
               set change 0
               # Flag la source comme SCIENCE
               if {$cptSci <= $::bdi_tools_astroid_tank::MAX_SOURCES_SCIENCE} {
                  set p [lsearch -index 0 $s $::bdi_tools_astroid_tank::cata_science]
                  if {$p != -1} {
                     set ar "S"
                     set ac $::bdi_tools_astroid_tank::cata_science
                     ::bdi_tools_psf::set_by_key othf "flagastrom" $ar
                     ::bdi_tools_psf::set_by_key othf "cataastrom" $ac
                     set change 1
                     incr cptSci
                  }
               }
               # garde les REFERENCE de cot�
               if {$err_psf == "-"} {
                  set p [lsearch -index 0 $s $::bdi_tools_astroid_tank::cata_ref]
                  if {$p != -1} {

                     if {1==1} {
                        # Mag Catalogue 
                        set cata [lindex $s $p]
                        set mag  [lindex $cata 1 3]
                     } else {
                        # Mag Mesuree 
                        set mag  [::bdi_tools_psf::get_val othf "mag"]
                     }

                     lappend sort_ref_sources [list $ids $mag]
                  }
                  # Si la source est SCIENCE
                  if {$change == 1} {
                     set astroid [lreplace $astroid 2 2 $othf]
                     set s [lreplace $s $posastroid $posastroid $astroid]
                     set sources [lreplace $sources $ids $ids $s]
                  }
               }
            }
         }
      }

      #gren_info "-------------------------------\n"
      # tri dans le sens des etoiles les plus brillantes
      set sort_ref_sources [lsort -real -increasing -index 1 $sort_ref_sources]
      #gren_info "Nb ref sources : [llength $sort_ref_sources]\n"
      
      # Flag des sources comme REFERENCE
      set cptRef 1
      foreach l $sort_ref_sources {
         if {$cptRef > $::bdi_tools_astroid_tank::MAX_SOURCES_REF} break
         set ids [lindex $l 0]
         set s   [lindex $sources $ids]
         set posastroid [lsearch -index 0 $s "ASTROID"]
         set astroid [lindex $s $posastroid]
         set othf [lindex $astroid 2]
         ::bdi_tools_psf::set_by_key othf "flagastrom" "R"
         ::bdi_tools_psf::set_by_key othf "cataastrom" $::bdi_tools_astroid_tank::cata_ref
         set astroid [lreplace $astroid 2 2 $othf]
         set s [lreplace $s $posastroid $posastroid $astroid]
         set sources [lreplace $sources $ids $ids $s]
         incr cptRef
      }
      set rang [expr $cptRef -1]
      #gren_info "mag ensemble : \n"
      #gren_info "mag ensemble premier mag  : [lindex $sort_ref_sources { 0 1 } ]\n"
      #gren_info "mag ensemble dernier rang : $rang \n"

      if {1==0} {
         gren_info "sort_ref_sources  : $sort_ref_sources ]\n"
         gren_info "cptRef   ids   mag\n"
         set cptRef 1
         foreach l $sort_ref_sources {
            set ids [lindex $l 0]
            set mag [lindex $l 1]
            gren_info "$cptRef   $ids   $mag\n"
            incr cptRef
         }
      }
      
      set l [lindex $sort_ref_sources [expr $rang-1] ]
      set ids [lindex $l 0]
      set mag [lindex $l 1]
      #gren_info "mag ensemble dernier mag  : $mag\n"
      #gren_info "mag ensemble dernier mag : [lindex $sort_ref_sources [lindex $sort_ref_sources [expr $rang-1] ] 1 ]\n"
      #gren_info "mag ensemble dernier mag : [lindex $sort_ref_sources { [expr $rang-1] 1 } ]\n"

      #gren_info "-------------------------------\n"
      
      


      set ::tools_cata::current_listsources [list $fields $sources]
      # Creation du fichier de conditions observationnelles: cnd.obs
      ::bdi_tools_priam::create_cndobs ::tools_cata::current_image
      # Recupere les sources de reference
      array unset tabsources_ref
      set nbts [::bdi_tools_astroid_tank::extract_tabsources_by_flagastrom "R" tabsources_ref]
      if {$nbts < $::bdi_tools_astroid_tank::MIN_SOURCES_REF} {
         set local_work_mode "CPE"
         gren_info "[gren_date] SLAVE \[$threadId\]:      ASTROMETRY ... Erreur : Not enough source ref"         
      } else {

         # Creation du catalogue local: local.cat
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Creation du catalogue local: local.cat "}
         ::bdi_tools_priam::create_localcat tabsources_ref

         # Creation du fichier de mesures: science.mes
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Creation du fichier de mesures: science.mes"}
         ::bdi_tools_priam::create_sciencemes

         # Creation de chaque bloc de science+ref pour chaque image
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Creation de chaque bloc de science+ref pour chaque image"}
         array unset tabsources_img
         ::bdi_tools_astroid_tank::extract_tabsources_by_idimg tabsources_img
         ::bdi_tools_priam::add_newsciencemes ::tools_cata::current_image tabsources_img

         # Creation du fichier de commande Priam pour l'image courante: cmd.priam
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Creation du fichier de commande Priam pour l'image courante: cmd.priam"}
         ::bdi_tools_priam::create_cmdpriam 1 $::bdi_tools_astrometry::polydeg $::bdi_tools_astrometry::use_refraction $::bdi_tools_astrometry::use_eop

         # Execution de Priam
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Execution de Priam"}
         set priam_result_file [::bdi_tools_priam::launch_priam]

         # Extraction des resultats de l'astrometrie
         if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Extraction des resultats de l'astrometrie"}
         if {[file exists $priam_result_file]} {
            set err [catch { ::bdi_tools_astroid_tank::extract_priam_results $priam_result_file } msg ]
            if {$err} {
               set local_work_mode "CPE"
               gren_info "[gren_date] SLAVE \[$threadId\]:      ASTROMETRY ... Erreur : $priam_result_file: $msg"
            } else {
               set bdi_astrometry  "Y"
               set bdi_cataastrom  $::bdi_tools_astroid_tank::cata_ref
            }
         } else {
            set local_work_mode "CPE"
            gren_info "[gren_date] SLAVE \[$threadId\]:      ASTROMETRY ... Erreur : $priam_result_file"
         }
      }

   }

   # Duree et memoire
   if {$::bdi_tools_astroid::log} {set tt_priam [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_priam [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}


# -----------------------------------------------------------------------------



   # On insere l image dans la base avec le nouveau FLAG pour ASTROID
   if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Flag ASTROID ? "}

   set key [list "BDDIMAGES ASTROID" $local_work_mode "string" "ASTROID performed" ""]
   buf$::audace(bufNo) delkwd "BDDIMAGES ASTROID"
   buf$::audace(bufNo) setkwd $key

   set key [list "BDDIMAGES PHOTOMETRY" "TANK" "string" "Photometry performed" ""]
   buf$::audace(bufNo) delkwd "BDDIMAGES PHOTOMETRY"
   buf$::audace(bufNo) setkwd $key

   set key [list "BDDIMAGES ASTROMETRY" "TANK" "string" "Astrometry performed" ""]
   buf$::audace(bufNo) delkwd "BDDIMAGES ASTROMETRY"
   buf$::audace(bufNo) setkwd $key

   set key [list "BDDIMAGES CATAASTROM" $bdi_cataastrom "string" "Catalog used for astrometry" ""]
   buf$::audace(bufNo) delkwd "BDDIMAGES CATAASTROM"
   buf$::audace(bufNo) setkwd $key

   # !!! ----------------------------------------------------------------
   # !!! Le lreplace pour mettre a jour une cle ne marche pas: ca decale progressivement les champs dans la cle (sauf la valeur)
   # !!! Exemple:
   # !!!    1ere fois: BDDIMAGES CATAASTROM = UCAC4     Catalog used for astrometry
   # !!!    xeme fois: BDDIMAGES CATAASTROM = UCAC4     [      ] [     ] [    ] [   ] [  ]
   # !!! ----------------------------------------------------------------
         #set key [buf$::audace(bufNo) getkwd "BDDIMAGES ASTROID"]
         #set key [lreplace $key 1 1 $local_work_mode]
         #buf$::audace(bufNo) setkwd $key
         #
         #set key [buf$::audace(bufNo) getkwd "BDDIMAGES PHOTOMETRY"]
         #set key [lreplace $key 1 1 $bdi_photometry]
         #buf$::audace(bufNo) setkwd $key
         #
         #set key [buf$::audace(bufNo) getkwd "BDDIMAGES ASTROMETRY"]
         #set key [lreplace $key 1 1 $bdi_astrometry]
         #buf$::audace(bufNo) setkwd $key
         #
         #set key [buf$::audace(bufNo) getkwd "BDDIMAGES CATAASTROM"]
         #set key [lreplace $key 1 1 $bdi_cataastrom]
         #buf$::audace(bufNo) setkwd $key



# -----------------------------------------------------------------------------



   # Enregistrement de l image
   if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Enregistrement de l image ? "}

   # Insertion de l image dans la base 
   set err [catch { set filename [::tools_cata::save_current_image_from_buffer_to_inco $idbddimg $threadId] } msg ]

   if {$err} {
      gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_tmp : err = $err"
      gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_tmp : msg = $msg"
      exit
      tsv::set dispo $threadId 1
      return
   }

   # Duree et memoire
   if {$::bdi_tools_astroid::log} {set tt_insf [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_insf [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}



# -----------------------------------------------------------------------------



   # Enregistrement du cata
   if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Enregistrement du cata ? "}
   if {$local_work_mode == "CPA" \
    || $local_work_mode == "CP"  \
    || $local_work_mode == "C"  \
    || $local_work_mode == "CE"  \
    || $local_work_mode == "CPE" } {

      set cataxml "[file join $bddconf(dirinco) [file rootname [file rootname $filename]]]_cata.xml"
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      ::tools_cata::save_cata_to_tmp $::tools_cata::current_listsources $tabkey $cataxml
   } else {
      set cataxml ""
   }

   # Duree et memoire
   if {$::bdi_tools_astroid::log} {set tt_insc [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_insc [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}



# -----------------------------------------------------------------------------


   # Donnees partagees entre les thread
   tsv::linsert common to_insert_list end [list $idbddimg $filename $cataxml $img_fwhm $img_zmag]

   # Duree et memoire
   if {$::bdi_tools_astroid::log} {set tt_fin [clock clicks -milliseconds]}
   if {$::bdi_tools_astroid::log} {set info [exec cat /proc/[pid]/status ] ; set mem_fin [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}



# -----------------------------------------------------------------------------



   # Log et final
   if {$::bdi_tools_astroid::log} {

      set tt_total  [format "%5.1f" [expr ($tt_fin   - $tt0) / 1000.0]]
      set tt_insc   [format "%5.1f" [expr ($tt_insc  - $tt_insf) / 1000.0]]
      set tt_insf   [format "%5.1f" [expr ($tt_insf  - $tt_priam) / 1000.0]]
      set tt_priam  [format "%5.1f" [expr ($tt_priam - $tt_psf) / 1000.0]]
      set tt_psf    [format "%5.1f" [expr ($tt_psf   - $tt_cata) / 1000.0]]
      set tt_cata   [format "%5.1f" [expr ($tt_cata  - $tt_wcs) / 1000.0]]
      set tt_wcs    [format "%5.1f" [expr ($tt_wcs   - $tt_load) / 1000.0]]
      set tt_load   [format "%5.1f" [expr ($tt_load  - $tt0) / 1000.0]]

      set mem_total  [format "%5.1f" [expr $mem_fin   - $mem0]]
      set mem_insc   [format "%5.1f" [expr $mem_insc  - $mem_insf]]
      set mem_insf   [format "%5.1f" [expr $mem_insf  - $mem_priam]]
      set mem_priam  [format "%5.1f" [expr $mem_priam - $mem_psf]]
      set mem_psf    [format "%5.1f" [expr $mem_psf   - $mem_cata]]
      set mem_cata   [format "%5.1f" [expr $mem_cata  - $mem_wcs]]
      set mem_wcs    [format "%5.1f" [expr $mem_wcs   - $mem_load]]
      set mem_load   [format "%5.1f" [expr $mem_load  - $mem0]]

      gren_info "[gren_date] SLAVE \[$threadId\]:      timing (s)  : total=$tt_total, load=$tt_load,  wcs=$tt_wcs,  cata=$tt_cata,  psf=$tt_psf,  priam=$tt_priam,  ifits=$tt_insf, icata=$tt_insc\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      Memory (Mo) : total=$mem_total, load=$mem_load,  wcs=$mem_wcs,  cata=$mem_cata,  psf=$mem_psf,  priam=$mem_priam,  ifits=$mem_insf, icata=$mem_insc, current=$mem_fin\n"
   }

   if { $local_work_mode == $::bdi_tools_astroid_tank::work_mode } {
      if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Update Database for Sky Cover "}
      ::bdi_tools_astroid_tank::update_images $threadId $::tools_cata::dateobs $img_fwhm $img_zmag "SUCCESS"
      gren_info "[gren_date] SLAVE \[$threadId\]:      SUCCESS"
   } else {
      if {$::bdi_tools_astroid::log} {gren_info "[gren_date] SLAVE \[$threadId\]:\[$local_work_mode\] Update Database for Sky Cover "}
      ::bdi_tools_astroid_tank::update_images $threadId $::tools_cata::dateobs $img_fwhm $img_zmag "ERROR" 
      gren_info "[gren_date] SLAVE \[$threadId\]:      Termine & ERROR"
   }
   tsv::set dispo $threadId 1
   return -code 0

}






proc ::bdi_tools_astroid_tank::change_tmp { threadId } {

   global bddconf
   set bddconf(dirtmp) [file join $bddconf(dirtmp) tank $threadId]
   createdir_ifnot_exist $bddconf(dirtmp)
   gren_info "TRHEAD \[$threadId\]:  : $bddconf(dirtmp) :: [pwd]"
}


proc ::bdi_tools_astroid_tank::check_dir { threadId } {
   global bddconf
   puts "TRHEAD \[$threadId\]: CHECK:  $bddconf(dirtmp) :: [pwd]  "
}






proc ::bdi_tools_astroid_tank::insert_file { { nb "" } } {

   global bddconf

   if {$::bdi_tools_astroid::test==1} {return}
   set nb_to_insert [llength [tsv::get common to_insert_list]]
   if {$nb_to_insert==0} {return}

   puts "[gren_date] MASTER\[0\]:      INSERT_FILE"
   #gren_info "MASTER TO_INSERT $nb_to_insert"

   set f [open [file join $bddconf(dirtmp) "files_inserted.txt"] "a"]
   
   #foreach t [tsv::get common to_insert_list] {
   #   set l [tsv::lpop common to_insert_list 0]
   #   set idbddimg [lindex $l 0]
   #   set filename [lindex $l 1]
   #   set cataxml  [lindex $l 2]
   #   gren_info "TO_INSERT: ($idbddimg) FITS:$filename CATA:$cataxml"
   #}
   #gren_info "MASTER TO_INSERT ... WORKING... "
   set id 0
   foreach t [tsv::get common to_insert_list] {
      
      incr id

      set l [tsv::lpop common to_insert_list 0]
      set idbddimg [lindex $l 0]
      set filename [lindex $l 1]
      set cataxml  [lindex $l 2]
      set img_fwhm [lindex $l 3]
      set img_zmag [lindex $l 4]

      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]
      set err ""
      set pass "yes"

      # verification avant insertion
      if {$fileimg == -1} {
         set err "Fichier image inexistant ($idbddimg)  \n"
         set pass "no"
      }
      if {![file exists $filename]} {
         set err "$err : Fichier $filename inexistant\n"
         set pass "no"
      }
      if {[file tail $fileimg] != [file tail $filename]} {
         set err "$err : Fichier $filename != $fileimg\n"
         set pass "no"
      }
      if {$cataxml == ""} {
         set err "$err : Fichier cata inexistant\n"
      }
      #gren_info "TO_INSERT pop : [file tail $fileimg] : PASS=$pass : ERR=$err"
      

      #if {$::bdi_tools_astroid_tank::image_rootfilename != ""} {
      #   puts "[gren_date] MASTER\[0\]:      current_image = $::tools_cata::current_image"
      #}
      set idbddimg ""
      # Ok on est bon pour l insertion
      if {$pass == "yes"} {
         # efface l image dans la base et le disqueMASTER TO_INSERT 
         #gren_info "[gren_date] MASTER                    bddimages_image_delete_fromsql"
         bddimages_image_delete_fromsql $ident
         #gren_info "[gren_date] MASTER                    bddimages_image_delete_fromdisk"
         bddimages_image_delete_fromdisk $ident
         # insere l image dans la base
         #gren_info "[gren_date] MASTER                    insertion_solo $filename"
         set err [catch {insertion_solo $filename} idbddimg ]
         #if {$err==0} { gren_info "TO_INSERT image inseree " }
         # Insertion du cata dans la base
         #gren_info "[gren_date] MASTER                    insertion_solo $cataxml"
         if {$cataxml != ""} {
            set err [ catch { insertion_solo $cataxml } msg ]
            if {$err} { set err "$err : Fichier cata $cataxml echec insertion\n" }
         }
         #if {[file exists $::bdi_tools_verif::test_file]} {
         #   gren_info "bddimages_catas_datainsert :6 EXIST $::bdi_tools_verif::test_file\n"
         #} else {
         #   gren_info "bddimages_catas_datainsert :6 NOT EXIST \n"
         #}

      }

      #gren_info "WORK ($idbddimg) FITS:$filename CATA:$cataxml ERR:$err"
      puts $f "($idbddimg) FITS:$filename CATA:$cataxml ERR:$err"

      
      
      
      #------------------------------------------------------------



      if {$nb_to_insert == $id && $idbddimg!="" && ($::bdi_tools_astroid_tank::image_rootfilename != "" || $::bdi_tools_astroid_tank::wcs_rootfilename != "") } {

         buf$bddconf(bufno) load $fileimg

      }


      #------------------------------------------------------------



      if {$nb_to_insert == $id && $::bdi_tools_astroid_tank::wcs_rootfilename != "" && $idbddimg!=""} {

         set chan [open $::bdi_tools_astroid_tank::wcs_rootfilename a]

         set tabkey [::bdi_tools_image::get_tabkey_from_buffer]
         set listkey [list DATE-OBS NAXIS1 NAXIS2 BIN1 BIN2 PIXSIZE1 PIXSIZE2 CDELT1 CDELT2 CROTA1 CROTA2 FOCLEN TELESCOP]

         set cpt 0
         set line ""
         foreach key $::bdi_tools_astroid_tank::wcs_listkey {
            set xkey [lindex [::bddimages_liste::lget $tabkey $key] 1]
            append line [expr {$cpt == 0 ? "$xkey" : ", $xkey"}]
            incr cpt
         }
         puts $chan $line

         close $chan

     }


      #------------------------------------------------------------


      # Sauvegarde d une image jpeg
      # puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg : $nb_to_insert == $id ($::bdi_tools_astroid_tank::image_rootfilename)"
      if {$nb_to_insert == $id && $::bdi_tools_astroid_tank::image_rootfilename != "" && $idbddimg!=""} {
         #puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg demarre ($idbddimg)"
         # on charge l image : $idbddimg
         set ident [bddimages_image_identification $idbddimg]
         #puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg : ident == $ident"
         set fileimg  [lindex $ident 1]
         set filecata [lindex $ident 3]
         #puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg : fileimg == $fileimg"
         if {$fileimg == -1} {
            puts "[gren_date] MASTER\[0\]:      le fichier image est inconnu"
         }
         if {![file exists $fileimg]} {
            puts "[gren_date] MASTER\[0\]:      le fichier image n existe pas"
         }
         if {$fileimg != -1 && [file exists $fileimg]} {
            # puts "[gren_date] MASTER\[0\]: on charge le buffer"
            
            puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg : $::bdi_tools_astroid_tank::image_rootfilename"
            set err [catch {::bdi_tools_astroid_tank::image_to_www $fileimg $filecata $img_zmag $img_fwhm } msg ]
            if {$err!=0} {
               puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg echec err=$err"
               puts "[gren_date] MASTER\[0\]:      msg=$msg"
            } else {

               # Envoi par FTP
               if {$::bdi_tools_astroid_tank::ftp == 1} {
                  set svg_rootfilename "[file rootname $::bdi_tools_astroid_tank::image_rootfilename].svg"
                  set php_rootfilename "[file rootname $::bdi_tools_astroid_tank::image_rootfilename].php"
                  set err [catch { exec lftp -u $::bdi_tools_astroid_tank::login,$::bdi_tools_astroid_tank::password $::bdi_tools_astroid_tank::host -e "cd $::bdi_tools_astroid_tank::distdir ; put $::bdi_tools_astroid_tank::image_rootfilename ; put $svg_rootfilename ; put $php_rootfilename ; exit" } msg ]
                  if {$err!=1 && $err!=0} {
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : echec"
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : cmd = lftp -u $::bdi_tools_astroid_tank::login,$::bdi_tools_astroid_tank::password $::bdi_tools_astroid_tank::host -e \"cd $::bdi_tools_astroid_tank::distdir ; put $::bdi_tools_astroid_tank::image_rootfilename ; put $svg_rootfilename ; put $php_rootfilename ; exit\""
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : err = $err"
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : msg = $msg"
                  } else {
                      puts "[gren_date] MASTER\[0\]:      Send by FTP on $::bdi_tools_astroid_tank::host svg"
                  }
               }
               
            }

         } else {
            puts "[gren_date] MASTER\[0\]:      Sauvegarde d une image jpeg : $fileimg not exists "
         }
      }
      
      
      
      #------------------------------------------------------------



      # Sauvegarde d un listing asteroide
      if {$nb_to_insert == $id && $::bdi_tools_astroid_tank::asteroid_listing_rootfilename != "" && $idbddimg!=""} {
         #puts "[gren_date] MASTER\[0\]:      Save listing asteroide demarre"
         set ident [bddimages_image_identification $idbddimg]
         set fileimg  [lindex $ident 1]
         set filecata [lindex $ident 3]
         if {$filecata != -1 && [file exists $filecata]} {
            file copy -force -- $filecata [file join $bddconf(dirtmp) i_cata.xml.gz]
            file delete -force -- [file join $bddconf(dirtmp) i_cata.xml]
            ::gunzip [file join $bddconf(dirtmp) i_cata.xml.gz]
            #puts "[gren_date] MASTER\[0\]:      Save listing asteroide : filecata = [file join $bddconf(dirtmp) i_cata.xml]"
            set listsources [::tools_cata::get_cata_xml [file join $bddconf(dirtmp) i_cata.xml]]
            #puts "[gren_date] MASTER\[0\]:      Save listing asteroide : listsources = $listsources"
            set listsources [::manage_source::extract_sources_by_catalog $listsources "SKYBOT"]
            #puts "[gren_date] MASTER\[0\]:      Save listing asteroide : listsources = $listsources"
            set nbskybot    [::manage_source::get_nb_sources_by_cata $listsources "SKYBOT"]
            #puts "[gren_date] MASTER\[0\]:      Save listing asteroide   nbskybot : $nbskybot"
            #puts "[gren_date] MASTER\[0\]:      FINAL ROLLUP = [::manage_source::get_nb_sources_rollup $listsources]"
            #puts "[gren_date] MASTER\[0\]:      nbskybot=$nbskybot"
            if {$nbskybot>0} {
               set r [info_fichier $fileimg]
               set dateobs  [lindex $r 3]
               set tabkey   [lindex $r 6]
               set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
               set bin      [lindex [::bddimages_liste::lget $tabkey BIN1] 1]
               set cdelt1   [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
               set cdelt2   [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
               
               set chan [open $::bdi_tools_astroid_tank::asteroid_listing_rootfilename a+]
               set sources [lindex $listsources 1]
               set cpt 0
               foreach s $sources { 
                  # puts "[gren_date] MASTER\[0\]:      s=$s"
                  foreach cata $s {
                     if { [string toupper [lindex $cata 0]] == "ASTROID" } {
                        set othf [lindex $cata 2]
                        set char ", "
                        set line "$dateobs"
                        foreach key [::bdi_tools_psf::get_otherfields_astroid] {
                           set val [::bdi_tools_psf::get_val othf $key]
                           append line "${char}${val}"
                           switch $key {
                              "fwhmx" {set fwhmx_arcsec [expr $val*abs($cdelt1)*3600.0]}
                              "fwhmy" {set fwhmy_arcsec [expr $val*abs($cdelt2)*3600.0]}
                           }
                        }
                        set fwhm_arcsec  [format "%0.2f" [expr sqrt( (pow($fwhmx_arcsec,2) + pow($fwhmy_arcsec,2)) / 2.0 )]]
                        set fwhmx_arcsec [format "%0.2f" $fwhmx_arcsec]
                        set fwhmy_arcsec [format "%0.2f" $fwhmy_arcsec]
                        append line "${char}${exposure}"
                        append line "${char}${bin}"
                        append line "${char}${fwhmx_arcsec}"
                        append line "${char}${fwhmy_arcsec}"
                        append line "${char}${fwhm_arcsec}"
                        puts $chan $line
                     }
                  }
               }
               close $chan
               puts "[gren_date] MASTER\[0\]:      Save listing asteroide : $::bdi_tools_astroid_tank::asteroid_listing_rootfilename"


               # Envoi par FTP
               if {$::bdi_tools_astroid_tank::ftp == 1} {
                  set err [catch { exec lftp -u $::bdi_tools_astroid_tank::login,$::bdi_tools_astroid_tank::password $::bdi_tools_astroid_tank::host -e "cd $::bdi_tools_astroid_tank::distdir ; put $::bdi_tools_astroid_tank::asteroid_listing_rootfilename ; exit" } msg ]
                  if {$err!=1 && $err!=0} {
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : echec"
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : cmd = lftp -u $::bdi_tools_astroid_tank::login,$::bdi_tools_astroid_tank::password $::bdi_tools_astroid_tank::host -e \"cd $::bdi_tools_astroid_tank::distdir ; put $::bdi_tools_astroid_tank::asteroid_listing_rootfilename ; exit\""
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : err = $err"
                      puts "[gren_date] MASTER\[0\]:      Sending FTP : msg = $msg"
                  } else {
                      puts "[gren_date] MASTER\[0\]:      Send by FTP on $::bdi_tools_astroid_tank::host listing"
                  }
               }
               
            }
         }
      }

      if { $nb == 1 } { break }

   }
   close $f
}

#------------------------------------------------------------
## Recopie l'image de l'étoile dans block1 de l'onglet "images"
# @brief Cette fonction est activee avec le rafraichissemnt
# @param fileimg string nom du fichier image
# @param filecata string nom du fichier cata
#
proc ::bdi_tools_astroid_tank::image_to_www { fileimg filecata img_zmag img_fwhm } {
    
    global audace
    global bddconf
    
    if {$filecata != -1 && [file exists $filecata]} {

       #--   Arrete si pas d'image dans le buffer
       if {[ buf$bddconf(bufno) imageready]==0} {
          return
       }
       set img_path $::bdi_tools_astroid_tank::image_rootfilename
       #--   Definit les variables pour l'image SVG
       #--   L'image .jpg a le memes dimensions que l'image .fit
       set naxis1 [ buf$bddconf(bufno) getpixelswidth ]
       set naxis2 [ buf$bddconf(bufno) getpixelsheight ]


       file copy -force -- $filecata [file join $bddconf(dirtmp) i_cata.xml.gz]
       file delete -force -- [file join $bddconf(dirtmp) i_cata.xml]
       ::gunzip [file join $bddconf(dirtmp) i_cata.xml.gz]
       set listsources [::tools_cata::get_cata_xml [file join $bddconf(dirtmp) i_cata.xml]]
       set skybot   [::manage_source::extract_sources_by_catalog $listsources "SKYBOT"] 
       set nbskybot [::manage_source::get_nb_sources_by_cata $skybot "SKYBOT"]
       set ref      [::manage_source::extract_sources_by_catalog $listsources $::bdi_tools_astroid_tank::cata_ref]
       set nbref [::manage_source::get_nb_sources_by_cata $ref $::bdi_tools_astroid_tank::cata_ref]

       set list_skybot ""
       if {$nbskybot>0} {
          foreach s [lindex $skybot 1] {
             if {$s==""} {continue}
             set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
             if {$othf==""} {continue}
             #puts "ASTER S = $s"
             #puts "ASTER OTHF = $othf"

             set xsm [::bdi_tools_psf::get_val othf xsm]
             if {$xsm==""} {continue}
             set xsm [format "%.1f" $xsm]

             set ysm [::bdi_tools_psf::get_val othf ysm]
             if {$ysm==""} {continue}
             set ysm [format "%.1f" $ysm]

             set mag [::bdi_tools_psf::get_val othf mag]
             if {$mag==""} {continue}
             set mag [format "%.1f" $mag]

             set name [::bdi_tools_psf::get_val othf name]
             if {$name==""} {continue}

             puts "[gren_date] MASTER\[0\]:      SKYBOT : $name mag=$mag"
             lappend list_skybot [list $name $mag $xsm $ysm]
          }
       }

       set list_ref ""
       if {$nbref>0} {
          foreach s [lindex $ref 1] {
             set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
             #puts "STAR OTHF = $othf"

             set xsm [::bdi_tools_psf::get_val othf xsm]
             if {$xsm==""} {continue}
             set xsm [format "%.1f" $xsm]

             set ysm [::bdi_tools_psf::get_val othf ysm]
             if {$ysm==""} {continue}
             set ysm [format "%.1f" $ysm]

             set mag [::bdi_tools_psf::get_val othf mag]
             if {$mag==""} {continue}
             set mag [format "%.1f" $mag]

             set name [::bdi_tools_psf::get_val othf name]
             if {$name==""} {continue}

             lappend list_ref [list $name $mag $xsm $ysm]
          }
       }
       set list_ref [lsort -index 1 $list_ref]
       
       #--   Texte a ecrire
       set dateobs [string range [ lindex [ buf$bddconf(bufno) getkwd DATE-OBS ] 1 ] 0 18 ]
       set horodate [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC]

       #--   Sauve l'image au format JPEG
       set n1 [buf$bddconf(bufno) getpixelswidth]
       set n2 [buf$bddconf(bufno) getpixelsheight]
       set quality 60
       if {$n2>410} {
          set nn2 410
          set scale_factor [expr 1./$n2*$nn2]
          set nn1 [expr $n1 * $scale_factor]
          buf$bddconf(bufno) scale [list $scale_factor $scale_factor] 1
          set quality 70
       }
       lassign [buf$bddconf(bufno) stat] sh sb
       buf$bddconf(bufno) savejpeg $img_path $quality $sb $sh

       #--   Centre x et y du rond rouge : todo calculer cx et cy (peuvent etre des decimaux)
       #set cx    462
       #--   Attention dans le SVG y=0 est en haut
       #set cy    [expr { $naxis2-$cy } ]

       #--   Son rayon (fixe par defaut a 5 pix, sauf si on transmet une valeur differente
       #set radius 5 ; #--   pix
       #--   Scale de l'image, fixe par defaut a 1, sauf si on transmet une valeur differente
       #set scale 1 ; #--   facteur d'echelle
       #--  Note : si les naxis sont constants on peut aussi les mettre par defaut

       #--   Liste les arguments
       
       # format pour tablette tactile
       
       set data [list $dateobs $horodate $list_skybot $list_ref "$img_path" $nn1 $nn2 $n1 $n2]

       jpeg2svg $data $img_zmag $img_fwhm

       #buf$bddconf(bufno) save $::bdi_tools_astroid_tank::image_rootfilename
   }

}






#-----------------------------------------
#  jpeg2svg
#     Ecrit la surcouche SVG
#  Parameters : text to add, coords of red circle,
#               JPEG image path,
#              width & height of the image
#  Return : nothing
#  Note : si l'image a des dimensions constantes
#         elles peuvent etre ecrites en dur
#-----------------------------------------
proc jpeg2svg { data img_zmag img_fwhm {radius 10} {scale 1} } {

global audace conf bddconf

lassign $data dateobs horodate list_aster list_stars img_path width height naxis1 naxis2

set date_info "DATE-OBS $dateobs | FINALIZED $horodate"

#--   Isole le petit nom de l'image
set imageName [file tail $img_path]

set htm    "<?xml version='1.0' encoding='utf-8' standalone='no'?>\n"
#append htm "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>\n"
append htm "<svg width='${width}px' height='${height}px' preserveAspectRatio='xMinYMin meet' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>\n"
append htm "<defs>\n"
append htm "<style type='text/css'>\n"
append htm "<!\[CDATA\[\n"
#--   Tous les textes ont ce style
#append htm "text{fill:yellow;text-anchor:middle;font-size:24px;font-family:Courgette}"
#--   La class css .redcircle a ce style
append htm ".astercircle{fill:none;stroke:#fc9600;stroke-width:2.0}\n"
append htm ".starcircle{fill:none;stroke:blue;stroke-width:2.0}\n"
append htm ".astername{fill:#fc9600;text-anchor:start;font-family:Courgette;font-size:14px;font-weight: bold}\n"
append htm ".starname{fill:cyan;text-anchor:start;font-family:Courgette;font-size:14px;font-weight: bold}\n"
append htm ".date{fill:yellow;text-anchor:middle;font-size:14px;font-family:Courgette}\n"
append htm "\]\]>\n"
append htm "</style>\n"
#--   modele de cercle centre sur le coin gauche en haut ; il n'apparait pas car il n'a pas de css
append htm "<circle id='circle' cx='0' cy='0' r='${radius}px' />\n"
append htm "</defs>\n"

#--   Le facteur d'echelle s'applique a toute l'image
append htm "<g transform='scale($scale)' >\n"

#--   Integre l'image : le nom court suffit dans la mesure ou les deux sont dans le meme repertoire
append htm "<image x='0' y='0' width='$width' height='$height' xlink:href='$imageName' />\n"

#--   Place le cercle
foreach aster $list_aster {
   set name [lindex $aster 0]
   set mag  [lindex $aster 1]
   #puts "ASTER MAG = $mag"
   set cx   [expr [lindex $aster 2] / $naxis1 * $width]
   set cy   [expr $height - [lindex $aster 3] / $naxis2 * $height]

   if {0==1} {
      gren_info "SVG: LOG -----------------\n"
      gren_info "SVG: naxis1 = $naxis1\n"
      gren_info "SVG: naxis2 = $naxis2\n"
      gren_info "SVG: width  = $width\n"
      gren_info "SVG: height = $height\n"
      gren_info "SVG: $name  xraw = [lindex $aster 2]\n"
      gren_info "SVG: $name  yraw = [lindex $aster 3]\n"
      gren_info "SVG: $name  xtr  = $cx\n"
      gren_info "SVG: $name  ytr  = $cy\n"
      gren_info "SVG: LOG -----------------\n"
   }
   
   set t [split $name "_"]
   if {[llength $t] == 3} { set name [lindex $t 2] }
   if {[llength $t] == 4} { set name "[lindex $t 2]_[lindex $t 3]" }
   if {[llength $t] == 5} { set name "[lindex $t 2]_[lindex $t 3]_[lindex $t 4]" }
   set texte "$name $mag"
   append htm "<use xlink:href='#circle' class='astercircle' transform='translate($cx,$cy)'/>\n"
   append htm "<text class='astername' x='[expr { $cx+13 }]' y='[expr { $cy-11 }]'>$name</text>\n"
   append htm "<text class='astername' x='[expr { $cx+13 }]' y='[expr { $cy+5 }]'>$mag</text>\n"
}
set magmax 0
set magmin 99
set cpt 0
foreach star $list_stars {
   incr cpt
   set mag [lindex $star 1]
   if {$mag>$magmax} { set magmax $mag}
   if {$mag<$magmin} { set magmin $mag}
   
   #puts "STAR MAG = $mag"
   if {$cpt<50} {
      set cx  [expr [lindex $star 2] / $naxis1 * $width]
      set cy  [expr $height - [lindex $star 3] / $naxis2 * $height]
      set texte "$mag"
      append htm "<use xlink:href='#circle' class='starcircle' transform='translate($cx,$cy)'/>\n"
      append htm "<text class='starname' x='[expr { $cx+13 }]' y='[expr { $cy+5 }]'>$texte</text>\n"
   }
}

#--   Place le milieu du texte au milieu de width grace a text-anchor:middle et le bas du texte a 10 px du bas
set startx           0
set starty           [expr $height-20]
set width_rectangle  $width
set height_rectangle 20
set color "black"
append htm "<rect x='$startx' y='$starty' width='$width_rectangle' height='$height_rectangle' style='fill:$color'/>"
append htm "<text class='date' x='[expr { $width/2 }]' y='[expr { $height-5 }]'>$date_info</text>"

#--   Fermeture des balises
append htm "</g>"    ; # balise de scale
append htm "</svg>"

#--   Sauve l'image SVG dans le meme repertoire que l'image JPEG et sous le meme nom mais avec l'extension svg
regsub -all "jpg" $img_path "svg" file

set fid [open $file w]
puts $fid $htm
close $fid

regsub -all "jpg" $img_path "php" file
set fid [open $file w]
puts $fid "<?php"
puts $fid "\$dateimg=\"$dateobs\";"
puts $fid "\$datetank=\"$horodate\";"
puts $fid "\$nbaster=[llength $list_aster];"
puts $fid "\$nbstarref=[llength $list_stars];"
puts $fid "\$magmax=$magmax;"
puts $fid "\$magmin=$magmin;"
puts $fid "\$zmag=$img_zmag;"
puts $fid "\$fwhm=$img_fwhm;"
puts $fid "?>"
close $fid

#$rollup="SKYBOT 1 NOMAD1 28 UCAC4 57 USNOA2 60 TYCHO2 3 UCAC2 56 TOTAL 62";
#$etat="SUCCESS";
#$duree="95.7";


}








# Tue tous les thread sauf le principal      
proc kill_all_thread {  } {
   foreach threadName [thread::names] {
      ::thread::release $threadName
   }
}






proc ::bdi_tools_astroid_tank::go_master {  } {
    
   global bddconf
   
   gren_info "#####################################################"
   gren_info "                     T.A.N.K.                        "
   gren_info "   Traitement Automatique des images en mode No tK   "
   gren_info ""
   gren_info "Auteurs : Fred Vachier, Jerome Berthier & Alain Klotz"
   gren_info "#####################################################"

   # Initialisation des variables
   gren_info "Init:"
   ::bdi_tools_astroid_tank::init_master

   # Environement
   gren_info "Environement:"
   ::bdi_tools_astroid_tank::set_master_env

   array unset ::bdi_tools_astroid::tabthread
   array unset ::bdi_tools_astroid::res

   set ::bdi_tools_astroid::stop 0

   set tt0 [clock clicks -milliseconds]

   ::bdi_tools_astroid_tank::info_base

   set nbexistthread [llength [thread::names]]
   gren_info "*** $nbexistthread threads exists"

   set threadId -1
   foreach threadName [thread::names] {
      set ::bdi_tools_astroid::tabthread(id,$threadId) $threadName
      set ::bdi_tools_astroid::tabthread(name,$threadName) $threadId
      incr threadId -1
   }

   # 
   # Create threads
   # 

   for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {

      set threadName [thread::create {

         namespace eval ::console {
            proc affiche_resultat { msg } { puts "$msg" }
            proc affiche_erreur { msg } { puts "$msg" }
            proc affiche_debug { msg } { puts "$msg" }
         }

         thread::wait
      }]
      
      set ::bdi_tools_astroid::tabthread(id,$threadId) $threadName
      set ::bdi_tools_astroid::tabthread(name,$threadName) $threadId
      #gren_info "**** Existing threads: [::bdi_tools_astroid::get_list_threadId]"

      ::thread::send $threadName [list set threadId $threadId]
      ::bdi_tools_astroid::setenv $threadName $threadId

      thread::configure $threadName -unwindonerror 1
      thread::errorproc ::bdi_tools_astroid::logError
      
      ::thread::send $threadName "::bdi_tools_astroid_tank::set_own_env"
      ::thread::send $threadName [list namespace eval ::console { 
            proc affiche_resultat { msg } { puts "$msg" }
            proc affiche_erreur { msg } { puts "$msg" }
            proc affiche_debug { msg } { puts "$msg" }
         }
         ]
      ::thread::send $threadName [list ::bdi_tools_astroid_tank::init_slave $threadId]
      ::thread::send $threadName [list puts [pwd]]
      
      puts "[gren_date] SLAVE \[$threadId\]: Started thread"
      #gren_info "*** Started thread $threadId"
   }




   # On recalcule le nombre de thread existant/manquant
   set texist 0
   for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
      set texist [expr $texist + [thread::exists $::bdi_tools_astroid::tabthread(id,$threadId)]]
   }
   set terr [expr $::bdi_tools_astroid::nb_threads - $texist]

   # Condition de sortie
   gren_info " ---------------"
   gren_info " nb_threads = $::bdi_tools_astroid::nb_threads"
   gren_info " texist     = $texist"
   gren_info " terr       = $terr"
   gren_info " ---------------"

   if { $terr > 0} {
      gren_info "ERR : $terr THREAD manquant : On quitte..."
      exit
      #return -code $::bdi_tools_astroid_tank::tank_final_error
   } 




   # 
   # boucle de travail : tant que la liste intelligente renvoit du travail a faire
   # 
   tsv::set common to_insert_list ""

   while {$::bdi_tools_astroid::stop == 0} {


       # Insertion des dernieres images avant recuperation d une nouvelle liste
       ::bdi_tools_astroid_tank::insert_file

       # Arret demande
       if { [file exists [file join $bddconf(dirtmp) tank tank.stop]]} {
          gren_info "MASTER: Traitement ASTROID stop manuel"
          file delete [file join $bddconf(dirtmp) tank tank.stop]
          set stop 2
          break
       }

       # Pause demandee
       if {[file exists [file join $bddconf(dirtmp) tank tank.pause]]} {
          set out 1
          while {$out} {
             gren_info "MASTER: Traitement en PAUSE : Wait 10 sec..."
             after 10000
             if {![file exists [file join $bddconf(dirtmp) tank tank.pause]]} {break}
          }
       }

       # Extraction des images a traiter
       ::bdi_tools_astroid_tank::get_list ::tools_cata::img_list
       set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

       if {$::tools_cata::nb_img_list == 0} {
          if {$::bdi_tools_astroid::infini} {
             gren_info "[gren_date] MASTER: Travail termine on attend 5 minutes"
             after 300000
             continue 
          } else {
             gren_info ""
             gren_info ""
             gren_info "MASTER: Travail termine On quitte Normalement"
             gren_info ""
             gren_info ""
             break 
          }
       }

       # Lancement du traitement de ce bloc
       gren_info ""
       gren_info ""
       gren_info "MASTER: NEW BLOCK"
       gren_info ""
       gren_info ""
       set idcata 0
       foreach ::tools_cata::current_image $::tools_cata::img_list {

          # Insertion d une seule image
          ::bdi_tools_astroid_tank::insert_file 1

          incr idcata

          set out 1

          # boucle d attente d un thread dispo
          while {$out} {

             if {$::bdi_tools_astroid::stop} {break}
             set threadName [::bdi_tools_astroid::get_dispo]
             if {$threadName == ""} {
                
                # Verification des thread mort
                set texist 0
                for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
                   set texist [expr $texist + [thread::exists $::bdi_tools_astroid::tabthread(id,$threadId)]]
                }

                #gren_info "Nb Thread exist = $texist / $::bdi_tools_astroid::nb_threads "
                if {$texist < $::bdi_tools_astroid::nb_threads} {
                   set terr [expr $::bdi_tools_astroid::nb_threads - $texist]
                   gren_info "\n\n Attention Erreur : Thread mort On se dirige vers la sortie"
                   set ::bdi_tools_astroid::stop 2
                   break
                }

                # Arret Manuel demande
                if {[file exists [file join $bddconf(dirtmp) tank tank.stop]]} { set ::bdi_tools_astroid::stop 1 }

                # Pause demandee
                if {[file exists [file join $bddconf(dirtmp) tank tank.pause]]} { set ::bdi_tools_astroid::stop 1 }

                # Pause 1 seconde
                after 1000

             } else {
                break
             }
          }

          # Arret demande
          if {$::bdi_tools_astroid::stop} {break}

          # Arret Manuel demande
          if {[file exists [file join $bddconf(dirtmp) tank tank.stop]]} { set ::bdi_tools_astroid::stop 1 }

          # Pause demandee
          if {[file exists [file join $bddconf(dirtmp) tank tank.pause]]} { set ::bdi_tools_astroid::stop 1 }


 #         gren_info "WORK $idcata"
          set threadId $::bdi_tools_astroid::tabthread(name,$threadName)
          set ex [thread::exists $threadName]
          if {$ex} {
             #::thread::send $threadName [list set bddconf(dirtmp) [file join $bddconf(dirtmp) tank $threadId]]
             ::thread::send $threadName [list set ::tools_cata::current_image $::tools_cata::current_image]
             after 500
             ::thread::send -async $threadName "::bdi_tools_astroid_tank::launch_on_slave" res($threadId)
             after 500
          }
          ::bdi_tools_astroid::set_progress $idcata $::tools_cata::nb_img_list
       }


      # Boucle d attente du maitre que tous les thread soient fini
      set out 1
      while {$out} {

         if {[::bdi_tools_astroid::get_nb_dispo] != $::bdi_tools_astroid::nb_threads} {

            # Insertion des dernieres images avant recuperation d une nouvelle liste
            ::bdi_tools_astroid_tank::insert_file

            # Verification des thread mort
            set texist 0
            for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
               set texist [expr $texist + [thread::exists $::bdi_tools_astroid::tabthread(id,$threadId)]]
            }
            #gren_info "* Nb Thread exist = $texist / $::bdi_tools_astroid::nb_threads "
            if {$texist < $::bdi_tools_astroid::nb_threads} {
               set terr [expr $::bdi_tools_astroid::nb_threads - $texist]
               gren_info "\n\n Attention erreur : Thread mort On se dirige verts la sortie"
               set ::bdi_tools_astroid::stop 2
               break
            }

            # Sinon on attend
            after 1000
            
         } else {
            break
         }
      }

      # Phase de test
      if {$::bdi_tools_astroid::test==1} {
         set ::bdi_tools_astroid::stop 1
         gren_info ""
         gren_info ""
         gren_info "MASTER: PHASE DE TEST : ON QUITTE"
         gren_info ""
         gren_info ""
      }

      # DEV: Arret volontaire
      # set ::bdi_tools_astroid::stop 1
   }
   
   

   # 
   # Attendre l arret de tous les threads
   # 
   #gren_info "MASTER: Stop : $::bdi_tools_astroid::stop"

   if {$::bdi_tools_astroid::stop!=2} {
#         puts "Dispo ?"
      set out 1
      while {$out} {

         # Verification des thread mort
         set texist 0
         for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
            set texist [expr $texist + [thread::exists $::bdi_tools_astroid::tabthread(id,$threadId)]]
         }
         if {$texist < $::bdi_tools_astroid::nb_threads} {
            set terr [expr $::bdi_tools_astroid::nb_threads - $texist]
            gren_info "\n\n Attention erreur : Thread mort On se dirige verts la sortie"
            break
         }

         # Verification du nombre de thread existant
         set threadName [::bdi_tools_astroid::get_nb_dispo]
         if {[::bdi_tools_astroid::get_nb_dispo] != $::bdi_tools_astroid::nb_threads} {
            ::bdi_tools_astroid_tank::insert_file
            after 1000
         } else {
            break
         }
      }
   }

   ::bdi_tools_astroid_tank::insert_file
   
   # DEV : sortie au bout d une image
   #return -code $::bdi_tools_astroid_tank::tank_final_error

   # 
   # Verification des thread mort
   # 
   set texist 0
   for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
      set texist [expr $texist + [thread::exists $::bdi_tools_astroid::tabthread(id,$threadId)]]
   }

   gren_info "thread en cours : $texist ** $::bdi_tools_astroid::nb_threads"

   if {$texist < $::bdi_tools_astroid::nb_threads} {

      set ::bdi_tools_astroid_tank::tank_final_error 1
      set terr [expr $::bdi_tools_astroid::nb_threads - $texist]
      gren_info "\n\n Attention erreur"
      gren_info "$terr THREAD manquant"
      gren_info "On attend la fin des autres thread et on sort"

      set out 1
      while {$out} {

         # on insere au cas ou il y aurait des donnees
         ::bdi_tools_astroid_tank::insert_file

         # arret Manuel
#           if {$::bdi_tools_astroid::stop} {break}

         # On calcule le nombre de thread dispo
         set tdispo [::bdi_tools_astroid::get_nb_dispo]

         # On recalcule le nombre de thread manquant
         set texist 0
         for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
            set texist [expr $texist + [thread::exists $::bdi_tools_astroid::tabthread(id,$threadId)]]
         }
         set terr [expr $::bdi_tools_astroid::nb_threads - $texist]

         # Condition de sortie
         gren_info "ERR : ---------------"
         gren_info "ERR : nb_threads = $::bdi_tools_astroid::nb_threads"
         gren_info "ERR : texist     = $texist"
         gren_info "ERR : terr       = $terr"
         gren_info "ERR : tdispo     = $tdispo"
         gren_info "ERR : ---------------"
         gren_info "ERR : Attendre [expr $::bdi_tools_astroid::nb_threads - $terr - $tdispo]"
         gren_info "ERR : ---------------"

         if { [expr $tdispo + $terr ] == $::bdi_tools_astroid::nb_threads} {
            gren_info "ERR : $terr THREAD manquant : On quitte..."
            set ::bdi_tools_astroid::stop 1
            break
         } 

         after 10000

      }

   }



   # 
   # detachement des threads
   # 

   gren_info "MASTER: Detachement des threads"
   catch {
      for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
         set threadName $::bdi_tools_astroid::tabthread(id,$threadId)
         set ex [thread::exists $threadName]
         # puts "\[$threadId\] exist ? = [thread::exists $threadName]"
         if {$ex} {
            ::thread::release $threadName
            # puts "\[$threadId\] release"
         }
      }
   }
   
   # 
   # Fin
   # 
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "MASTER: Traitement ASTROID complet en $tt sec "

   array unset ::bdi_tools_astroid::tabthread
   array unset ::bdi_tools_astroid::res
   unset ::bdi_tools_astroid::nb_threads

   return -code $::bdi_tools_astroid_tank::tank_final_error

   #
   #   Code de sortie sans erreur : 99
   #
   # Liste des causes de sortie en erreur
   #
   # Erreur : Libtt error #202:HÿâB Detail=pw 
   #   Cause possible : Toujours apres qu un thread demande d ecrire le buffer dans un fichier
   #   Consequence : Termine le programme
   #   Code d erreur : 0
   #
   # Thread Fantome :
   #    non repertorié
   #
   # Disparition de Thread 
   #   Cause possible : inconnue
   #   Consequence : continue le programme mais il manque un thread, arret demandé du programme
   #   Code d erreur : 1
   #
}
proc ::bdi_tools_astroid_tank::get_intellilist { block type_requ choix_limit_result limit_result } {

   return [list \
             [list type intellilist] \
             [list name tank] \
             [list datemin {}] \
             [list datemax {}] \
             [list midi 12] \
             [list type_req_check 1] \
             [list type_requ $type_requ] \
             [list choix_limit_result $choix_limit_result] \
             [list limit_result $limit_result] \
             [list type_result elements] \
             [list type_select DATE-OBS] \
             [list reqlist $block ] \
          ]
}

proc ::bdi_tools_astroid_tank::info_base {  } {

   if {$::bdi_tools_astroid::info_base!=1} { return }
   
   set tt0 [clock clicks -milliseconds]      

   set result [::bddimages_define::get_list_box_champs]

   gren_info "************************************\n"
   #gren_info "set il [list $il]\n"
   gren_info "Information sur les donnees de la base\n"

   set block {}
   set il       [::bdi_tools_astroid_tank::get_intellilist $block {toutes les} 0 0]
   set type     [::bddimages_liste_gui::get_val_intellilist $il "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $il]
   set total    [llength $img_list]
   gren_info "     NB TOTAL   : $total\n"

   set block [list {1 {BDDIMAGES ASTROID} = FINAL} \
             ]
   set il       [::bdi_tools_astroid_tank::get_intellilist $block {toutes les} 0 0]
   set type     [::bddimages_liste_gui::get_val_intellilist $il "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $il]
   set final    [llength $img_list]
   gren_info "     NB FINAL   : $final\n"

   set block [list {1 {BDDIMAGES ASTROID} = CPA} \
             ]
   set il       [::bdi_tools_astroid_tank::get_intellilist $block {toutes les} 0 0]
   set type     [::bddimages_liste_gui::get_val_intellilist $il "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $il]
   set cpa [llength $img_list]
   gren_info "     NB CPA     : $cpa\n"

   set block [list {1 {BDDIMAGES ASTROID} = E} \
                   {2 {BDDIMAGES ASTROID} = CE} \
                   {3 {BDDIMAGES ASTROID} = CPE} \
             ]
   set il       [::bdi_tools_astroid_tank::get_intellilist $block {n'importe laquelle des} 0 0]
   set type     [::bddimages_liste_gui::get_val_intellilist $il "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $il]
   set err [llength $img_list]
   gren_info "     NB ERROR   : $err\n"

   set block [list {1 {BDDIMAGES ASTROID} = P} \
             ]
   set il       [::bdi_tools_astroid_tank::get_intellilist $block {toutes les} 0 0]
   set type     [::bddimages_liste_gui::get_val_intellilist $il "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $il]
   set priority [llength $img_list]
   gren_info "     NB PRIORIY : $priority\n"

   set block [list {1 {BDDIMAGES TYPE}    = IMG} \
                   {2 {BDDIMAGES STATE}   = CORR} \
                   {3 {BDDIMAGES ASTROID} != FINAL} \
                   {4 {BDDIMAGES ASTROID} != CPA} \
                   {5 {BDDIMAGES ASTROID} != E} \
                   {6 {BDDIMAGES ASTROID} != CE} \
                   {7 {BDDIMAGES ASTROID} != CPE} \
                   {8 {BDDIMAGES ASTROID} != DISCARD} \
             ]
   set il       [::bdi_tools_astroid_tank::get_intellilist $block {toutes les} 0 0]
   set type     [::bddimages_liste_gui::get_val_intellilist $il "type"]
   set img_list [::bddimages_liste_gui::intellilist_to_imglist $il]
   set todo [llength $img_list]
   gren_info "     NB TODO    : $todo\n"

   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "[gren_date] MASTER: Travail termine en $tt_total secondes"
   gren_info "[gren_date]: INFOBASE: TOTAL=$total FINAL=$final CPA=$cpa ERROR=$err PRIORIY=$priority TODO=$todo ($tt_total sec)\n"
   gren_info "************************************\n"

}


# Mise a jour de la base : t60.images
proc ::bdi_tools_astroid_tank::update_images { threadId date fwhm zmag state } {

   if {![info exists ::bdi_tools_astroid_tank::skycover]} {return}
   
   if {$::bdi_tools_astroid_tank::skycover!=1} {return}
   
   # On met la date au format sql
   set date [string replace [string range $date 0 18] 10 10 " "]
   
   if { [string trim $fwhm] == "" } { set fwhm NULL }
   if { [string trim $zmag] == "" } { set zmag NULL }

   set sqlcmd "update ${::bdi_tools_astroid_tank::skycoverdb}.images set type=\"$state\", fwhm=$fwhm, zmag=$zmag where date=\"$date\";"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "[gren_date] SLAVE \[$threadId\]:      Erreur : update ${::bdi_tools_astroid_tank::skycoverdb}.images"
      gren_info "[gren_date] SLAVE \[$threadId\]:      SQL: $sqlcmd"
      gren_info "[gren_date] SLAVE \[$threadId\]:      err: $err"
      gren_info "[gren_date] SLAVE \[$threadId\]:      msg: $msg"
   } else {
      gren_info "[gren_date] SLAVE \[$threadId\]:      Update ${::bdi_tools_astroid_tank::skycoverdb}.images"
   }

}




proc ::bdi_tools_astroid_tank::get_info_sky { p_listsources exposure cdelt1 cdelt2 } {

   upvar $p_listsources listsources

   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   set tzmag ""
   set tfwhm ""
   foreach s $sources {
      set pos [lsearch -index 0 $s "ASTROID"]
      if { $pos == -1 } { continue }
      set othf  [::bdi_tools_psf::get_astroid_othf_from_source $s]
      #puts "A21: $othf"
      set mag   [::bdi_tools_psf::get_val othf "mag"]
      set flux  [::bdi_tools_psf::get_val othf "flux"]
      set fwhmx [::bdi_tools_psf::get_val othf "fwhmx"]
      set fwhmy [::bdi_tools_psf::get_val othf "fwhmy"]
      #set flagastrom [::bdi_tools_psf::get_val othf "flagastrom"]
      #set flagphotom [::bdi_tools_psf::get_val othf "flagphotom"]
      #if { $flagastrom == "" && $flagphotom == "" } {continue}
      if { ! ($mag > 6.0 && $mag<20) } { continue }
      #puts "A3: $fwhmx $fwhmy $flux $mag"
      set fwhmx_arcsec [expr $fwhmx*abs($cdelt1)*3600.0]
      set fwhmy_arcsec [expr $fwhmy*abs($cdelt2)*3600.0]
      set fwhm_arcsec  [expr sqrt( (pow($fwhmx_arcsec,2) + pow($fwhmy_arcsec,2)) )]
      lappend tfwhm $fwhm_arcsec
      set zmag [expr $mag + 2.5 * log($flux/$exposure)]
      lappend tzmag $zmag
   }
   set fwhm ""
   if {[llength $tfwhm] > 0} {
      set fwhm [format "%0.2f" [::math::statistics::median $tfwhm] ]
   }
   set zmag ""
   if {[llength $tzmag] > 0} {
      set zmag [format "%0.3f" [::math::statistics::median $tzmag] ]
   }
   return [list $fwhm $zmag]
}




# environnement pour procedure de test
proc ::bdi_tools_astroid_tank::test {  } {

   exit

}
