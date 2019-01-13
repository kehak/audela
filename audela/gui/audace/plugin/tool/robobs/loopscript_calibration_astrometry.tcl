## @file      loopscript_calibration_astrometry.tcl
#  @brief     Explication du fichier ?
#  @pre       This script will be sourced in the loop
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_calibration_astrometry.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_calibration_astrometry.tcl 14446 2018-06-20 18:43:07Z fredvachier $

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,afilenames) ""
set bufNo $audace(bufNo)

if {($robobs(planif,mode)=="vttrrlyr")||($robobs(planif,mode)=="trerrlyr")} {
   
   foreach fname $robobs(image,dfilenames) {
      # --- WCS calibration
      loadima $fname
      set cdpath $robobs(conf,astrometry,cat_folder,value)
      set cattype $robobs(conf,astrometry,cat_name,value)
      set catastar [calibwcs * * * * * $cattype $cdpath]
      ::robobs::log "WCS calibration : $catastar stars matched."
      saveima $fname
      lappend robobs(image,afilenames) "$fname"
   }

}

if {$robobs(planif,mode)=="meridian"} {
   
   foreach fname $robobs(image,filenames) {
      # --- WCS calibration
      set cdpath $robobs(conf,astrometry,cat_folder,value)
      set cattype $robobs(conf,astrometry,cat_name,value)
      set catastar [calibwcs * * * * * $cattype $cdpath]
      ::robobs::log "WCS calibration : $catastar stars matched."
      saveima $fname
      lappend robobs(image,afilenames) "$fname"
   }

}

if {$robobs(planif,mode)=="geostat1"} {
   
   set fname $robobs(image,dfilenames)
   # --- cosmetique
   #uncosmic 0
   #convgauss 1
   subsky 50 0.4   
   
   # --- Orientation du nord et de l'est
    buf$bufNo imaseries "INVERT xy"
   buf$bufNo imaseries "INVERT flip"
   saveima i
   
   # --- Filtrage special pour la calibration des images trainees
   set res [buf$bufNo stat]
   set sigma_ciel [lindex $res 7]
   set signal_ciel [lindex $res 6]
   set binmax [expr $signal_ciel+10*$sigma_ciel]
   buf$bufNo clipmax $binmax
   set binmin [expr $binmax-1]
   buf$bufNo clipmin $binmin
   gren_info " Filtrage special pour la calibration des images trainees : clipmax=$binmax et clipmin=$binmin\n"
   buf$bufNo imaseries "CONV sigma=7 kernel_type=gaussian"
   buf$bufNo bitpix float
   buf$bufNo imaseries "FILTER kernel_type=gradleft kernel_width=7"
   buf$bufNo clipmin 0.2
   buf$bufNo mult 10
   buf$bufNo bitpix float         
   saveima j
   
   set cdpath $robobs(conf,astrometry,cat_folder,value)
   set cattype $robobs(conf,astrometry,cat_name,value)
   set catastar [calibwcs * * * * * $cattype $cdpath]
   ::robobs::log "WCS calibration : $catastar stars matched."
   
   set tmpkeyws [buf$bufNo getkwds]
   set tmpkeys ""
   foreach keyw $tmpkeyws {
      lappend tmpkeys [buf$bufNo getkwd $keyw]
   }
   
   # --- Recopie les mots clé WCS dans l'image trainée
   loadima prt1
   foreach key $tmpkeys {
      buf$bufNo setkwd $key
   }
   set list_keys [buf$bufNo getkwds]
   
   saveima $fname   
   lappend robobs(image,afilenames) "$fname"

}

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,dfilenames)!="")} {
   
   # --- WCS calibration
   set fname $robobs(image,ffilenames)
   set cdpath $robobs(conf,astrometry,cat_folder,value)
   set cattype $robobs(conf,astrometry,cat_name,value)
   set catastar [calibwcs * * * * * $cattype $cdpath]
   ::robobs::log "WCS calibration : $catastar stars matched."
   saveima $fname
   lappend robobs(image,afilenames) "$fname"

}

