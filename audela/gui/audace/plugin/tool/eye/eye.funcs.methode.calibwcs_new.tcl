


   #------------------------------------------------------------
   ## Applique une calibration wcs avec la routine calibwcs_new
   # @return void
   #
   proc ::eye::get_calibwcs_new { } {

      global audace

      gren_info "pixsize1 $::eye::widget(methode,pixsize1) "
      gren_info "pixsize2 $::eye::widget(methode,pixsize2) "
      gren_info "foclen   $::eye::widget(methode,foclen) "
      gren_info "delta    $::eye::widget(methode,calibwcs_new,delta) \n"
      gren_info "nmax     $::eye::widget(methode,calibwcs_new,nmax) "
      gren_info "fluxcrit $::eye::widget(methode,calibwcs_new,fluxcrit) "
      gren_info "ra       $::eye::widget(coord,wanted,raJ2000) "
      gren_info "dec      $::eye::widget(coord,wanted,decJ2000) \n"
      gren_info "TMP DIR = $::eye::widget(methode,calib_tmpdir)\n"


      set catalog $::eye::widget(methode,calibwcs_new,catalog)
      set cataloguePath "Unknown"

      switch $catalog {
         "USNOA2" { set cataloguePath $audace(rep_userCatalogUsnoa2) }
         "TYCHO2" { set cataloguePath $audace(rep_userCatalogTycho2_fast) }
         "UCAC2"  { set cataloguePath $audace(rep_userCatalogUcac2) }
         "UCAC3"  { set cataloguePath $audace(rep_userCatalogUcac3) }
         "UCAC4"  { set cataloguePath $audace(rep_userCatalogUcac4) }
         "2MASS"  { set cataloguePath $audace(rep_userCatalog2mass) }
         "PPMX"   { set cataloguePath $audace(rep_userCatalogPpmx) }
         "NOMAD1" { set cataloguePath $audace(rep_userCatalogNomad1) }
         "PPMXL"  { set cataloguePath $audace(rep_userCatalogPpmxl) }
      }

      gren_info "catalog       $::eye::widget(methode,calibwcs_new,catalog) \n"
      gren_info "cataloguePath $cataloguePath \n"

      if {$cataloguePath=="Unknown"} {
         gren_erreur "Echec test de calibration cataloguePath inconnu\n"
         return -code 1 "Echec test de calibration cataloguePath inconnu"
      }

      gren_info "Calibration encours : "
      set tt0 [clock clicks -milliseconds]
      set cmd "calibwcs_new $::eye::widget(coord,wanted,raJ2000) \
                            $::eye::widget(coord,wanted,decJ2000) \
                            $::eye::widget(methode,pixsize1) \
                            $::eye::widget(methode,pixsize2) \
                            $::eye::widget(methode,foclen) \
                            $catalog $cataloguePath \
                            $::eye::widget(methode,calibwcs_new,delta) \
                            $::eye::widget(methode,calibwcs_new,nmax) \
                            $::eye::widget(methode,calibwcs_new,fluxcrit) \
                            -del_tmp_files 0 -tmp_dir $::eye::widget(methode,calib_tmpdir)"

      set err [catch {eval $cmd} msg ]

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Termine ($tt sec) :"
      if {$err} {
         gren_erreur "Echec calibwcs_new\n"
         gren_erreur "err = $err\n"
         gren_erreur "msg = $msg\n"
         return -code 2 "Echec msg=$msg"
      }
      gren_info "SUCCESS (nb star = $msg)\n"
      return
   }




   #------------------------------------------------------------
   ## Affiche le resultat de la calibration astrometrique par 
   # des ronds de differentes couleurs dans l image
   # @return void
   #
   proc ::eye::view_calibwcs_new { } {

      global audace

      set filenametmp [file join $::eye::widget(methode,calib_tmpdir) catalog.cat]
      if {![file exists $filenametmp]} {
         return -1
      }
      set allfields [list id xpos ypos calib_mag_ss2 err_calib_mag_ss2 ra dec flux_sex err_flux_sex background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex class_star]

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

         set xcent [lindex $xlistcata 6]
         set ycent [lindex $xlistcata 7]
         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set xlist [list [lindex $xlistcata 0] [lindex $a 0] [lindex $a 1] $xcent $ycent [lindex $xlistcata 3] ]
         lappend list_sources $xlist
      }
      if {[catch {close $chan} err]} {
         gren_erreur "Cannot close cata file ($filenametmp): <$err>"
      }

      foreach value $list_sources {
         #gren_info "s= $value\n"
         set xpic [lindex $value 3]
         set ypic [lindex $value 4]
         set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xpic $ypic ]]
         set x   [lindex $coord 0]
         set y   [lindex $coord 1]
         set radius 7
         $::eye::hCanvas create oval [expr $x-$radius] [expr $y-$radius] \
                              [expr $x+$radius] [expr $y+$radius] \
                              -fill {} -outline green -width 2 \
                              -activewidth 3 -tag eye_calib_star

      }

      return
   }
