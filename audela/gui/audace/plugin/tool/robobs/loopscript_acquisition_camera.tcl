## @file      loopscript_acquisition_camera.tcl 
#  @brief     According to the scene to observe, starts a camera acquisition.
#             In the case of science image acquisition, the script wait the
#             end of exposure and updates the FITS header with the maximum of
#             informations.
#  @pre       This script will be sourced in the loop
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_acquisition_camera.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_acquisition_camera.tcl 14476 2018-09-14 13:59:59Z alainklotz $


# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,filenames) ""

set pi [expr 4*atan(1)]




#------------------------------------------------------------
## Explication de la procedure ?
#  @param exposure exposure time 
#  @return void
#  @todo A completer
#
proc acq_set_fits_header { exposure } {
   global robobs audace conf
   set camNo $robobs(conf,camera,camno,value)
   set bufNo $audace(bufNo)
   # --- Complete the FITS header
   set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
   set pi [expr 4*atan(1)]
   set type [::robobs::key2val $robobs(next_scene,slew) type]   
   if {$type=="radec"} {
      set ra [::robobs::key2val $robobs(next_scene,slew) ra]   
      set ra [mc_angle2deg $ra ]
   } else {
      set ra 0
   }
   set dec [::robobs::key2val $robobs(next_scene,slew) dec]   
   set dec [mc_angle2deg $dec 90]
   set dra [::robobs::key2val $robobs(next_scene,slew) dra]
   set ddec [::robobs::key2val $robobs(next_scene,slew) ddec]
   set longitude [lindex $robobs(conf,home,gps,value) 1]
   set sens [lindex $robobs(conf,home,gps,value) 2]
   if {$sens=="W"} {
      set longitude [expr -1.*$longitude]
   }
   set latitude [lindex $robobs(conf,home,gps,value) 3]
   set altitude [lindex $robobs(conf,home,gps,value) 4]
   set mjd [expr [mc_date2jd [lindex [buf$bufNo getkwd DATE-OBS] 1 ]]-2400000.5]
   if {$robobs(cam,name)=="simulation"} {
      set pixsize1 9
      set pixsize2 9
   } else {
      set commande "lindex \[cam$camNo pixdim\] 0"
      set err1 [catch {eval $commande} msg]
      set pixsize1 [expr (1e6*$msg)]
      set commande "lindex \[cam$camNo pixdim\] 1"
      set err1 [catch {eval $commande} msg]
      set pixsize2 [expr (1e6*$msg)]
   }
   set foclen $robobs(conf,optic,foclen,value)
   set diamtel $robobs(conf,optic,diam,value)
   set cdelt1 [expr -2*atan($pixsize1*1e-6/$foclen/2.)*180/$pi]
   set cdelt2 [expr  2*atan($pixsize2*1e-6/$foclen/2.)*180/$pi]
   set crota2 0
   set crpix1 [expr $naxis1/2]
   set crpix2 [expr $naxis2/2]
   # --- observing conditions
   set commande "buf$bufNo setkwd \{ \"EXPOSURE\" \"$exposure\" \"string\" \"Total time of exposure\" \"s\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"MJD-OBS\" \"$mjd\" \"double\" \"Start of exposure JD-2400000.5\" \"d\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"TRACKSPA\" \"$dra\" \"double\" \"Tracking for HA\" \"deg/s\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"TRACKSPD\" \"$ddec\" \"double\" \"Tracking for DEC\" \"deg/s\" \}"
   set err1 [catch {eval $commande} msg]
   # --- Observatory location
   set commande "buf$bufNo setkwd \{ \"OBS-LONG\" \"$longitude\" \"float\" \"east-positive observatory longitude\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"OBS-LAT\" \"$latitude\" \"float\" \"geodetic observatory latitude\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"OBS-ELEV\" \"$altitude\" \"float\" \"elevation above sea of observatory\" \"m\" \}"
   set err1 [catch {eval $commande} msg]
   # --- WCS classique
   set commande "buf$bufNo setkwd \{ \"RADESYS\" \"FK5\" \"string\" \"Mean Place IAU 1984 system\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"EQUINOX\" \"2000\" \"string\" \"System of equatorial coordinates\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CTYPE1\" \"RA---TAN\" \"string\" \"Gnomonic projection\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CTYPE2\" \"DEC--TAN\" \"string\" \"Gnomonic projection\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"LONPOLE\" \"180\" \"float\" \"Long. of the celest.NP in native coor.sys\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CUNIT1\" \"deg\" \"string\" \"Angles are degrees always\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CUNIT2\" \"deg\" \"string\" \"Angles are degrees always\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"RADESYS\" \"FK5\" \"string\" \"Mean Place IAU 1984 system\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CRPIX1\" \"$crpix1\" \"double\" \"X ref pixel\" \"pixel\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CRPIX2\" \"$crpix2\" \"double\" \"Y ref pixel\" \"pixel\" \}"
   set err1 [catch {eval $commande} msg]   
   set commande "buf$bufNo setkwd \{ \"CRVAL1\" \"$ra\" \"double\" \"RA for CRPIX1\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CRVAL2\" \"$dec\" \"double\" \"DEC for CRPIX2\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]   
   set commande "buf$bufNo setkwd \{ \"CDELT1\" \"$cdelt1\" \"double\" \"Scale along axis 1\" \"deg/pix\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CDELT2\" \"$cdelt2\" \"double\" \"Scale along axis 2\" \"deg/pix\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"CROTA2\" \"$crota2\" \"double\" \"Position angle of North\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]
   # --- WCS etendu
   set commande "buf$bufNo setkwd \{ \"RA\" \"$ra\" \"double\" \"Expected RA asked to telescope\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"DEC\" \"$dec\" \"double\" \"Expected DEC asked to telescope\" \"deg\" \}"
   set err1 [catch {eval $commande} msg]   
   set commande "buf$bufNo setkwd \{ \"PIXSIZE1\" \"$pixsize1\" \"float\" \"Pixel size along naxis1\" \"um\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"PIXSIZE2\" \"$pixsize2\" \"float\" \"Pixel size along naxis2\" \"um\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"FOCLEN\" \"$foclen\" \"double\" \"Focal length\" \"m\" \}"
   set err1 [catch {eval $commande} msg]   
   # --- Ajoute les mots clé de la configuration header du pluggin Acquisition
   set visuNo $audace(visuNo)
   set key_protected {CRPIX1 CRPIX2 RA DEC DEC OBJNAME CRVAL1 CRVAL2 CROTA2 FOCLEN}
   set err0 [catch {
      foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqfc,keywordConfigName) ] {
         set key [lindex $keyword 0]
         set k [lsearch -exact $key_protected $key]
         set val [lindex $keyword 1]
         if {($k==-1)&&($val!={})} {
            set commande "buf$bufNo setkwd"
            lappend commande $keyword
            set err1 [catch {eval $commande} msg]   
         }
      }
   } msg0]
   if {$err0==1} {
      ::robobs::log "Errror in proc acq_set_fits_header : $msg0"
   }
   # --- Ajoute les mots clé de la météo
   if {[info exists robobs(private,meteo_headerfits)]==1} {
      set err0 [catch {
         foreach keyword $robobs(private,meteo_headerfits) {
            set commande "buf$bufNo setkwd"
            lappend commande $keyword
            set err1 [catch {eval $commande} msg]   
         }
      } msg0]
      if {$err0==1} {
         ::robobs::log "Errror in proc acq_set_fits_header : $msg0"
      }
   }   
   # --- Ajoute les mots clé de l'UPS
   if {[info exists robobs(private,ups_headerfits)]==1} {
      set err0 [catch {
         foreach keyword $robobs(private,ups_headerfits) {
            set commande "buf$bufNo setkwd"
            lappend commande $keyword
            set err1 [catch {eval $commande} msg]   
         }
      } msg0]
      if {$err0==1} {
         ::robobs::log "Errror in proc acq_set_fits_header : $msg0"
      }
   }   
}
# Fin de procedure acq_set_fits_header ------------------------------------------------------------

