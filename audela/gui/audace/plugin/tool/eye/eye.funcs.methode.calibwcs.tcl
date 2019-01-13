



   #------------------------------------------------------------
   ## Applique une calibration wcs avec la routine calibwcs
   # @return void
   #
   proc ::eye::get_calibwcs { } {

      global audace

      gren_info "pixsize1 $::eye::widget(methode,pixsize1)              \n"
      gren_info "pixsize2 $::eye::widget(methode,pixsize2)              \n"
      gren_info "foclen   $::eye::widget(methode,foclen)                \n"
      gren_info "maglimit $::eye::widget(methode,calibwcs,maglimit)     \n"
      gren_info "nmax     $::eye::widget(methode,calibwcs_new,nmax)     \n"
      gren_info "fluxcrit $::eye::widget(methode,calibwcs_new,fluxcrit) \n"
      gren_info "ra       $::eye::widget(coord,wanted,raJ2000)          \n"
      gren_info "dec      $::eye::widget(coord,wanted,decJ2000)         \n"


      set catalog $::eye::widget(methode,calibwcs,catalog)
      set cataloguePath "Unknown"

      switch $catalog {
         "USNOA2" { set cataloguePath $audace(rep_userCatalogUsnoa2) }
         "TYCHO2" { set cataloguePath $::eye::widget(methode,calibwcs,tycho_facon_usno) }
      }

      gren_info "catalog       $catalog \n"
      gren_info "cataloguePath $cataloguePath \n"

      if {$cataloguePath=="Unknown"} {
         gren_erreur "Echec test de calibration cataloguePath inconnu\n"
         return -code 1 "Echec test de calibration cataloguePath inconnu"
      }

gren_erreur "TMP DIR = $::eye::widget(methode,calib_tmpdir)\n"

      gren_info "Calibration encours : "
      set tt0 [clock clicks -milliseconds]
      set cmd "calibwcs $::eye::widget(coord,wanted,raJ2000) \
                        $::eye::widget(coord,wanted,decJ2000) \
                        $::eye::widget(methode,pixsize1) \
                        $::eye::widget(methode,pixsize2) \
                        $::eye::widget(methode,foclen) \
                        USNO $cataloguePath \
                        -maglimit $::eye::widget(methode,calibwcs,maglimit) \
                        -del_tmp_files 0 -tmp_dir $::eye::widget(methode,calib_tmpdir)"
      set err [catch {eval $cmd} msg ]
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Termine ($tt sec) :"
      if {$err} {
         gren_erreur "Echec calibwcs\n"
         gren_erreur "err = $err\n"
         gren_erreur "msg = $msg\n"
         return -code 2 "Echec msg=$msg"
      }
      gren_info "SUCCESS\n"
      return
   }





   #------------------------------------------------------------
   ## Affiche le resultat de la calibration astrometrique par 
   # des ronds de differentes couleurs dans l image
   # @return void
   #
   proc ::eye::view_calibwcs { } {

      global audace

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
