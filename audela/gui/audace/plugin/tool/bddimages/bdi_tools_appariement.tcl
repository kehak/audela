## @file bdi_tools_appariement.tcl
#  @brief     Choix de la m&eacute;thode d'appariement pour l'astrom&eacute;trie
#  @author    Jerome Berthier and Frederic Vachier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [ file join $audace(rep_plugin) tool bddimages bdi_tools_appariement.tcl ]
#  @endcode
#  @code Usage:
#  set ::bdi_tools_appariement::calibwcs_args "$ra $dec * * *"
#   set erreur [catch {set calibwcs_cmd [::bdi_tools_appariement::get_calibwcs_cmde]} msg]
#   if {$erreur} { ... }
#   set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
#   if {$erreur} { ... }
#  @endcode

#  $Id: bdi_tools_appariement.tcl 6858 2011-03-06 14:19:15Z fredvachier $

##
# @namespace bdi_tools_appariement
# @brief Choix de la m&eacute;thode d'appariement pour l'astrom&eacute;trie
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_appariement {

   # Choix de la methode d'appariement: 0: calibwcs ; 1: calibwcs_new
   variable calibwcs_method

   # Parametres de la methode d'appariement:
   #   calibwcs_param(maglimit)       : magnitude limite de la methode calibwcs
   #   calibwcs_param(refcata)        : cata de reference pour l'appariement
   #   calibwcs_param(delta)          : ?
   #   calibwcs_param(nmax)           : ?
   #   calibwcs_param(flux_criterion) : ?
   #   calibwcs_param(catalist)       : Liste des cata de ref. possibles
   variable calibwcs_param

   # Parametres externes de la methode d'appariement (i.e. independant de la methode)
   variable calibwcs_args

   # Liste des catalogues disponibles affichee dans la GUI
   variable combo_catalist

}

#------------------------------------------------------------
## Initialisation des parametres d'appariement au niveau GUI
# @return void
#
proc ::bdi_tools_appariement::inittoconf { } {

   global conf

   # Methode d'appariement
   if {! [info exists ::bdi_tools_appariement::calibwcs_method] } {
      if {[info exists conf(bddimages,appariement,method)]} {
         set ::bdi_tools_appariement::calibwcs_method $conf(bddimages,appariement,method)
      } else {
         set ::bdi_tools_appariement::calibwcs_method 0
      }
   }
   # Parametres des methodes d'appariement
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(maglimit)] } {
      if {[info exists conf(bddimages,appariement,maglimit)]} {
         set ::bdi_tools_appariement::calibwcs_param(maglimit) $conf(bddimages,appariement,maglimit)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(maglimit) ""
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(refcata)] } {
      if {[info exists conf(bddimages,appariement,refcata)]} {
         set ::bdi_tools_appariement::calibwcs_param(refcata) $conf(bddimages,appariement,refcata)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(refcata) "?"
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(delta)] } {
      if {[info exists conf(bddimages,appariement,delta)]} {
         set ::bdi_tools_appariement::calibwcs_param(delta) $conf(bddimages,appariement,delta)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(delta) 3.5
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(nmax)] } {
      if {[info exists conf(bddimages,appariement,nmax)]} {
         set ::bdi_tools_appariement::calibwcs_param(nmax) $conf(bddimages,appariement,nmax)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(nmax) 35
      }
   }
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(flux_criterion)] } {
      if {[info exists conf(bddimages,appariement,flux_criterion)]} {
         set ::bdi_tools_appariement::calibwcs_param(flux_criterion) $conf(bddimages,appariement,flux_criterion)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(flux_criterion) 0
      }
   }

   # List des cata de reference possibles, a partir de la liste par defaut
   if {! [info exists ::bdi_tools_appariement::calibwcs_param(catalist)] } {
      if {[info exists conf(bddimages,appariement,catalist)]} {
         set ::bdi_tools_appariement::calibwcs_param(catalist) $conf(bddimages,appariement,catalist)
      } else {
         set ::bdi_tools_appariement::calibwcs_param(catalist) [::bdi_tools_appariement::get_default_refcatalist]
      }
   }

   # Parametres externes
   if {[info exists ::bdi_tools_appariement::calibwcs_args]} {
      unset ::bdi_tools_appariement::calibwcs_args
   }

   ::bdi_tools_appariement::closetoconf

}

