#
# Projet EYE
# Description : Pilotage d un chercheur electronique asservissant une monture
# Auteur : Frederic Vachier
# Mise a jour $Id: eye.funcs.methode.tcl 13706 2016-04-15 11:43:09Z rzachantke $
#

   #------------------------------------------------------------
   ## Modifie la gui pour les paramètres de configuration de la
   # méthode de calibration choisie
   #
   proc ::eye::chg_calib_method { frmtable } {

      if {$::eye::widget(methode)=="CALIBWCS"} {
         grid $frmtable.calibwcs
         grid remove $frmtable.calibwcs_new
         grid remove $frmtable.statistique
         grid remove $frmtable.bogumil
      }
      if {$::eye::widget(methode)=="CALIBWCS_NEW"} {
         grid remove $frmtable.calibwcs
         grid $frmtable.calibwcs_new
         grid remove $frmtable.statistique
         grid remove $frmtable.bogumil
      }
      if {$::eye::widget(methode)=="STAT"} {
         grid remove $frmtable.calibwcs
         grid remove $frmtable.calibwcs_new
         grid $frmtable.statistique
         grid remove $frmtable.bogumil
      }
      if {$::eye::widget(methode)=="BOGUMIL"} {
         grid remove $frmtable.calibwcs
         grid remove $frmtable.calibwcs_new
         grid remove $frmtable.statistique
         grid $frmtable.bogumil
      }
      return 0
   }

   #------------------------------------------------------------
   ## Procedure de Test de calibration astrometrique
   # @return void
   #
   proc ::eye::test_calibration { } {

      gren_info "Test de calibration : $::eye::widget(methode)\n"

      set tt0 [clock clicks -milliseconds]
      switch $::eye::widget(methode) {
         "CALIBWCS"     { set err [catch {::eye::get_calibwcs} msg ] }
         "CALIBWCS_NEW" {
            ::eye::delete_calib_star
            set err [catch {::eye::get_calibwcs_new} msg ]
            ::eye::view_calibwcs_new
         }
         "STAT"         { }
         "BOGUMIL"      { }
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      if {$err} {
         gren_erreur "Calibration en erreur msg=$msg\n"
         return
      }
      gren_info "Calibration reussie en $tt_total sec\n"
      return
   }

   #------------------------------------------------------------
   ## @brief calibration astrométrique de l'image courante
   #  @return void
   #
   proc ::eye::start_calibration {  } {

      global conf
      global audace

      set tt0 [clock clicks -milliseconds]
      switch $::eye::widget(methode) {
         "CALIBWCS"     { set err [catch {::eye::get_calibwcs} msg ] }
         "CALIBWCS_NEW" { set err [catch {::eye::get_calibwcs_new} msg ] }
         "STAT"         { }
         "BOGUMIL"      { }
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]

      if {$err} {
         gren_erreur "Calibration en erreur msg=$msg\n"
         return
      }
      gren_info "Calibration reussie en $tt_total sec\n"

      set ::eye::widget(coord,reticule,draJ2000)  ""
      set ::eye::widget(coord,reticule,ddecJ2000) ""
      set ::eye::widget(coord,reticule,distJ2000) ""

      if {[info exists ::eye::widget(telescope,reticule,position,x)] && \
          [info exists ::eye::widget(telescope,reticule,position,y)] } {

         gren_erreur "Reticule X=$::eye::widget(telescope,reticule,position,x) Y=$::eye::widget(telescope,reticule,position,y)\n"

         set a [buf$::eye::bufNo xy2radec [list $::eye::widget(telescope,reticule,position,x) \
                                                $::eye::widget(telescope,reticule,position,y)]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]

         set ::eye::widget(coord,reticule,raJ2000)  [mc_angle2hms $ra 360 zero 1 auto string]
         set ::eye::widget(coord,reticule,decJ2000) [mc_angle2dms $dec 90 zero 1 + string]

         set dra [expr [mc_angle2deg $::eye::widget(coord,wanted,raJ2000)]-$ra]
         set ::eye::widget(coord,reticule,draJ2000) [mc_angle2dms $dra 90 zero 1 + string]

         set ddec [expr [mc_angle2deg $::eye::widget(coord,wanted,decJ2000)]-$dec]
         set ::eye::widget(coord,reticule,ddecJ2000) [mc_angle2dms $ddec 90 zero 1 + string]

         set dist [expr sqrt(pow($dra,2)+pow($ddec,2))]
         set ::eye::widget(coord,reticule,distJ2000) [mc_angle2dms $dist 90 zero 1 + string]

         ::eye::affiche_calibstars $ra $dec $dra $ddec $dist

      } else {
         set ::eye::widget(coord,reticule,raJ2000) "***"
         set ::eye::widget(coord,reticule,decJ2000) "***"
      }

      return
   }

   #------------------------------------------------------------
   ## brief calibration astrométrique de l'image courante
   # @warning procédure obsolete, ne sert que pour finir la procédure
   # existante en y ajoutant plus tard quelques lignes de code
   # @todo la fonction affiche_calibration ne semble pas définie
   #
   proc ::eye::startCalibration_obsolete {  } {

      global conf
      global audace

      set tt0 [clock clicks -milliseconds]
      set ::eye::widget(event,workinglabel,calibration) "Working..."

      ::eye::widget_to_conf

#      set crval1  [mc_angle2deg $::eye::widget(keys,img,crval1)]
#      set crval2  [mc_angle2deg $::eye::widget(keys,img,crval2)]
      set crval1 [mc_angle2hms $::eye::widget(keys,img,crval1) 360 zero 1 auto string]
      set crval2 [mc_angle2dms $::eye::widget(keys,img,crval2) 90 zero 1 + string]

      gren_info "CRVAL1   = $crval1 ($::eye::widget(keys,new,crval1))  \n"
      gren_info "CRVAL2   = $crval2 ($::eye::widget(keys,new,crval2))  \n"
      gren_info "PIXSIZE1 = $::eye::widget(keys,new,pixsize1) \n"
      gren_info "PIXSIZE2 = $::eye::widget(keys,new,pixsize2) \n"
      gren_info "FOCLEN   = $::eye::widget(keys,new,foclen)   \n"
      gren_info "CRPIX1   = $::eye::widget(keys,new,crpix1)   \n"
      gren_info "CRPIX2   = $::eye::widget(keys,new,crpix2)   \n"
      gren_info "CROTA2   = $::eye::widget(keys,new,crota2)   \n"

      buf$::eye::bufNo setkwd [list "RA"         $::eye::widget(keys,new,crval1)     float {[deg] coord center frame} "pixel" ]
      buf$::eye::bufNo setkwd [list "DEC"        $::eye::widget(keys,new,crval2)     float {[deg] coord center frame} "pixel" ]
      buf$::eye::bufNo setkwd [list "PIXSIZE1"   $::eye::widget(keys,new,pixsize1)   float {[um] Pixel size along naxis1} "um" ]
      buf$::eye::bufNo setkwd [list "PIXSIZE2"   $::eye::widget(keys,new,pixsize2)   float {[um] Pixel size along naxis2} "um" ]
      buf$::eye::bufNo setkwd [list "CRPIX1"     $::eye::widget(keys,new,crpix1)     float {[pixel] reference pixel for naxis1} "pixel" ]
      buf$::eye::bufNo setkwd [list "CRPIX2"     $::eye::widget(keys,new,crpix2)     float {[pixel] reference pixel for naxis2} "pixel" ]
      buf$::eye::bufNo setkwd [list "CRVAL1"     $::eye::widget(keys,new,crval1)     float {[deg] coord center frame} "deg" ]
      buf$::eye::bufNo setkwd [list "CRVAL2"     $::eye::widget(keys,new,crval2)     float {[deg] coord center frame} "deg" ]
      buf$::eye::bufNo setkwd [list "FOCLEN"     $::eye::widget(keys,new,foclen)     double "Focal length" "m"]
      buf$::eye::bufNo setkwd [list "CROTA2"     $::eye::widget(keys,new,crota2)     double "position angle" "deg"]
      buf$::eye::bufNo setkwd [list "CTYPE1"     "RA---TAN" string "Gnomonic projection" "" ]
      buf$::eye::bufNo setkwd [list "CTYPE2"     "DEC--TAN" string "Gnomonic projection" "" ]
      buf$::eye::bufNo setkwd [list "CUNIT1"     "deg" string "Angles are degrees always" "" ]
      buf$::eye::bufNo setkwd [list "CUNIT2"     "deg" string "Angles are degrees always" "" ]
      buf$::eye::bufNo setkwd [list "EQUINOX"    "2000" string "System of equatorial coordinates" "" ]

#      buf1 delkwd CD1_1
#      buf1 delkwd CD1_2
#      buf1 delkwd CD2_1
#      buf1 delkwd CD2_2

      set flipx -1
      set flipy -1
      #-- Note RZ le message est ambigüe car il n'y a un ] terminal --> erreur detectee par Doxygen
      #gren_info "cdelt1=$flipx * 3438 * $::eye::widget(keys,new,pixsize1) / $::eye::widget(keys,new,foclen) / 60000000.]\n"
      gren_info "cdelt1=$flipx * 3438 * $::eye::widget(keys,new,pixsize1) / $::eye::widget(keys,new,foclen) / 60000000.\n"

# estimation du facteur d echelle

      set fact 3438
      set fact 3437.74999472

      set foclen $::eye::widget(keys,new,foclen)
      set fact 3438
      set cdelt1 [expr $flipx * $fact * $::eye::widget(keys,new,pixsize1) \
                       / $foclen / 60000000.]
      set cdelt2 [expr $flipy * $fact * $::eye::widget(keys,new,pixsize2) \
                       / $foclen / 60000000.]
      gren_info "Estim cdelt1=$cdelt1\n"
      gren_info "Estim cdelt2=$cdelt2\n"

# ICI on le fixe
      if {1==1} {
         set cdelt1 -0.003548407306
         set cdelt2 0.0032589915700
         gren_info "Fix cdelt1=$cdelt1\n"
         gren_info "Fix cdelt2=$cdelt2\n"
      }

      set ::eye::widget(keys,new,cdelt1) $cdelt1
      set ::eye::widget(keys,new,cdelt2) $cdelt2

      buf1 setkwd [list {CDELT1} $cdelt1 {double} { [X scale] deg/pixel } { X scale} ]
      buf1 setkwd [list {CDELT2} $cdelt2 {double} { [Y scale] deg/pixel } { Y scale} ]

#  buf1 setkwd { {CDELT1} -0.003548407306000000028 {double} { [X scale] deg/pixel } { X scale} }
#  buf1 setkwd { {CDELT2} 0.003258991570000000036 {double} { [Y scale] deg/pixel } { Y scale} }
#  buf1 setkwd { {FOCLEN} 0.1388634743000000116 {double} { [Focal length] m } { Focal length} }


      set err 1

      switch $::eye::widget(methode) {
         "CALIBWCS" {
            gren_info "CalibWCS : [pwd]\n"
            gren_info "cmd : calibwcs $::eye::widget(keys,new,crval1) $::eye::widget(keys,new,crval2) $::eye::widget(keys,new,pixsize1) $::eye::widget(keys,new,pixsize2)
                     $::eye::widget(keys,new,foclen) USNO $audace(rep_userCatalogUsnoa2)
                     -maglimit $::eye::widget(methode,magnitude) -del_tmp_files 0 -yes_visu 0 \n"

            calibwcs $::eye::widget(keys,new,crval1)   $::eye::widget(keys,new,crval2) \
                     $::eye::widget(keys,img,pixsize1) $::eye::widget(keys,img,pixsize2) \
                     $::eye::widget(keys,new,foclen) USNO $audace(rep_userCatalogUsnoa2) \
                     -maglimit $::eye::widget(methode,magnitude) -del_tmp_files 0 -yes_visu 0

                    }
         "STAT"     {
                    }
         "BOGUMIL"  {
                      set err [ bogumil_1 ]
                    }
      }

      if {$err==0} {
         ::eye::maj_widget_motscles
      }

      ::eye::affiche_calibration

      set tt [format "%.1f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]
      gren_info "Temps pour calculer l astrometrie : $tt sec\n"
      set ::eye::widget(event,workinglabel,calibration) "Terminated in $tt sec"
   }


   #------------------------------------------------------------
   ## Affiche le résultat de la calibration astrométrique par
   # des ronds de différentes couleurs dans l'image
   #
   proc ::eye::view_calib { } {

      switch $::eye::widget(methode) {
         "CALIBWCS" {
            ::eye::view_calibwcs
                    }
         "CALIBWCS_NEW" {
            ::eye::view_calibwcs_new
                    }
         "STAT"     {

                    }
         "BOGUMIL"  {

                    }
      }
   }
