## @file bdi_tools_reports_v0_v1.tcl
#  @brief     Fonctions d&eacute;di&eacute;es aux rapports d'analyse  - transformation des donn&eacute;es version 0 aux &eacute;es version 1
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2015
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_reports_v0_v1.tcl]
#  @endcode

# $Id: bdi_tools_reports_v0_v1.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_reports_v0_v1
# @brief Fonctions d&eacute;di&eacute;es aux rapports d'analyse  - transformation des donn&eacute;es version 0 aux &eacute;es version 1
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_reports_v0_v1 {

}


#------------------------------------------------------------
## procedure récursive qui construit la liste des fichiers
# propre à la version 0 des données
# @param dir
# @param p_oldliste
# @return void
#
proc ::bdi_tools_reports_v0_v1::globrdk { {dir .} p_oldliste } {

   upvar $p_oldliste oldliste

   set liste [glob -nocomplain -dir $dir *]
   foreach i $liste {
      if {[file type $i]=="directory"} {
            globrdk $i oldliste
       } else {
          if {[::bdi_tools_reports_v0_v1::v0_is_filename [file tail $i]]} {
             lappend oldliste $i
          }
       }
    }
    return
 }



#------------------------------------------------------------
## procedure recursive qui efface les repertoire vide
# propre ala version 0 des donnees
# @param dir
# @return void
#
proc ::bdi_tools_reports_v0_v1::deleterdk { {dir .} } {

   set liste [glob -nocomplain -dir $dir *]
   foreach i $liste {
      if {[file type $i]=="directory"} {
            set err [catch {file delete $i} msg]
            if {$err} {deleterdk $i}
       }
    }
    return
 }



#------------------------------------------------------------
## Verifie la structure du repertoire rapport
# doit etre rapport/$obs/$firstdate/$batch
# @return err code ou 0
#
# ::bddimages::ressource_tools ; ::bdi_tools_reports_v0_v1::is_v0 "no" 1
proc ::bdi_tools_reports_v0_v1::is_v0 { mode {repar 0} } {


   global bddconf
   global maliste

      set errbadfile "Fichiers ou repertoires non conformes a la structure des rapports de bddimages.\n"
      append errbadfile "Veuillez deplacer ces fichiers manuellement...\n\n"

      set oldliste ""
      set err [catch {::bdi_tools_reports_v0_v1::globrdk [file join $bddconf(dirreports) ASTROPHOTOM] oldliste} msg ]
      if {$err} {
         gren_erreur "$err $msg\n"
         return
      }
      set nb [llength $oldliste]

      if {$nb>0} {
         # version 0 trouvée
         if {$repar==0} {
            set msg "\n"
            append msg "Ancienne version des rapports detectee.\n"
            append msg "La reparation permettra la mise a jour dans le nouveau format.\n"
            append msg "$nb fichiers en version 0 seront transformes\n"
            return -code 2 $msg
         } else {

            # On ne traite que les fichiers de donnee
            set list_readme ""
            foreach v0_rootfile $oldliste {
               set file [file tail $v0_rootfile]
               set dir  [file tail [file dirname $v0_rootfile]]
               set rxp {^.{4}-.{2}-.{2}}
               if {[regexp -- $rxp $dir]} {
                  lappend list_readme $v0_rootfile
                  continue
               }
               ::bdi_tools_reports_v0_v1::v0_to_v1_rootfilename $v0_rootfile $mode
            }


            # On ne traite que les fichiers readme
            foreach v0_rootfile $list_readme {
               ::bdi_tools_reports_v0_v1::v0_to_v1_rootfilename $v0_rootfile $mode
            }

            # On efface les repertoires vides
            ::bdi_tools_reports_v0_v1::deleterdk [file join $bddconf(dirreports) ASTROPHOTOM]
         }
      }
      return 0

}