#------------------------------------------------------------
## Sauvegarde dans la conf des parametres lies a l'appariement
# @return void
#
proc ::bdi_tools_appariement::closetoconf { } {

   global conf

   set conf(bddimages,appariement,method)         $::bdi_tools_appariement::calibwcs_method
   set conf(bddimages,appariement,maglimit)       $::bdi_tools_appariement::calibwcs_param(maglimit)
   set conf(bddimages,appariement,refcata)        $::bdi_tools_appariement::calibwcs_param(refcata)
   set conf(bddimages,appariement,delta)          $::bdi_tools_appariement::calibwcs_param(delta)
   set conf(bddimages,appariement,nmax)           $::bdi_tools_appariement::calibwcs_param(nmax)
   set conf(bddimages,appariement,flux_criterion) $::bdi_tools_appariement::calibwcs_param(flux_criterion)
   set conf(bddimages,appariement,catalist)       $::bdi_tools_appariement::calibwcs_param(catalist)

}


#------------------------------------------------------------
## Retourne la liste des cata de reference possibles pour l'appariement
# @return list liste des cata de reference
#
proc ::bdi_tools_appariement::get_default_refcatalist { } {

   global conf

   set refcatalist {}
   if {! [info exists conf(bddimages,cata,use_usnoa2)]} { set conf(bddimages,cata,use_usnoa2) 0}
   if {! [info exists conf(bddimages,cata,use_ucac2)]}  { set conf(bddimages,cata,use_ucac2)  0}
   if {! [info exists conf(bddimages,cata,use_ucac3)]}  { set conf(bddimages,cata,use_ucac3)  0}
   if {! [info exists conf(bddimages,cata,use_ucac4)]}  { set conf(bddimages,cata,use_ucac4)  0}
   if {! [info exists conf(bddimages,cata,use_ppmx)]}   { set conf(bddimages,cata,use_ppmx)   0}
   if {! [info exists conf(bddimages,cata,use_ppmxl)]}  { set conf(bddimages,cata,use_ppmxl)  0}
   if {! [info exists conf(bddimages,cata,use_tycho2)]} { set conf(bddimages,cata,use_tycho2) 0}
   if {! [info exists conf(bddimages,cata,use_nomad1)]} { set conf(bddimages,cata,use_nomad1) 0}
   if {! [info exists conf(bddimages,cata,use_2mass)]}  { set conf(bddimages,cata,use_2mass)  0}
   if {! [info exists conf(bddimages,cata,use_wfibc)]}  { set conf(bddimages,cata,use_wfibc)  0}
   if {! [info exists conf(bddimages,cata,use_gaia1)]}  { set conf(bddimages,cata,use_gaia1)  0}

   if {$conf(bddimages,cata,use_usnoa2) == 1} { lappend refcatalist [list USNOA2 $conf(bddimages,catfolder,usnoa2)] }
   if {$conf(bddimages,cata,use_ucac2)  == 1} { lappend refcatalist [list UCAC2  $conf(bddimages,catfolder,ucac2)]  }
   if {$conf(bddimages,cata,use_ucac3)  == 1} { lappend refcatalist [list UCAC3  $conf(bddimages,catfolder,ucac3)]  }
   if {$conf(bddimages,cata,use_ucac4)  == 1} { lappend refcatalist [list UCAC4  $conf(bddimages,catfolder,ucac4)]  }
   if {$conf(bddimages,cata,use_ppmx)   == 1} { lappend refcatalist [list PPMX   $conf(bddimages,catfolder,ppmx)]   }
   if {$conf(bddimages,cata,use_ppmxl)  == 1} { lappend refcatalist [list PPMXL  $conf(bddimages,catfolder,ppmxl)]  }
   if {$conf(bddimages,cata,use_tycho2) == 1} { lappend refcatalist [list TYCHO2 $conf(bddimages,catfolder,tycho2)] }
   if {$conf(bddimages,cata,use_nomad1) == 1} { lappend refcatalist [list NOMAD1 $conf(bddimages,catfolder,nomad1)] }
   if {$conf(bddimages,cata,use_2mass)  == 1} { lappend refcatalist [list 2MASS  $conf(bddimages,catfolder,2mass)]  }
   if {$conf(bddimages,cata,use_wfibc)  == 1} { lappend refcatalist [list WFIBC  $conf(bddimages,catfolder,wfibc)]  }
   if {$conf(bddimages,cata,use_gaia1)  == 1} { lappend refcatalist [list GAIA1  $conf(bddimages,catfolder,gaia1)]  }

   # Raffraichissement de la liste combo
   if {[info exists ::bdi_tools_appariement::combo_catalist]} {
      $::bdi_tools_appariement::combo_catalist configure -values [::bdi_tools_appariement::get_combo_catalist]
   }

   return $refcatalist

}


