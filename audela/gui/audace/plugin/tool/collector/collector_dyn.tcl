#
## @file collector_dyn.tcl
#  @brief Gère la mise à jour des variables
#  @author Raymond Zachantke
#  $Id: collector_dyn.tcl 14244 2017-07-06 17:11:57Z robertdelmas $
#

   #--   Liste des proc                   utilisee par
   # ::collector::updateInfo              testPattern et testNumeric
   # ::collector::computeOptic            updateInfo
   # ::collector::computeCdeltFov         updateInfo, modifyCamera
   # ::collector::computeCenterPixVal     updateInfo, modifyCamera, initPose
   # ::collector::computeTslMoon          updateInfo, refreshSpeed, initLocal
   # ::collector::computeTelCoord         updateInfo et refreshCoordsJ2000
   # ::collector::modifyBand              combobox des filtres
   # ::collector::modifyCamera            combobox du choix de la camera
   # ::collector::modifyPriority          combobox du choix de la priorite, modifyBand, modifyCamera, computeTslMoon, updateInfo et updateEtc
   # ::collector::modifyRep               combobox du choix du catalogue
   # ::collector::refreshNotebook         configTraceRaDec
   # ::collector::refreshCoordsJ2000      initTarget, refreshNotebook, doUnPark et doPark
   # ::collector::refreshMeteo            initAtm
   # ::collector::computeTelSpeed         refreshNotebook

   #---------------------------------------------------------------------------
   #  brief met à jour Collector en fonction du paramètre modifié
   #  param child nom de la variable modifiée
   #
   proc ::collector::updateInfo { child } {
      variable private
      global cameras

      if {$child in [list aptdia fond seeing]} {
         ::collector::computeOptic
      } elseif {$child in [list tu gps]} {
         ::collector::computeTslMoon
      } elseif {$child in [list ra dec equinox temperature airpressure]} {
         ::collector::computeTslMoon
         ::collector::computeTelCoord
         ::collector::computeCenterPixVal
      } elseif {$child in [list bin1 bin2 naxis1 naxis2 crota2 photocell1 photocell2]} {
         ::collector::computeCdeltFov
         ::collector::computeCenterPixVal
      }

      if {$child in [string map { \{ "" \} "" } $private(etc_variables)]} {
         ::collector::modifyPriority
      }

      #--   configure les boutons de commandes
      ::collector::configCmd
   }

   #------------------------------------------------------------
   #  brief met à jour les paramètres optiques
   #
   proc ::collector::computeOptic { } {
      variable private

      lassign [getFonDResolution $private(aptdia) $private(foclen)] \
         private(fond) private(resolution)

      set error 10
      set private(ncfz) [::collector::getNewCriticalFocusZone $private(fond) $private(aptdia) $private(seeing) $error]
      set ncfz [::collector::getNewCriticalFocusZone $private(fond) $private(aptdia) $private(seeing) $error]
      if {$ncfz ne "-"} {
         set private(ncfz) [format %0.1f $ncfz]
      } else {
         set private(ncfz) $ncfz
      }

      set private(focus_pos) $::audace(focus,currentFocus)
   }

   #------------------------------------------------------------
   #  brief met à jour l'échantillonnage et le champ
   #
   proc ::collector::computeCdeltFov { } {
      variable private

      #--   raccourcis
      foreach v [list naxis1 naxis2 bin1 bin2 photocell1 photocell2 foclen] \
         {set $v $private($v)}

      set private(pixsize1) [expr { $photocell1 * $bin1 }]
      set private(pixsize2) [expr { $photocell2 * $bin2 }]

      lassign [getCdeltFov $naxis1 $naxis2 $private(pixsize1) $private(pixsize2) $foclen] \
         private(cdelt1) private(cdelt2) private(fov1) private(fov2)
   }

   #------------------------------------------------------------
   #  brief met à jour les coordonnées du centre de l'image
   #
   proc ::collector::computeCenterPixVal { } {
      variable private

      set private(crpix1) [expr { $private(naxis1)/2. } ]
      set private(crpix2) [expr { $private(naxis2)/2. } ]

      set private(crval1) [string trim [mc_angle2deg $private(ra)]]
      set private(crval2) [string trim [mc_angle2deg $private(dec)]]
   }

   #------------------------------------------------------------
   # brief met à jour le temps JD, TSL et la Lune
   #
   proc ::collector::computeTslMoon { } {
      variable private

      set private(jd) [mc_date2jd $private(tu)]
      set private(tsl) [getTsl $private(tu) $private(gps)]

      lassign [getMoonAge $private(jd) $private(gps)] \
         private(moonphas) private(moonalt) private(moon_age)

      etc_params_set moon_age $private(moon_age)

      ::collector::modifyPriority
    }

   #------------------------------------------------------------
   #  brief met à jour les coordonnées du télescope
   #
   proc ::collector::computeTelCoord { } {
      variable private

      set data [list $private(ra) $private(dec) $private(jd) $private(gps) \
         $private(pressure) $private(temperature) $private(humidity)]
      if {"-" in $data} {return}

      lassign [::collector::getTrueCoordinates $data] private(raTel) private(decTel) \
         private(haTel) private(azTel)  private(elevTel)

      #--   rafaichit secz et airmass de l'onglet Atmosphere
      lassign [getSecz $private(elevTel)] private(secz) private(airmass)
   }

   #----------------- proc associees aux combobox -----------------------------

   #------------------------------------------------------------
   #  brief modifie les variables band et associées de etc_tools
   #
   proc ::collector::modifyBand { } {
      variable private
      global audace

      set audace(etc,param,object,band) $private(filter)
      etc_modify_band $private(filter)

      ::collector::modifyPriority
   }

   #------------------------------------------------------------
   #  brief configure l'affichage des paramètres de la caméra
   #
   proc ::collector::modifyCamera { } {
      variable private

      #--   interdit 'Nouvelle camera'
      if {$private(detnam) eq "$::caption(collector,newCam)"} {
         ::collector::addNewCam
         return
      }

      etc_set_camera $private(detnam)

      #--   recupere les valeurs de etc_tools
      foreach {var key} [list naxis1 naxis1 naxis2 naxis2 bin1 bin1 bin2 bin2 photocell1 photocell1 \
         photocell2 photocell2 eta eta gain G noise N_ro therm C_th ampli Em] {
         if {$var ni [list photocell1 photocell2]} {
            set private($var) $::audace(etc,param,ccd,$key)
         } else {
            #--   affiche la dimension des cellules en mum
            set private($var) [expr { $::audace(etc,param,ccd,$key) * 1e6 }]
         }
      }

      ::collector::computeCdeltFov
      ::collector::computeCenterPixVal
      ::collector::modifyPriority
   }

   #------------------------------------------------------------
   #  brief commande associée à la combobox du choix de la priorité
   #
   proc ::collector::modifyPriority { } {
      variable private
      global audace caption

      #etc_preliminary_computations
      switch -exact [lsearch $caption(collector,prior_combo) $private(prior)] {
        0   {  #--   priorite au temps --> calcule la magnitude et snr
               etc_t2snr_computations
               set private(snr) $audace(etc,compsnr,SNR_obj)
               set private(error) [format %.3f [expr { 1.09 / $private(snr) }] ]
            }
        1   {  #--   priorite la magnitude --> calcule le temps et snr
               etc_snr2m_computations
               set private(error) [format %.3f [expr { 1.09 / $audace(etc,input,constraint,snr) }] ]
            }
        2   {  #--   priorite a snr --> calcule le temps et la magnitude
               etc_snr2t_computations
               set private(error) [format %.3f [expr { 1.09 / $audace(etc,input,constraint,snr) }] ]
            }
      }

      #-- conversion de fwhm (m) en (arcsec)
      set fwhm [expr { $audace(etc,comp1,Fwhm_psf) / $audace(etc,comp1,Foclen) * 180 / 4 / atan(1) * 3600 } ]

      #-- conversion de fwhm (arcsec) en (pixels)
      set private(fwhm) [format %0.2f [expr { $fwhm / $audace(etc,comp1,cdelt1) } ]]
   }

   #------------------------------------------------------------
   #  brief met à jour le chemin d'accès du répertoire choisi
   #
   proc ::collector::modifyRep {} {
      variable private
      global audace

      switch -exact $private(catname) {
         MICROCAT { set private(catAcc) $audace(rep_userCatalogMicrocat)}
         USNO     { set private(catAcc) $audace(rep_userCatalogUsnoa2)}
      }
   }

   #------------------------------------------------------------
   #  brief met à jour les paramètres et la vitesse du télescope
   #  param args arguments de \::collector::configTraceRaDec
   #
   proc ::collector::refreshNotebook { args } {
      variable private
      global audace

      #--   met a jour les coordonnees visees a partir des coordonnees du telescope
      ::collector::refreshCoordsJ2000 $audace(telescope,getra) $audace(telescope,getdec) EQUATORIAL

      ::collector::computeTelSpeed

      if {[winfo exists $private(canvas)] == 1 && $private(german) == 1} {
         refreshMyTel
      }
   }

   #------------------------------------------------------------
   #  brief met à jour les coordonnées de la cible et du télescope
   #  param coord1
   #  param coord2
   #  param TypeObs EQUATORIAL ALTAZ ou HADEC
   #
   #  couples {coord1 coord2) :  {ra dec} EQUATORIAL ou {az elev} ALTAZ ou {hour_angle dec} HADEC
   #
   proc ::collector::refreshCoordsJ2000 { coord1 coord2 TypeObs } {
      variable private
      global audace

      #--   rafraichit TU et JD
      lassign [getDateTUJD [::audace::date_sys2ut now]] private(tu) private(jd)

      #--   prepare la liste des donnees
      set record [list $coord1 $coord2 $TypeObs $private(tu) $private(gps) \
         $audace(meteo,obs,pressure) $audace(meteo,obs,temperature) $audace(meteo,obs,humidity)]

      #--   coordonnees J2000 du telescope
      lassign [::collector::getCoordJ2000 $record] private(ra) private(dec)

      ::collector::computeTelCoord
      ::collector::computeCenterPixVal
      ::collector::computeTslMoon
   }

   #------------------------------------------------------------
   #  brief met à jour l'onglet "Météo"
   #  details valeurs par défaut ou données de realtime.txt ou de infodata.tx
   #
   proc ::collector::refreshMeteo { } {
      variable private
      global audace

      set private(temperature)  $audace(meteo,obs,temperature)
      set private(humidity)     $audace(meteo,obs,humidity)
      set private(pressure)     $audace(meteo,obs,pressure)
      set private(temprose)     $audace(meteo,obs,temprose)
      set private(windsp)       $audace(meteo,obs,windsp)
      set private(winddir)      $audace(meteo,obs,winddir)
      if {[info exists ::station_meteo::widget(cycle)] eq "1"} {
         set cycle [expr { $::station_meteo::widget(cycle)*1000 }] ; #convertit en ms
      } else {
         set cycle  10000 ; # n ms
      }
      update

      after $cycle ::collector::refreshMeteo
   }

   #------------------------------------------------------------
   #  brief met à jour la vitesse du télescope
   #
   proc ::collector::computeTelSpeed { } {
      variable private

      #--   recupere les coordonnes actuelles du telescope
      set ra1 $private(raTel)
      set dec1 $private(decTel)
      set t1 $private(jd)

      if {[info exists private(previous)]} {
         lassign $private(previous) ra0 dec0 t0
         set private(previous) [list $ra1 $dec1 $t1]
      } else {
         #--   cas du demarrage
         set private(previous) [list $ra1 $dec1 $t1]
         return
      }

      #--   calcule les ecarts en degres
      set deltaRA [mc_anglescomp $ra1 - $ra0]
      set deltaDEC [mc_anglescomp $dec1 - $dec0]
      set deltaTime [expr { ( $t1 - $t0 ) * 86400 }]

      if {$deltaRA != "0" && $deltaDEC != 0 && $deltaTime != 0} {
         #--   calcule la vitesse de deplacement
         lassign [getMountSpeed $deltaRA $deltaDEC $deltaTime $private(cdelt1) $private(cdelt2) $private(crota2)] \
            vra vdec vxPix vyPix

         set private(vra) [format %0.5f $vra]
         set private(vdec) [format %0.5f $vdec]
         set private(vxPix) [format %0.1f $vxPix]
         set private(vyPix) [format %0.1f $vyPix]

      } else {
         set private(vra) [format %0.5f 0]
         set private(vdec) [format %0.5f 0]
         set private(vxPix) [format %0.1f 0]
         set private(vyPix) [format %0.1f 0]
      }
   }