#------------------------------------------------------------
## retourne 1 si le nom du fichier d entree est construit
# dans l ancien format
# @param  oldfile chemin complet vers fichier
# @return bool
#
# @brief
# ::bdi_tools_reports_v0_v1::v0_is_filename "SKYBOT_107_Camilla.2015-04-20.Audela_BDI_2015-05-17T18:02:00_CEST.info.txt"
# retourne 0
# ::bdi_tools_reports_v0_v1::v0_is_filename "DateObs.2015-04-21.Obj.SKYBOT_107_Camilla.submit.no.Batch.Audela_BDI_2015-04-27T21:59:42_CEST.readme.txt"
# retourne 1
# ::bdi_tools_reports_v0_v1::v0_is_filename "DateObs.2015-04-21.Obj.SKYBOT_107_Camilla.submit.no.Batch.Audela_BDI_2015-04-27T21:59:42_CEST.astrom.readme.txt"
# retourne 0
#
proc ::bdi_tools_reports_v0_v1::v0_is_filename { oldfile } {

   set log 0

   # old photometrique
   if {$log} {gren_info "old photometrique ?\n"}
   set rxp {^DateObs\.(.+)\.Obj\.(.+)\.submit\.(.+)\.Batch\.([^.]+)\.(.+)}
   if {[regexp -- $rxp $oldfile]} {

      set r [regexp -inline -- $rxp $oldfile]
      if {$log} {gren_info "r = $r\n"}
      lassign $r u date obj submit batch node1

      if {$log} {gren_info "date = $date\n"}
      set rxp {^.{4}-.{2}-.{2}}
      if {![regexp -- $rxp $date]} {
         return 0
      }

      if {$log} {gren_info "batch = $batch\n"}
      set rxp {^Audela_BDI_.{4}-.{2}-.{2}}
      if {![regexp -- $rxp $batch]} {
         return 0
      }
      if {$node1 == "txt" } { return 1 }
      if {$node1 == "mpc" } { return 1 }
      if {$node1 == "xml" } { return 1 }

      if {$log} {gren_info "ni  = txt mpc xml\n"}

   }

   # old astrometrique
   if {$log} {gren_info "old astrometrique ?\n"}
   set rxp {^DateObs\.(.+)\.Obj\.(.+)\.submit\.(.+)\.Batch\.([^.]+)\.(.+)\.(.+)}
   if {[regexp -- $rxp $oldfile]} {

      set r [regexp -inline -- $rxp $oldfile]
      lassign $r u date obj submit batch node1 node2

      if {$log} {
         set i 0
         foreach val $r {
            gren_info "$i => $val\n"
            incr i
         }
      }

      set rxp {^.{4}-.{2}-.{2}}
      if {![regexp -- $rxp $date]} {
         return 0
      }

      set rxp {^Audela_BDI_.{4}-.{2}-.{2}}
      if {![regexp -- $rxp $batch]} {
         return 0
      }

      if {$node1 == "readme" && $node2 == "txt"} { return 1 }
      if {$node1 == "astrom" && $node2 == "txt"} { return 1 }
      if {$node1 == "astrom" && $node2 == "xml"} { return 1 }
      if {$node1 == "astrom" && $node2 == "mpc"} { return 1 }
      if {$node1 == "photom" && $node2 == "txt"} { return 1 }
      if {$node1 == "photom" && $node2 == "xml"} { return 1 }
      if {$node1 == "photom" && $node2 == "mpc"} { return 1 }
      if {$node1 == "astrom.readme" && $node2 == "txt"} { return 1 }
   }
   if {$log} {gren_info "old inconnu\n"}

   return 0
}



#------------------------------------------------------------
## retourne le type d'un batch dans l'ancien format
# @param obj
# @param firstdate
# @param batch
# @return bool
#
proc ::bdi_tools_reports_v0_v1::v0_get_type_from_batch { obj firstdate batch } {

   global bddconf

   set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]
   set err [catch {set dliste [glob -dir $dir *]} msg ]
   if {$err==0} {
      foreach d $dliste {
         set dtail [ file tail $d]
         if {[file type $d]=="file"} {
            set type [::bdi_tools_reports::get_type_filename $dtail]
            if {$type == "astrom"} {
               return astrom
            }
            if {$type == "photom"} {
               return photom
            }
         }
      }

   }
   return err

}