#------------------------------------------------------------
## Met a jour la liste courante des cata de reference (calibwcs_param(catalist)) pour la methode d'appariement,
#  et met a jour la liste combo des cata
# @return void
#
proc ::bdi_tools_appariement::update_current_refcatalist { {cata ""} {use 0} {dir ""} } {

   if {[info exists ::bdi_tools_appariement::calibwcs_param(catalist)]} {
      set refcatalist $::bdi_tools_appariement::calibwcs_param(catalist)
   } else {
      set refcatalist {}
   }

   set k 0
   set catakey -1
   foreach c $refcatalist {
      if {[string toupper [lindex $c 0]] == [string toupper $cata]} {
         set catakey $k
      }
      incr k
   }

   if {$catakey > -1} {
      if {$use == 0} {
         set refcatalist [lreplace $refcatalist $catakey $catakey]
         if {$::bdi_tools_appariement::calibwcs_param(refcata) == [string toupper $cata]} {
            set ::bdi_tools_appariement::calibwcs_param(refcata) "?"
         }
      }
   } else {
      if {$use == 1} {
         lappend refcatalist [list [string toupper $cata] $dir]
      }
   }

   set ::bdi_tools_appariement::calibwcs_param(catalist) $refcatalist

   # Raffraichissement de la liste combo
   if {[info exists ::bdi_tools_appariement::combo_catalist]} {
      $::bdi_tools_appariement::combo_catalist configure -values [::bdi_tools_appariement::get_combo_catalist]
   }

}


#------------------------------------------------------------
## Retourne la liste combo des cata de reference pour l'appriement (affichee par la GUI)
# @return list vide ou liste de cata de reference possibles
#
proc ::bdi_tools_appariement::get_combo_catalist { } {

   if {[info exists ::bdi_tools_appariement::combo_catalist]} {
      set combolist {}
      foreach c $::bdi_tools_appariement::calibwcs_param(catalist) {
         lappend combolist [lindex $c 0]
      }
      return $combolist
   }
   return {}

}


#------------------------------------------------------------
## Retourne le nom du repertoire d'un cata de reference de l'appariement a partir de son nom
# @param cata string Nom du cata
# @return string repertoire du cata
#
proc ::bdi_tools_appariement::get_refcatadir { cata } {

   set catadir "?"
   if {[info exists ::bdi_tools_appariement::calibwcs_param(catalist)]} {
      foreach c $::bdi_tools_appariement::calibwcs_param(catalist) {
         if {[string toupper [lindex $c 0]] == [string toupper $cata]} {
            set catadir [lindex $c 1]
         }
      }
   }

   return $catadir

}