if {$robobs(next_scene,action)!="none"} {

   set camNo $robobs(conf,camera,camno,value)
   set bufNo $audace(bufNo)
      
   # --- Loop over the images of this scene
   ::robobs::log "[llength $robobs(next_scene,images)] scenes to observe"
   set kimage 0
   set nimage [llength $robobs(next_scene,images)]
   set exposure0 120
   set repetition 0
   if {($robobs(conf,home,telescope_id,value)=="makes_t60")&&($nimage>0)} {
      power flat 0 2500
   }
   
   while {$kimage<$nimage} {
      set imagedefs [lindex $robobs(next_scene,images) $kimage]
      # ::robobs::log "STEP -90 robobs(next_scene,images)=$robobs(next_scene,images)"
      incr kimage
      
      # --- default values
      set binx 1         
      set biny 1
      set shutter_mode synchro
      set exposure $exposure0
      set object_name not_defined
      set comment ""
      set simunaxis1 400
      set simunaxis2 300
      set skylevel 17
      set filter_name L
      set window -
         
      # --- specified values
      foreach imagedef $imagedefs {
         
         set key [lindex $imagedef 0]
         set val [lindex $imagedef 1]
         
         if {$key=="name"} { set object_name $val }
         if {$key=="exposure"} { set exposure $val }
         if {$key=="shutter_mode"} { set shutter $val }
         if {$key=="filter_name"} { set filter_name $val }
         if {$key=="binx"} { set binx $val }
         if {$key=="biny"} { set biny $val }
         if {$key=="comment"} { set comment $val }
         if {$key=="simunaxis1"} { set simunaxis1 $val }
         if {$key=="simunaxis2"} { set simunaxis2 $val }
         if {$key=="skylevel"} { set skylevel $val }
         if {$key=="window"} { set window $val }
         
      }
      ::robobs::log "Scene $object_name (exposure=$exposure)"
      set res [lindex [split $object_name _] 1]
      set tospeak "$res"
      catch {exec espeak.exe -v fr "$tospeak"}

      # --- flat light
      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         set flatlight [::robobs::key2val $imagedefs flatlight]
         if {$flatlight!=""} {
            power flat $flatlight 1500
            ::robobs::log "power flat $flatlight 1500" 3
         }
         # --- Close the roof during the darks and flats
         if {$robobs(next_scene,action)=="flat & dark"} {
            robobs_dome_close
         }
      }
      
      # --- loop over the exposure time if needed (when searchexpo==1)
      while {1==1} {

         # --- searchexpo=1 in case where the exposure time must be optimized (flat cases)
         set searchexpo 0
         if {($object_name=="flat1")&&($repetition==0)} {
            set k [string first ? $exposure]
            ::robobs::log "k = $k exposure=$exposure" 3
            if {$k>=0} {
               set exposure [string range $exposure 0 [expr $k-1]]
               set searchexpo 1
            }
         } else {
            set k [string first ? $exposure]
            if {$k>=0} {
               set exposure $exposure0
            }
         }
         set repetition 0
      
         # --- Stop the current image 
         set command "cam$camNo stop"
         ::robobs::log "$command" 3
         if {$robobs(cam,name)!="simulation"} {
            set err [catch {uplevel #0 "$command"} msg]
            if {$err==1} {
               ::robobs::log "$step ERROR $msg" 3
               error $msg
            }
         }
         
         # --- Set the window
         if {$window!="-"} {
            set command "cam$camNo window \[list $window\]"
            ::robobs::log "$command" 3
            if {$robobs(cam,name)!="simulation"} {
               set err [catch {uplevel #0 "$command"} msg]
               if {$err==1} {
                  ::robobs::log "$step ERROR $msg" 3
                  error $msg
               }
            }
         }
         
         # --- Set the binning   
         set command "cam$camNo bin \[list $binx $biny\]"
         ::robobs::log "$command" 3
         if {$robobs(cam,name)!="simulation"} {
            set err [catch {uplevel #0 "$command"} msg]
            if {$err==1} {
               ::robobs::log "$step ERROR $msg" 3
               error $msg
            }
         }
         
         # --- Set the exposure time
         set command "cam$camNo exptime $exposure"
         ::robobs::log "$command" 3
         if {$robobs(cam,name)!="simulation"} {
            set err [catch {uplevel #0 "$command"} msg]
            if {$err==1} {
               ::robobs::log "$step ERROR $msg" 3
               error $msg
            }
         }
         
         # --- Select the shutter mode
         set command "cam$camNo shutter $shutter"
         ::robobs::log "$command" 3
         if {$robobs(cam,name)!="simulation"} {
            set err [catch {uplevel #0 "$command"} msg]
            if {$err==1} {
               ::robobs::log "$step ERROR $msg" 3
               error $msg
            }
         }
         if {$shutter=="closed"} {
            set tospeak "Commence darke [format %.0f $exposure] secondes. Binning $binx."
         } else {
            if {$robobs(next_scene,action)=="flat"} {
               set tospeak "Commence flatte [format %.0f $exposure] secondes. Binning $binx."
            } else {
               set tospeak "Commence image [format %.0f $exposure] secondes. Binning $binx."
            }
         }
         catch {exec espeak.exe -v fr "$tospeak"}
       
         # --- Select the filter
         if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
            if {$filter_name=="C"} {
               set filter_name L
            }
            ::robobs::log "Select the filter $filter_name"
            filtre $filter_name
         }
         
         # --- Start the exposure
         set dateobs [mc_date2iso8601 [::audace::date_sys2ut]]
         set command "cam$camNo acq"
         ::robobs::log "$command" 3
         if {$robobs(cam,name)!="simulation"} {
            set err [catch {uplevel #0 "$command"} msg]
            ::robobs::log "acquisition launched $msg"
            if {$err==1} {
               ::robobs::log "$step ERROR $msg" 3
               error $msg
            }
         }
      
         # --- Wait the end of the exposure
         set t0 [clock seconds]
         set timeout [expr $exposure+30.] ; # TODO replace 30 by readouttime+delay
         set sortie 0
         while {$sortie==0} {
            set dt [expr [clock seconds]-$t0]
            if {$robobs(cam,name)=="simulation"} {
               set ti [expr $exposure-$dt]
            } else {
               set ti [cam$camNo timer]
            }
            ::robobs_acquisition::state_loop "$step ($dt seconds)"
            ::robobs::log "timer=$ti [format %.0f [expr abs($dt)]] sec. (timeout=$timeout sec.)" 40
            update
            after 1000
            # --- Check for a normal end of acquisition
            if {$ti==-1} {
               set sortie 1
            }
            # --- Check for a timeout
            if {$dt>$timeout} {
               set sortie 1
            }
            if {$robobs(next_scene,action)!="flat & dark"} {
               # --- Check for meteo problems
               read_meteosensor
               if {$robobs(meteo,global_check)=="PB"} {
                  ::robobs::log "$caption(robobs,exit_script) $step METEO WARNING $robobs(meteo,global_check) : $robobs(meteo,global_comment)"
                  set sortie 10
               }
               # --- Check for power supply problems
               read_ups
               if {$robobs(ups,global_check)=="PB"} {
                  ::robobs::log "$caption(robobs,exit_script) $step UPS WARNING $robobs(ups,global_check) : $robobs(ups,global_comment)"
                  set sortie 10
               }
            }
            # --- Check for a premature signal to exit the steps
            if {[::robobs_acquisition::signal_loop]==1} {
               ::robobs::log "$step EXIT_LOOP signal" 3
               set sortie 11
            }
            update         
         }
         if {$sortie>=10} {
            # --- Stop acquisition in case of problems            
            set command "cam$camNo stop"
            ::robobs::log "$command" 3
            if {$robobs(cam,name)!="simulation"} {
               set err [catch {uplevel #0 "$command"} msg]
               ::robobs::log "acquisition stoped $msg"
               if {$err==1} {
                  ::robobs::log "$step ERROR $msg" 3
                  error $msg
               }
            }
            ::robobs::log "Acquisition stopped at [format %.1f $dt] sec. Exposure asked : $exposure" 3
            set robobs(image,filenames) ""
            set robobs(image,dfilenames) ""
            set robobs(image,ffilenames) ""
            set tospeak "Fin de pose prématurée."
            catch {exec espeak.exe -v fr "$tospeak"}
				# --- Telescope name: simulation or real
				set telNo $robobs(conf,telescope,telno,value)
				if {$telNo>0} {
					::robobs::log "tel$telNo radec motor off"
					tel$telNo radec motor off
				}
            return ""
         }
         ::robobs::log "Acquisition complete in [format %.1f $dt] sec. Exposure asked : $exposure" 3
      
         # --- Simulation of the image if needed
         if {$robobs(cam,name)=="simulation"} {
            buf$bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
            set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
            set err1 [catch {eval $commande} msg]
            set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
            set err1 [catch {eval $commande} msg]
         }
         
         # --- Complete the FITS header
         acq_set_fits_header $exposure
         if {$comment!=""} {
            set commande "buf$bufNo setkwd \{ \"COMMENT\" \"$comment\" \"string\" \"\" \"\" \}"
            set err1 [catch {eval $commande} msg]   
         }
         set commande "buf$bufNo setkwd \{ \"OBJENAME\" \"$object_name\" \"string\" \"\" \"\" \}"
         set err1 [catch {eval $commande} msg]      
         set commande "buf$bufNo setkwd \{ \"OBJECT\" \"$object_name\" \"string\" \"\" \"\" \}"
         set err1 [catch {eval $commande} msg]      
         set commande "buf$bufNo setkwd \{ \"FILTER\" \"$filter_name\" \"string\" \"Filter symbol\" \"\" \}"
         set err1 [catch {eval $commande} msg]
         if {$filter_name=="R"} {
            set centrwv 6215
            set bandwidth 1390
            set wavemin [expr $centrwv-$bandwidth/2]
            set wavemax [expr $centrwv+$bandwidth/2]
         } elseif {$filter_name=="L"} {
            set wavemin 3900
            set wavemax 6900
            set centrwv [expr ($wavemin+$wavemax)/2.]
            set bandwidth [expr ($wavemax-$wavemin)]
         } elseif {$filter_name=="B"} {
            set wavemin 3800
            set wavemax 5000
            set centrwv [expr ($wavemin+$wavemax)/2.]
            set bandwidth [expr ($wavemax-$wavemin)]
         } elseif {$filter_name=="V"} {
            set wavemin 5000
            set wavemax 5800
            set centrwv [expr ($wavemin+$wavemax)/2.]
            set bandwidth [expr ($wavemax-$wavemin)]
         } elseif {$filter_name=="Ha"} {            
            set centrwv 6560
            set bandwidth 120
            set wavemin [expr $centrwv-$bandwidth/2]
            set wavemax [expr $centrwv+$bandwidth/2]
            
         } else {
            set wavemin 4000
            set wavemax 9000
            set centrwv [expr ($wavemin+$wavemax)/2.]
            set bandwidth [expr ($wavemax-$wavemin)]
         }
         set commande "buf$bufNo setkwd \{ \"BANDWID\" \"$bandwidth\" \"float\" \"Filter band width\" \"A\" \}"
         set err1 [catch {eval $commande} msg]
         set commande "buf$bufNo setkwd \{ \"CENTRWV\" \"$centrwv\" \"float\" \"Filter central wavelength\" \"A\" \}"
         set err1 [catch {eval $commande} msg]
         set commande "buf$bufNo setkwd \{ \"WAVEMIN\" \"$wavemin\" \"float\" \"Filter minimal wavelength\" \"A\" \}"
         set err1 [catch {eval $commande} msg]
         set commande "buf$bufNo setkwd \{ \"WAVEMAX\" \"$wavemax\" \"float\" \"Filter maximal wavelength\" \"A\" \}"
         set err1 [catch {eval $commande} msg]
         set commande "buf$bufNo setkwd \{ \"SHUTTER\" \"$shutter\" \"string\" \"Shutter action\" \"\" \}"
         set err1 [catch {eval $commande} msg]      
         
         # --- Simulation of the image if needed
         set diamtel $robobs(conf,optic,diam,value)
         if {$robobs(cam,name)=="simulation"} {
            ::robobs::log "Simulate the image" 3
            set shut 1
            if {$shutter=="closed"} { set shut 0 }
            set newstar ""
            if {($robobs(planif,mode)=="vttrrlyr")&&($shutter!="closed")} {
               if {$object_name=="rrlyr"} {
                  # hjdmax = 2442923.49+0.56683500*$e-1e-10*$e*$e
                  set ra0 291.365878 ; set dec0 42.783933
                  set hjd [lindex [mc_dates_ut2bary $dateobs $ra0 $dec0 J2000] 0]
                  set a -1e-10 ; set b 0.56683500 ; set c [expr 2442923.49-$hjd]
                  set d [expr $b*$b-4.*$a*$c]
                  set e [expr (-$b + sqrt($d) ) / (2.*$a)]
                  set phase [expr $e-floor($e)]
                  set four_c 7.55
                  set four_a(1) -0.098 ; set four_b(1)  0.168
                  set four_a(2)  0.099 ; set four_b(2) -0.008
                  set four_a(3) -0.050 ; set four_b(3) -0.035
                  set four_a(4)  0.011 ; set four_b(4)  0.032
                  set four_a(5)  0.001 ; set four_b(5) -0.019
                  set mag $four_c
                  set phase0 [expr $phase-0.29]
                  for {set kk 1} {$kk<=5} {incr kk} {
                     set mag [expr $mag + 1.7*($four_a($kk)*cos(2*$pi*$kk*$phase0) + $four_b($kk)*sin(2*$pi*$kk*$phase0))]
                  }            
                  set newstar " REPLACE $ra0 $dec0 $mag"
               } else {
                  # --- for other rrlyr stars
                  set ra0 [::robobs::key2val $imagedefs ra]
                  set ra0 [mc_angle2deg $ra ]
                  set dec0 [::robobs::key2val $imagedefs dec]
                  set dec0 [mc_angle2deg $dec 90]
                  set hjd [lindex [mc_dates_ut2bary $dateobs $ra0 $dec0 J2000] 0]
                  set a -1e-10 ; set b 0.56683500 ; set c [expr 2442923.49+$b/2.-$hjd]
                  set d [expr $b*$b-4.*$a*$c]
                  set e [expr (-$b + sqrt($d) ) / (2.*$a)]
                  set phase [expr $e-floor($e)]
                  set four_c 9.55
                  set four_a(1) -0.098 ; set four_b(1)  0.168
                  set four_a(2)  0.099 ; set four_b(2) -0.008
                  set four_a(3) -0.050 ; set four_b(3) -0.035
                  set four_a(4)  0.011 ; set four_b(4)  0.032
                  set four_a(5)  0.001 ; set four_b(5) -0.019
                  set mag $four_c
                  set phase0 [expr $phase-0.29]
                  for {set kk 1} {$kk<=5} {incr kk} {
                     set mag [expr $mag + 1.7*($four_a($kk)*cos(2*$pi*$kk*$phase0) + $four_b($kk)*sin(2*$pi*$kk*$phase0))]
                  }            
                  set newstar " REPLACE $ra0 $dec0 $mag"
               }
            }
            set toeval "simulimage * * * * * \"$robobs(conf,astrometry,cat_name,value)\" \"$robobs(conf,astrometry,cat_folder,value)\" $exposure 3.5 $diamtel R $skylevel 0.07 2.5 12 $shut 1000 0.5 0.6 0.85 1 1 $newstar"
            eval $toeval
         } else {
            ::audace::autovisu $::audace(visuNo)
         }
         
         # --- Complete the FITS header
         ::bddimagesAdmin::bdi_setcompat $bufNo
         buf$bufNo setkwd [list "BDDIMAGES STATE" "RAW" "string" "RAW | CORR | CATA | ?" ""]
         set type IMG
         set prefix [::robobs::key2val $imagedefs prefix]
         if {$prefix=="FL"} { set type FLAT }
         if {$prefix=="DA"} { set type DARK }
         buf$bufNo setkwd [list "BDDIMAGES TYPE" "${type}" "string" "IMG | FLAT | DARK | OFFSET | ?" ""]
         # --- Insert an entry in the image SQL table
         if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
            set dateobs [lindex [buf$bufNo getkwd DATE-OBS] 1]
            set dateobs [regsub -all T $dateobs " "]
            # sql_mjd1 defined in loopscript_goto_telescope
            set sql_mjd2 [expr [mc_date2jd now]-2400000.5]
            set type [lindex [buf$bufNo getkwd "BDDIMAGES TYPE"] 1]
            if {$robobs(planif,mode)=="vachier_berthier"} {
               set planif Fred
            } else {
               set planif Alain
            }
            ::robobs::log "robobs(next_scene,action)=$robobs(next_scene,action)"
            
            if { $binx != $biny } {
               ::robobs::log "ERROR Binning : Les BINX  et BINY sont differents, attention cas non pris en compte" 0 #FF0000
            } else {
               set bin $binx
            }
            
            set command ""
            append command "INSERT INTO  `t60`.`images` (`date` ,`type` ,`planif` ,`fwhm` ,`zmag` ,`skytemp` ,`humidity` ,`pressure` ,`temperature` ,`exposure` ,`binning`) "
            append command "VALUES ('$dateobs', '$type', '$planif', "
            set re [lindex [buf$bufNo getkwd FWHM] 1] ; if {$re==""} { append command "NULL, " } else { append command "'$re', " }
            append command "NULL, "
            set re [lindex [buf$bufNo getkwd SKYTEMP] 1] ; if {$re==""} { append command "NULL, " } else { append command "'$re', " }
            set re [lindex [buf$bufNo getkwd HUMIDITY] 1] ; if {$re==""} { append command "NULL, " } else { append command "'$re', " }
            set re [lindex [buf$bufNo getkwd PRESSURE] 1] ; if {$re==""} { append command "NULL, " } else { append command "'$re', " }
            set re [lindex [buf$bufNo getkwd TEMP] 1] ; if {$re==""} { append command "NULL, " } else { append command "'$re', " }
            append command "'$exposure', "
            append command "'$bin'"
            append command ");"
            set err [catch {
               ::robobs::log "Insert Mysql"
               if {[info commands ::bddimages_sql::sql]==""} {
                  ::bddimages::ressource
               }
               package require mysqltcl
               set res [::bddimages_sql::sql connect $robobs(conf_planif,vachier_berthier,sql_host) $robobs(conf_planif,vachier_berthier,sql_user) $robobs(conf_planif,vachier_berthier,sql_pass)]
               ::bddimages_sql::sql query $command
               ::bddimages_sql::sql disconnect
            } msg]
            if {$err==1} {
               ::robobs::log "ERROR MySQL : $msg"
               ::robobs::log "SQL command = $command"
            }
         }
         # --- Search for the best exposure time
         #::robobs::log "STEP 40 searchexpo = $searchexpo kimage=$kimage" 3
         if {($searchexpo==1)} {
            set mean [lindex [buf$bufNo stat] 4]
            set adumin [::robobs::key2val $imagedefs adumin]
            set adumax [::robobs::key2val $imagedefs adumax]
            ::robobs::log "mean=$mean adumin=$adumin adumax=$adumax" 3
            if {($mean>=$adumin)&&($mean<=$adumax)} {
               set searchexpo 0
            } else {
               set exposuremin [::robobs::key2val $imagedefs exposuremin]
               set exposuremax [::robobs::key2val $imagedefs exposuremax]
               set adu [expr ($adumin+$adumax)/2.]
               set e [expr 1.*$exposure/$mean*$adu]
               ::robobs::log "e=$e = $exposure/$mean*$adu" 3
               if {$e>$exposuremax} {
                  set exposure $exposuremax
                  set searchexpo 0
               } elseif {$e<$exposuremin} {
                  set exposure $exposuremin
                  set searchexpo 0
               } else {
                  set exposure [format %.1f $e]
               }
               ::robobs::log "New exposure is $exposure sec." 3
               incr kimage -1
               set repetition 1
            }
         }
         if {$searchexpo==0} {
            break
         }
         
      } ; # end of the exposure time searching
      set exposure0 $exposure
      
      # --- Save the FITS file
      set date [mc_date2iso8601 [::audace::date_sys2ut]]
      set prefix [::robobs::key2val $imagedefs prefix]
      if {$prefix==""} {
         set prefix IM
      }
      if {$prefix=="DA"} {
         set fi ""
      } else {
          set fi _$filter_name
      }
      set name ${prefix}_[string range $date 0 3][string range $date 5 6][string range $date 8 9]_[string range $date 11 12][string range $date 14 15][string range $date 17 18]_${object_name}${fi}
      ::robobs::log "Save image $name" 3
      saveima $name
      if {$repetition==0} {
         lappend robobs(image,filenames) $name
      }
      
      set tospeak "Image terminée."
      catch {exec espeak.exe -v fr "$tospeak"}
      
      # --- Update file list of observations
      if {$robobs(planif,mode)=="snresearch1"} {
         set kobs $robobs(planif,snresearch1,kobs)
         set field [lindex $robobs(planif,snresearch1,fields) $kobs]
         set field [lreplace $field 4 4 1]
         set robobs(planif,snresearch1,fields) [lreplace $robobs(planif,snresearch1,fields) $kobs $kobs $field]         
      }      
      
   }
   
   if {$robobs(planif,mode)=="asteroid_light_curve"} {
      incr robobs(planif,asteroid_light_curve,index_last_field)
      if {$robobs(planif,asteroid_light_curve,index_last_field)>3} {
         set robobs(planif,asteroid_light_curve,index_last_field) 1
      }
      #::robobs::log "B robobs(planif,asteroid_light_curve,index_last_field)=$robobs(planif,asteroid_light_curve,index_last_field)" 3
   }
   
   if {$robobs(planif,mode)=="star_light_curve"} {
      incr robobs(planif,star_light_curve,index_last_field)
      if {$robobs(planif,star_light_curve,index_last_field)>3} {
         set robobs(planif,star_light_curve,index_last_field) 1
      }
   }
   
}

# --- Switch off the flat lamp
if {$robobs(next_scene,action)=="flat"} {
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      power flat 0 2500
   }
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