if {(($robobs(planif,mode)=="asteroid_light_curve")||($robobs(planif,mode)=="star_light_curve")||($robobs(planif,mode)=="vachier_berthier"))&&($robobs(image,ffilenames)!="")} {
   
   ::robobs::log "WCS calibration : robobs(image,ffilenames)=$robobs(image,ffilenames)"
   foreach fname $robobs(image,ffilenames) {
      ::robobs::log "WCS calibration : fname=$fname"
      buf$bufNo load $fname
      # --- WCS calibration
      set pi [expr 4.*atan(1)]
      set naxis1 [buf$bufNo getpixelswidth]
      set naxis2 [buf$bufNo getpixelsheight]
      set cdpath $robobs(conf,astrometry,cat_folder,value)
      set cattype $robobs(conf,astrometry,cat_name,value)
      set ra00 [buf$bufNo getkwd RA]
      set ra0 [lindex $ra00 1]
      set dec00 [buf$bufNo getkwd DEC]
      set dec0 [lindex $dec00 1]
      set pixsize1_mu [lindex [buf$bufNo getkwd PIXSIZE1] 1]
      set pixsize2_mu [lindex [buf$bufNo getkwd PIXSIZE2] 1]
      set foclen_m [lindex [buf$bufNo getkwd FOCLEN] 1]
      set fov1_deg [expr 1.*$pixsize1_mu*1e-6*$naxis1/$foclen_m*180/$pi]
      set fov2_deg [expr 1.*$pixsize2_mu*1e-6*$naxis2/$foclen_m*180/$pi]
      set cosd [expr cos($dec0*$pi/180)]
      set radecs ""
      set ra [expr $ra0]                 ; set dec [expr $dec0]                 ; lappend radecs [list $ra $dec]
      if {1==0} {
         set ra [expr $ra0+$fov1_deg/$cosd] ; set dec [expr $dec0]                 ; lappend radecs [list $ra $dec]
         set ra [expr $ra0-$fov1_deg/$cosd] ; set dec [expr $dec0]                 ; lappend radecs [list $ra $dec]
         set ra [expr $ra0]                 ; set dec [expr $dec0+$fov2_deg/$cosd] ; lappend radecs [list $ra $dec]
         set ra [expr $ra0]                 ; set dec [expr $dec0-$fov2_deg/$cosd] ; lappend radecs [list $ra $dec]
         set ra [expr $ra0+$fov1_deg/$cosd] ; set dec [expr $dec0+$fov2_deg/$cosd] ; lappend radecs [list $ra $dec]
         set ra [expr $ra0+$fov1_deg/$cosd] ; set dec [expr $dec0-$fov2_deg/$cosd] ; lappend radecs [list $ra $dec]
         set ra [expr $ra0-$fov1_deg/$cosd] ; set dec [expr $dec0+$fov2_deg/$cosd] ; lappend radecs [list $ra $dec]
         set ra [expr $ra0-$fov1_deg/$cosd] ; set dec [expr $dec0-$fov2_deg/$cosd] ; lappend radecs [list $ra $dec]
      }
      # --- Loop over the expected center and 8 adjascent image centers
      set kradec 0
      foreach radec $radecs {
         incr kradec
         buf$bufNo load $fname
         lassign $radec ra dec
         set ra0 $ra ; set dec0 $dec ; # expected radec of the image center
         ::robobs::log "WCS calibration : -------- ra=$ra dec=$dec"
         set err [catch {calibwcs $ra $dec $pixsize1_mu $pixsize2_mu $foclen_m $cattype $cdpath - maglimit 16 -foclendif 5.0} catastar]
         set wcs_calibration_problem 1
         if {$err==0} {
            set nbstars [lindex [buf$bufNo getkwd NBSTARS] 1]
            set texte "WCS calibration : $catastar stars matched ($nbstars detected)."
            if {$catastar>=6} {
               saveima dum1
               set wcs_calibration_problem 0
               # --- compute the offset of pointing and the optical parameter to validate the WCS calibration
               set naxis1 [buf$bufNo getpixelswidth]
               set naxis2 [buf$bufNo getpixelsheight]
               set x [expr $naxis1/2.]
               set y [expr $naxis2/2.]
               set radec [buf$bufNo xy2radec [list $x $y]]
               lassign $radec ra dec ; # radec measured at the center of the calibrated WCS image
               set dra [expr ($ra-$ra0)*60]
               set ddec [expr ($dec-$dec0)*60]
               ::robobs::log "WCS calibration : Offsets dRA = [format %.2f $dra] arcmin dDec = [format %.2f $ddec] arcmin"  
               # ---   compute the focal length and the field of view      
               set foclen1_m [lindex [buf$bufNo getkwd FOCLEN] 1]
               set focalendif_percent [expr 100.*abs($foclen1_m-$foclen_m)/$foclen_m]
               set cdelt1 [lindex [buf$bufNo getkwd CDELT1] 1]
               set cdelt2 [lindex [buf$bufNo getkwd CDELT2] 1]
               set fov1 [expr $naxis1*abs($cdelt1)*60]
               set fov2 [expr $naxis2*abs($cdelt2)*60]
               ::robobs::log "WCS calibration : Field of view = [format %.1f $fov1] x [format %.1f $fov2] arcmin"
               ::robobs::log "WCS calibration : Focal = [format %.3f $foclen1_m] m ([format %.3f $focalendif_percent] percent)"
               # ---   compute the (x,y) position of the target with the WCS parameters
               set xy0 [buf$bufNo radec2xy [list $ra0 $dec0]]
               lassign $xy0 x0 y0
               ::robobs::log "WCS calibration : Target is at pixel x= [format %.1f $x0] y = [format %.1f $y0]"
               # ---   compute the (x,y) position of the target with the WCS parameters relative to the image center
               set dabsx [expr abs($naxis1/2-$x0)]
               set dabsy [expr abs($naxis2/2-$y0)]
               ::robobs::log "WCS calibration : dabsx=[format %.1f $dabsx] dabsy=[format %.1f $dabsy]" 3
               # --- test if the measured coordinate center is not too far from the expected image center coordinates
               if {([expr 1.*$dabsx/$naxis1]>0.9)||([expr 1.*$dabsy/$naxis2]>0.9)} {
                  set wcs_calibration_problem 2
               }
               # --- test if the matched stars is a significant fraction of the total number of stars detected
               if {[expr 1.*$catastar/(1.+$nbstars)]<0.2} {
                  set wcs_calibration_problem 3
               }
               # --- test if the focal length is close to the expected one (5%)
               if {$focalendif_percent>5.} {
                  set wcs_calibration_problem 4
               }
            }
         }
         # --- final validation of the WCS calibration
         if {$wcs_calibration_problem==0} {
            set tospeak "Calibration OK."
            catch {exec espeak.exe -v fr "$tospeak"}
            ::robobs::log $texte 0 #00AA00
            if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
               ::robobs::log "WCS calibration : tel1 radec init [list $ra $dec]" 3
               tel1 radec init [list $ra $dec]
            }
            break
         } else {
            if {$kradec==1} {
               set tospeak "Problème calibration."
               catch {exec espeak.exe -v fr "$tospeak"}
            }
            ::robobs::log "WCS calibration : wcs_calibration_problem=$wcs_calibration_problem"            
            if {$err==1} {
               ::robobs::log "WCS calibration : Error = $catastar"
               set texte "WCS calibration : Error = $catastar"
            } else {
               if {$wcs_calibration_problem==2} {
                  ::robobs::log "WCS calibration : Error = The measured coordinate center is too far from the expected image center coordinates"
               } elseif {$wcs_calibration_problem==3} {
                  ::robobs::log "WCS calibration : Error = The matched stars is not a significant fraction of the total number of stars detected"
               } elseif {$wcs_calibration_problem==4} {
                  ::robobs::log "WCS calibration : Error = The focal length is too far to the expected one (5%)"
               }
            }
            ::robobs::log $texte 0 #FF0000
            set sortie 1
            if {[info exists nbstars]==1} {
               if {$nbstars!=""} {
                  if {$nbstars>5} {
                     set sortie 0
                  }
               }
            }
            if {$sortie==1} {
               ::robobs::log "WCS calibration : Too few stars detected in the image. Exit the calibration loop."
               break
            }
         }
      }
      if {$wcs_calibration_problem>0} {
         ::robobs::log "WCS calibration problem : error = $wcs_calibration_problem" 0 #FF0000
      }
      buf$bufNo setkwd $ra00
      buf$bufNo setkwd $dec00
      buf$bufNo save $fname      
      lappend robobs(image,afilenames) "$fname"
   }

}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