#------------------------------------------------------------
## Affichage de la GUI de choix de la methode d'appariement et de ses parametres
# @return list_sources
#
   #{
   # {
   #  { IMG   {list field crossmatch} {list fields}}
   #  { TYC2  {list field crossmatch} {list fields}}
   #  { USNO2 {list field crossmatch} {list fields}}
   # }
   # {                                -> liste des sources
   #  {                               -> 1 source
   #   { IMG   {crossmatch} {fields}}  -> vue dans l image
   #   { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
   #   { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
   #  }
   # }
   #}
proc ::bdi_tools_appariement::get_cata { } {

   global audace
   global bddconf

   if {$::bdi_tools_appariement::calibwcs_method == 0} {

      # Chargement du fichier ascii.txt genere par calibwcs
      set filenametmp [file join $bddconf(dirtmp) ascii.txt]
      if {![file exists $filenametmp]} {
        return -code 1 "::bdi_tools_appariement::get_cata: fichier $filenametmp non trouve"
      }
      set cmfields  [list ra dec poserr mag magerr]
      set allfields [list id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex]
      set list_fields [list [list "IMG" $cmfields $allfields] [list "USNOA2CALIB" $cmfields {}]]
      set list_sources {}
      set chan [open $filenametmp r]
      set lineCount 0
      set littab "no"
      while {[gets $chan line] >= 0} {
         incr lineCount
         set zlist [split $line " "]
         set xlist {}
         foreach value $zlist {
            if {$value != {}} {
               set xlist [linsert $xlist end $value]
            }
         }
         set row {}
         set cmval [list [lindex $xlist 8] [lindex $xlist 9] 5.0 [lindex $xlist 10] [lindex $xlist 12]]
         if {[lindex $xlist 1] == 1} {
            lappend row [list "IMG" $cmval $xlist ]
            lappend row [list "OVNI" $cmval {} ]
         }
         if {[lindex $xlist 1] == 3} {
            lappend row [list "IMG" $cmval $xlist ]
            lappend row [list "USNOA2CALIB" $cmval {} ]
         }
         if {[llength $row] > 0} {
            lappend list_sources $row
         }
      }
      if {[catch {close $chan} err]} {
         gren_erreur "::bdi_tools_appariement::get_cata: cannot close cata file ($filenametmp): <$err>"
      }

   } else {

      set filenametmp [file join $bddconf(dirtmp) catalog.cat]
      if {![file exists $filenametmp]} {
         return -1
      }
      set cmfields  [list ra dec poserr mag magerr]
#      set allfields [list id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex]
      set allfields [list id xpos ypos calib_mag_ss2 err_calib_mag_ss2 ra dec flux_sex err_flux_sex background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex class_star]
      set list_fields [list [list "IMG" $cmfields $allfields]]
      set list_sources {}
      set chan [open $filenametmp r]
      set lineCount 0
      set littab "no"
      while {[gets $chan line] >= 0} {
         incr lineCount
         set zlist [split $line " "]
         # catalog.cat format
         #   1 NUMBER          Running object number
         #   2 FLUX_BEST       Best of FLUX_AUTO and FLUX_ISOCOR               [count]
         #   3 FLUXERR_BEST    RMS error for BEST flux                         [count]
         #   4 MAG_BEST        Best of MAG_AUTO and MAG_ISOCOR                 [mag]
         #   5 MAGERR_BEST     RMS error for MAG_BEST                          [mag]
         #   6 BACKGROUND      Background at centroid position                 [count]
         #   7 X_IMAGE         Object position along x                         [pixel]
         #   8 Y_IMAGE         Object position along y                         [pixel]
         #   9 X2_IMAGE        Variance along x                                [pixel**2]
         #  10 Y2_IMAGE        Variance along y                                [pixel**2]
         #  11 XY_IMAGE        Covariance between x and y                      [pixel**2]
         #  12 A_IMAGE         Profile RMS along major axis                    [pixel]
         #  13 B_IMAGE         Profile RMS along minor axis                    [pixel]
         #  14 THETA_IMAGE     Position angle (CCW/x)                          [deg]
         #  15 FWHM_IMAGE      FWHM assuming a gaussian core                   [pixel]
         #  16 FLAGS           Extraction flags
         #  17 CLASS_STAR      S/G classifier output
         set xlistcata {}
         foreach value $zlist {
            if {$value != {}} {
               set xlistcata [linsert $xlistcata end $value]
            }
         }
         # Common fields
         set xcent [lindex $xlistcata 6]
         set ycent [lindex $xlistcata 7]
         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set cmval [list [lindex $a 0] [lindex $a 1] 5.0 [lindex $xlistcata 3] [lindex $xlistcata 4]]
         # Reorganisation de xlist
         set xlist [list [lindex $xlistcata 0] [lindex $xlistcata 6] [lindex $xlistcata 7] [lindex $xlistcata 3] [lindex $xlistcata 4] [lindex $a 0] [lindex $a 1]\
                         [lindex $xlistcata 1] [lindex $xlistcata 2] [lindex $xlistcata 5] [lindex $xlistcata 8] [lindex $xlistcata 9]\
                         [lindex $xlistcata 10] [lindex $xlistcata 11] [lindex $xlistcata 12] [lindex $xlistcata 13] [lindex $xlistcata 14]\
                         [lindex $xlistcata 15] [lindex $xlistcata 16] [lindex $xlistcata 17]]
         # Other fields
         set row {}
         lappend row [list "IMG" $cmval $xlist]
         # Append to current source list
         lappend list_sources $row
      }
      if {[catch {close $chan} err]} {
         gren_erreur "::bdi_tools_appariement::get_cata: cannot close cata file ($filenametmp): <$err>"
      }

   }

   return [list $list_fields $list_sources]

}