#------------------------------------------------------------
## @brief retourne le nom du fichier d'entrée valide
# à partir d un ancien format de nom de fichier
# @code
# ::bdi_tools_reports_v0_v1::v0_to_v1_filename "SKYBOT_107_Camilla.2015-04-20.Audela_BDI_2015-05-17T18:02:00_CEST.info.txt"
# retourne 0
# ::bdi_tools_reports_v0_v1::v0_to_v1_filename "DateObs.2015-04-21.Obj.SKYBOT_107_Camilla.submit.no.Batch.Audela_BDI_2015-04-27T21:59:42_CEST.readme.txt"
# retourne 1
# @endcode
# @param v0_rootfile ??
# @param mode        ??
# @return file validité du format
# - 1 ??
# - 0 ??
# @todo documenter les ??
proc ::bdi_tools_reports_v0_v1::v0_to_v1_rootfilename { v0_rootfile mode } {

   global bddconf

   #gren_info "\n"
   #gren_info "rootfile = $v0_rootfile\n"
   set file [file tail $v0_rootfile]
   set dir  [file dirname $v0_rootfile]
   set dir  [file tail $dir]

   #gren_info "oldfile = $file\n"
   #gren_info "    dir = $dir\n"

   set rxp {^DateObs\.(.+)\.Obj\.(.+)\.submit\.(.+)\.Batch\.([^.]+)\.}
   set r [regexp -inline -- $rxp $file]
   lassign $r u firstdate obj submit batch
   #gren_info "    obj        = $obj\n"
   #gren_info "    firstdate  = $firstdate\n"
   #gren_info "    batch      = $batch\n"

   if {$dir in [list "astrom_txt" "astrom_mpc" "astrom_xml" "photom_txt" "photom_xml"]} {

         # le conteneur est un repertoire de donnees
         #gren_info "    data\n"
         switch $dir {
            "astrom_txt" {
               set type astrom
               set ext  txt
            }
            "astrom_mpc" {
               set type astrom
               set ext  mpc
            }
            "astrom_xml" {
               set type astrom
               set ext  xml
            }
            "photom_txt" {
               set type photom
               set ext  txt
            }
            "photom_xml" {
               set type photom
               set ext  xml
            }
         }

         # renomme
         set nwf [::bdi_tools_reports::build_filename $obj $firstdate $batch $type $ext]

         # cree du repertoire de destination
         set destdir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]
         if {![file exists $destdir]} {
            ::bdi_tools_verif::print_line $mode H3 "Creation du repertoire $destdir"
            file mkdir $destdir
         }

         # deplacement du fichier
         set v1_rootfile  [file join $destdir $nwf]
         catch { file rename -force -- $v0_rootfile $v1_rootfile }
         return

  } else {

         # le conteneur est un repertoire firstdate
         # le fichier devrait etre un readme
         #gren_info "    readme\n"
         #gren_info "    submit     = $submit\n"
         set l [list obj $obj firstdate $firstdate batch $batch submit_mpc $submit]

         # recuperation du type
         set type [::bdi_tools_reports_v0_v1::v0_get_type_from_batch $obj $firstdate $batch]
         gren_info "    type       = $type\n"
         if {$type == "err"} {
            gren_erreur "v0_rootfile = $v0_rootfile\n"
            gren_erreur "file = $file\n"
            gren_erreur "type inconnu $batch\n"
            return
         }
         lappend l type $type

         # lecture du comment
         set chan [open $v0_rootfile r]
         if {$type == "astrom"} {gets $chan line}
         gets $chan comment
         close $chan
         lappend l comment $comment
         #gren_info "    comment    = $comment\n"

         # lecture des autres champs TODO
         if {$type == "astrom"} {
            set astrom_txt_file [::bdi_tools_reports::build_filename $obj $firstdate $batch "astrom" "txt"]
            set astrom_txt_file [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch $astrom_txt_file ]
            if {[file exists $astrom_txt_file]} {
               set h [::bdi_tools_reports_v0_v1::v0_get_info_astrom_txt $astrom_txt_file]
               foreach x $h {
                  lappend l $x
               }
            }
         }
         if {$type == "photom"} {
            set photom_txt_file [::bdi_tools_reports::build_filename $obj $firstdate $batch "photom" "txt"]
            set photom_txt_file [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch $photom_txt_file ]
            if {[file exists $photom_txt_file]} {
               set h [::bdi_tools_reports_v0_v1::v0_get_info_photom_txt $photom_txt_file]
               foreach x $h {
                  lappend l $x
               }
            }
         }

         # renomme
         set nwf [::bdi_tools_reports::build_filename $obj $firstdate $batch "info" "txt"]
         #gren_info "    nwf    = $nwf\n"

         # cree du repertoire de destination
         set destdir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]
         if {![file exists $destdir]} {
            ::bdi_tools_verif::print_line $mode H3 "Creation du repertoire $destdir"
            file mkdir $destdir
         }

         # ecriture du fichier
         set v1_rootfile  [file join $destdir $nwf]
         gren_info "v1_rootfile  = $v1_rootfile\n"
         gren_info "l  = $l\n"
         ::bdi_tools_reports::list_to_file_info $v1_rootfile l

         catch { file delete -force -- $v0_rootfile }

         return
  }

  return
}



