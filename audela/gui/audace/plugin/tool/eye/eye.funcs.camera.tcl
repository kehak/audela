#
# Projet EYE
# Description : Pilotage d un chercheur electronique asservissant une monture
# Auteur : Frederic Vachier
# Mise a jour $Id: eye.funcs.camera.tcl 12533 2016-01-06 17:36:27Z fredvachier $
#

   proc ::eye::camera_init { } {

      set ::eye::camItem [::confVisu::getCamItem $::eye::visuNo]
      set ::eye::camNo  [::confCam::getCamNo $::eye::camItem ]
      gren_info "camItem = $::eye::camItem \n"
      gren_info "camNo = $::eye::camNo \n"
      return

   }

   proc ::eye::acq_une_image { } {
      set file "acqinteg${::eye::extension}"
      set ::eye::camItem [::confVisu::getCamItem $::eye::visuNo]
      set ::eye::camNo  [::confCam::getCamNo $::eye::camItem ]
      if {$::eye::camItem!=""} {
         if {$::eye::widget(camera,integ,sum)>=1} {

            cam$::eye::camNo exptime 0
            for {set i 0} {$i<$::eye::widget(camera,integ,sum)} {incr i} {
               if {$i==0} {
                  set tt0 [clock clicks -milliseconds]
               } else {
                  #after 100
               }

               cam$::eye::camNo acq -blocking
               set file "acqinteg${i}${::eye::extension}"
               buf$::eye::bufNo save $file


               # on lance une acquisition
               #::camera::acquisition $::eye::camItem "::eye::callbackAcquisition $::eye::visuNo" 0

               # on ajoute les coadds au buffer
               #if {$i>0} { buf$::eye::bufNo add $file 0}
               #gren_info "Mean img [lindex [buf$::eye::bufNo stat] 4]\n"

               # on sauve les coadds
               #if {$i<$::eye::widget(camera,integ,sum)} {
#                  buf$::eye::bufNo save $file
               #}

            }
            #update
            #after 1000
            #update
            set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]

            for {set i 0} {$i<$::eye::widget(camera,integ,sum)} {incr i} {
               set file "acqinteg${i}${::eye::extension}"
               if {$i==0} {
                  buf$::eye::bufNo load $file
               } else {
                  buf$::eye::bufNo add $file 0
               }
            }
            ::confVisu::autovisu $::eye::visuNo
            update
#            gren_info "Temps d'exposition : $tt sec (coadds = $i) Mean img [lindex [buf$::eye::bufNo stat] 4]\n"

            #buf$::eye::bufNo load $file
            #::confVisu::autovisu $::eye::visuNo
         }
      }
      return
   }

   proc ::eye::acq_continue { } {

      set ::eye::acq_boucle 1
      while {$::eye::acq_boucle == 1} {
         ::eye::acq_une_image
         if {$::eye::acq_boucle == 0} {
            gren_info "Acquisition Stoppee par l utilisateur\n"
         }
      }

   }

   proc ::eye::acq_stop { } {
      set ::eye::acq_boucle 0
      gren_info "Demande d arret de l acquisition continue\n"
   }

   proc ::eye::camera_simulation { } {
      gren_info "Simule une image sur les coordonnees de la monture\n"
      gren_info "VISU  = $::eye::visuNo\n"
      gren_info "BufNo = $::eye::bufNo\n"
      gren_info "BufNo = $::eye::bufNo\n"
      # --- 752 x 576 => 8.6 x 8.4 µm F = 25e-3
      set ra  $::eye::widget(coord,wanted,raJ2000)
      set dec $::eye::widget(coord,wanted,decJ2000)

      set ra  [expr [mc_angle2deg $ra] + $::eye::widget(simu,dra)/60.0]
      set dec [expr [mc_angle2deg $dec] + $::eye::widget(simu,ddec)/60.0]

      gren_info "Center = $ra $dec\n"
      set simunaxis1 720
      set simunaxis2 576
      set pixsize1 8.6
      set pixsize2 8.3
      set foclen 25e-3
      # --- utiliser uniquement le cataloguie TYCHO2 au format USNO
      set path_usno $::eye::widget(simu,catalog)
      # --- parametres de simulation
      set exposure_s [expr 1./15]
      set fwhm_pix 3
      set teldiam_m [expr $foclen/1.4]
      set colfilter C
      set sky_brightness_mag 20
      set quantum_efficiency 0.7
      set gain_e 5
      set readout_noise_e 30
      set shutter_mode 1
      set bias_level_ADU 100
      set thermic_response_e 10
      set Tatm 0.6
      set Topt 0.9
      set EMCCD_mult 1
      #
      buf$::eye::bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      set dateobs [get_date_sys2ut]
      set commande "buf$::eye::visuNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      set err1 [catch {eval $commande} msg]
      set commande "buf$::eye::visuNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      set err1 [catch {eval $commande} msg]
      simulimage $ra $dec $pixsize1 $pixsize2 $foclen USNO $path_usno $exposure_s $fwhm_pix $teldiam_m $colfilter $sky_brightness_mag $quantum_efficiency $gain_e $readout_noise_e $shutter_mode $bias_level_ADU $thermic_response_e $Tatm $Topt $EMCCD_mult
   }









   proc ::eye::tel_move_offset_obsolete { } {
      gren_info "Simule une image sur les coordonnees de la monture\n"
      gren_info "VISU = $::eye::visuNo\n"
      gren_info "BufNo = $::eye::bufNo\n"
      gren_info "BufNo = $::eye::bufNo\n"
      # --- 752 x 576 => 8.6 x 8.4 µm F = 25e-3
      set ra  $::eye::widget(coord,wanted,raJ2000)
      set dec $::eye::widget(coord,wanted,decJ2000)

      set ra  [expr [mc_angle2deg $ra] + $::eye::widget(simu,dra)/60.0]
      set dec [expr [mc_angle2deg $dec] + $::eye::widget(simu,ddec)/60.0]

      set ra  [expr $ra  + [mc_angle2deg $::eye::widget(coord,reticule,draJ2000)]]
      set dec [expr $dec + [mc_angle2deg $::eye::widget(coord,reticule,ddecJ2000)]]

      gren_info "Center = $ra $dec\n"
      set simunaxis1 720
      set simunaxis2 576
      set pixsize1 8.6
      set pixsize2 8.3
      set foclen 25e-3
      # --- utiliser uniquement le cataloguie TYCHO2 au format USNO
      set path_usno $::eye::widget(simu,catalog)
      # --- parametres de simulation
      set exposure_s [expr 1./25]
      set fwhm_pix 1
      set teldiam_m [expr $foclen/1.4]
      set colfilter C
      set sky_brightness_mag 22
      set quantum_efficiency 0.9
      set gain_e 3
      set readout_noise_e 30
      set shutter_mode 1
      set bias_level_ADU 100
      set thermic_response_e 10
      set Tatm 0.6
      set Topt 0.9
      set EMCCD_mult 1
      #
      buf$::eye::bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      set dateobs [get_date_sys2ut]
      set commande "buf$::eye::visuNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      set err1 [catch {eval $commande} msg]
      set commande "buf$::eye::visuNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      set err1 [catch {eval $commande} msg]
      simulimage $ra $dec $pixsize1 $pixsize2 $foclen USNO $path_usno $exposure_s $fwhm_pix $teldiam_m $colfilter $sky_brightness_mag $quantum_efficiency $gain_e $readout_noise_e $shutter_mode $bias_level_ADU $thermic_response_e $Tatm $Topt $EMCCD_mult

   }