#------------------------------------------------------------
## Retourne la commande calibwcs a executer pour effectuer l'appariement
# @return string commande calibwcs a executer
#
proc ::bdi_tools_appariement::get_calibwcs_cmde { } {

   set cmde ""

   if {! [info exists ::bdi_tools_appariement::calibwcs_args] || [string length $::bdi_tools_appariement::calibwcs_args] < 1} {
      set msg "bdi_tools_appariement: no user argument defined for calibwcs method. Set them through ::bdi_tools_appariement::calibwcs_args variable"
      return -code 1 $msg
   }

   switch $::bdi_tools_appariement::calibwcs_method {
      1 {
         set calibwcs_method "calibwcs_new"
         set calibwcs_args $::bdi_tools_appariement::calibwcs_args
         set calibwcs_cata $::bdi_tools_appariement::calibwcs_param(refcata)
         set calibwcs_catadir [::bdi_tools_appariement::get_refcatadir $::bdi_tools_appariement::calibwcs_param(refcata)]
         set calibwcs_options "$::bdi_tools_appariement::calibwcs_param(delta) $::bdi_tools_appariement::calibwcs_param(nmax) $::bdi_tools_appariement::calibwcs_param(flux_criterion) -del_tmp_files 0 -yes_visu 0"
      }
      default {
         set calibwcs_method "calibwcs"
         set calibwcs_args $::bdi_tools_appariement::calibwcs_args
         set calibwcs_cata "USNO"
         set calibwcs_catadir $::tools_cata::catalog_usnoa2
         set calibwcs_options "-del_tmp_files 0 -yes_visu 0"
         if {[string length $::bdi_tools_appariement::calibwcs_param(maglimit)] > 0} {
            append calibwcs_options " -maglimit $::bdi_tools_appariement::calibwcs_param(maglimit)"
         }
      }
   }

   return -code 0 "$calibwcs_method $calibwcs_args $calibwcs_cata $calibwcs_catadir $calibwcs_options"

}


#------------------------------------------------------------
## ...
# @return void
#
proc ::bdi_tools_appariement::toggle_USNOA2_cata { } {

   if {$::bdi_tools_appariement::calibwcs_method == 0} {
      set ::tools_cata::use_usnoa2 1
   }

}