#------------------------------------------------------------
## lecture des info astrometrique
# @param  file   nom de l objet, date iso YYYY-MM-DD de la premiere observation, Yes ou No, Chemin complet vers fichier
# @return void
#
proc ::bdi_tools_reports_v0_v1::v0_get_info_astrom_txt { file } {


   #return [list obj $obj type $type firstdate $firstdate batch $batch nbpts $nbpts submit_mpc $submit_mpc iau_code $iau_code \
   #             subscriber $subscriber address $address mail $mail software $software observers $observers reduction $reduction \
   #             instrument $instrument nb_dates $nb_dates duration $duration ref_catalogue $refcata nb_ref_stars $nb_ref_stars \
   #             deg_polynom $deg_polynom use_refraction $use_refraction use_eop $use_eop use_debias $use_debias res_max_ref_stars $res_max_refstars \
   #             res_min_ref_stars $res_min_refstars res_mean_ref_stars $res_mean_refstars res_std_ref_stars $res_std_refstars \
   #             fwhm_mean $fwhm_mean fwhm_std $fwhm_std mag_mean $mag_mean mag_std $mag_std mag_amp $mag_amp ra_mean $ra_mean \
   #             ra_std $ra_std dec_mean $dec_mean dec_std $dec_std residuals_mean $residus_mean residuals_std $residus_std \
   #             omc_mean $omc_mean omc_std $omc_std omc_x_mean $omc_x_mean omc_y_mean $omc_y_mean omc_x_std $omc_x_std \
   #             omc_y_std $omc_y_std comment $comment]

   set searchlist [list iau_code          "IAU code"            \
                        subscriber        "Subscriber"          \
                        address           "Address"             \
                        mail              "Mail"                \
                        software          "Software"            \
                        observers         "Observers"           \
                        reduction         "Reduction"           \
                        instrument        "Instrument"          \
                        nb_dates          "Nb of dates"         \
                        duration          "Duration"        \
                        ref_catalogue     "Ref\. catalogue"      \
                        nb_ref_stars      "Nb Ref\. Stars"       \
                        deg_polynom       "Degre polynom"       \
                        use_refraction    "Refraction"          \
                        use_eop           "EOP correction"      \
                        res_max_ref_stars "Res max Ref Stars"   \
                        res_min_ref_stars "Res min Ref Stars"   \
                        res_mean_ref_stars "Res moy Ref Stars"   \
                        res_std_ref_stars "Res std Ref Stars"   \
                        mag_mean          "Magnitude   "           \
                        mag_std           "Magnitude STD"       \
                        mag_amp           "Magnitude Ampl"      \
                        fwhm_mean         "FWHM .arcsec"       \
                        fwhm_std          "FWHM STD"   \
                        ra_mean           "Right Asc"    \
                        dec_mean          "Declination"   \
                        ra_std            "RA STD"        \
                        dec_std           "DEC STD"       \
                        residuals_mean    "Residus .mas"       \
                        residuals_std     "Residus STD"   \
                        omc_mean          "OmC .mas"           \
                        omc_std           "OmC STD"       \
                        omc_x_mean        "OmC X  "     \
                        omc_y_mean        "OmC Y  "     \
                        omc_x_std         "OmC X STD"     \
                        omc_y_std         "OmC Y STD"     \
                     ]

   set chan [open $file r]

   array unset tab
   set tab(use_debias) 0
   set tab(use_eop) 0
   set tab(use_refraction) 0
   set tab(type) "astrom"

   set lecture 0
   while {[gets $chan line] >= 0} {

      if {!$lecture} {
         if {[regexp -- {^\#\$\+} $line]} {
            gren_info "on demarre la lecture\n"
            set lecture 1
         }
         continue
      }

      if {[regexp -- {^\#\$\-} $line]} {
         gren_info "on arrete la lecture\n"
         break
      }

      foreach {x y} $searchlist {
         set r [regexp -all -inline -- "^\# $y.*= (.*)" $line] ; #"
         if {$r!=""} {
            set tab($x) [lindex $r 1]
            gren_erreur "OOO $x = $tab($x)\n"
            break
         }
      }

   }
   close $chan

   return [array get tab]

}


#------------------------------------------------------------
## lecture des info astrometrique
# @param  file  (nom de l objet, date iso YYYY-MM-DD de la premiere observation, Yes ou No, Chemin complet vers fichier) ???
# @return void
#
proc ::bdi_tools_reports_v0_v1::v0_get_info_photom_txt { file } {


   #return [list obj $obj type $type firstdate $firstdate batch $batch nbpts $nbpts submit_mpc $submit_mpc iau_code $iau_code \
   #             subscriber $subscriber address $address mail $mail software $software observers $observers reduction $reduction \
   #             instrument $instrument nb_dates $nb_dates duration $duration ref_catalogue $refcata nb_ref_stars $nb_ref_stars \
   #             deg_polynom $deg_polynom use_refraction $use_refraction use_eop $use_eop use_debias $use_debias res_max_ref_stars $res_max_refstars \
   #             res_min_ref_stars $res_min_refstars res_mean_ref_stars $res_mean_refstars res_std_ref_stars $res_std_refstars \
   #             fwhm_mean $fwhm_mean fwhm_std $fwhm_std mag_mean $mag_mean mag_std $mag_std mag_amp $mag_amp ra_mean $ra_mean \
   #             ra_std $ra_std dec_mean $dec_mean dec_std $dec_std residuals_mean $residus_mean residuals_std $residus_std \
   #             omc_mean $omc_mean omc_std $omc_std omc_x_mean $omc_x_mean omc_y_mean $omc_y_mean omc_x_std $omc_x_std \
   #             omc_y_std $omc_y_std comment $comment]

   set searchlist [list iau_code          "IAU code"            \
                        subscriber        "Subscriber"          \
                        address           "Address"             \
                        mail              "Mail"                \
                        software          "Software"            \
                        observers         "Observers"           \
                        reduction         "Reduction"           \
                        instrument        "Instrument"          \
                        nb_dates          "Nb of dates"         \
                        duration          "Duration"            \
                        mag_mean          "Magnitude   "        \
                        mag_std           "Magnitude STD"       \
                        mag_amp           "Magnitude Ampl"      \
                        mag_prec          "Magnitude Err"       \
                        cm_var_max        "Variation Max CM"    \
                        cm_var_moy        "Variation Moy CM"    \
                        cm_var_med        "Variation Med CM"    \
                        cm_var_std        "Variation STD CM"    \
                        fwhm_mean         "FWHM .arcsec"        \
                        fwhm_std          "FWHM STD"            \
                        ra_mean           "Right Asc"           \
                        dec_mean          "Declination"         \
                        nb_ref_stars      "Nb Star Ref"         \
                     ]

   set chan [open $file r]

   array unset tab
   set tab(use_debias) 0
   set tab(use_eop) 0
   set tab(use_refraction) 0
   set tab(type) "photom"

   set lecture 0
   while {[gets $chan line] >= 0} {

      if {!$lecture} {
         if {[regexp -- {^\#\$\+} $line]} {
            gren_info "on demarre la lecture\n"
            set lecture 1
         }
         continue
      }

      if {[regexp -- {^\#\$\-} $line]} {
         gren_info "on arrete la lecture\n"
         break
      }

      foreach {x y} $searchlist {
         set r [regexp -all -inline -- "^\# $y.*= (.*)" $line] ; #"
         if {$r!=""} {
            set tab($x) [lindex $r 1]
            gren_erreur "OOO $x = $tab($x)\n"
            break
         }
      }

   }
   close $chan

   return [array get tab]

}


proc ::bdi_tools_reports_v0_v1::v0_get_batch { file } {
   set pos [expr [string last "Batch" $file] + 6]
   set batch [string range $file $pos end]
   set pos [expr [string first "." $batch] -1]
   set batch [string range $batch 0 $pos]
   return $batch
}