#------------------------------------------------------------
## Affichage de la GUI de choix de la methode d'appariement et de ses parametres
# @param frm id du frame dans lequel la GUI est packee
# @return void
#
proc ::bdi_tools_appariement::gui { frm } {

   set calib1 [frame $frm.m1 -borderwidth 0 -cursor arrow]
   pack $calib1 -in $frm -anchor w -side top -expand 0 -fill x -padx 5 -pady 5

      radiobutton $calib1.r -text "calibwcs" -width 12 -value 0 -variable ::bdi_tools_appariement::calibwcs_method -highlightthickness 0 -anchor w \
                  -command {::bdi_tools_appariement::toggle_USNOA2_cata}
      pack $calib1.r -in $calib1 -anchor s -side left -expand 0 -fill x -padx 5 -pady 5

      frame $calib1.f -borderwidth 1 -cursor arrow -relief groove
      pack $calib1.f -in $calib1 -anchor s -side left -expand 0 -fill x -padx 5 -pady 5

         label $calib1.f.lab -text "Mag. limit : " -width 12 -anchor e
         pack $calib1.f.lab -in $calib1.f -side left -padx 5 -pady 5
         entry $calib1.f.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(maglimit) -width 5
         pack $calib1.f.val -in $calib1.f -side left -padx 5 -pady 5

   set calib2 [frame $frm.m2 -borderwidth 1 -cursor arrow]
   pack $calib2 -in $frm -anchor n -side top -expand 0 -fill x -padx 5 -pady 5

      radiobutton $calib2.r -text "calibwcs new" -width 12 -value 1 -variable ::bdi_tools_appariement::calibwcs_method -highlightthickness 0 -anchor w \
                  -command ""
      pack $calib2.r -in $calib2 -anchor w -side left -expand 0 -fill x -padx 5 -pady 5

      frame $calib2.f -borderwidth 1 -cursor arrow -relief groove
      pack $calib2.f -in $calib2 -anchor s -side left -expand 0 -fill x -padx 5 -pady 5

         frame $calib2.f.1
         pack $calib2.f.1 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.1.lab -text "Ref. cata: " -width 12 -anchor e
            pack $calib2.f.1.lab -in $calib2.f.1 -side left -padx 5 -pady 5
            set ::bdi_tools_appariement::combo_catalist [ComboBox $calib2.f.1.combo -height 3 -relief sunken -borderwidth 1 -editable 0 \
               -textvariable ::bdi_tools_appariement::calibwcs_param(refcata) -values [::bdi_tools_appariement::get_combo_catalist]]
            pack $::bdi_tools_appariement::combo_catalist -in $calib2.f.1 -side left -padx 5 -pady 5 -expand 0

         frame $calib2.f.2
         pack $calib2.f.2 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.2.lab -text "Delta: " -width 12 -anchor e
            pack $calib2.f.2.lab -in $calib2.f.2 -side left -padx 5 -pady 5
            entry $calib2.f.2.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(delta) -width 5
            pack $calib2.f.2.val -in $calib2.f.2 -side left -padx 5 -pady 5

         frame $calib2.f.3
         pack $calib2.f.3 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.3.lab -text "nmax: " -width 12 -anchor e
            pack $calib2.f.3.lab -in $calib2.f.3 -side left -padx 5 -pady 5
            entry $calib2.f.3.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(nmax) -width 5
            pack $calib2.f.3.val -in $calib2.f.3 -side left -padx 5 -pady 5

         frame $calib2.f.4
         pack $calib2.f.4 -in $calib2.f -anchor n -side top -expand 0 -fill x -padx 5 -pady 5
            label $calib2.f.4.lab -text "flux_criterion: " -width 12 -anchor e
            pack $calib2.f.4.lab -in $calib2.f.4 -side left -padx 5 -pady 5
            entry $calib2.f.4.val -relief sunken -textvariable ::bdi_tools_appariement::calibwcs_param(flux_criterion) -width 5
            pack $calib2.f.4.val -in $calib2.f.4 -side left -padx 5 -pady 5

   # Initialisation de la combolist des cata
   ::bdi_tools_appariement::update_current_refcatalist

}
