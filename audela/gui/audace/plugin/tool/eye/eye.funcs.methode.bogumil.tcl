   #------------------------------------------------------------
   ## Retourne le nombre d'etoile du catalogue choisi dont les
   # etoiles appartiennent a l'image
   # @return matchedStarNb Nombre entier d'etoiles
   #
   proc ::eye::get_matchedStarNb {  } {
      if {![file exists "com.lst"]} {
         return 0
      }
      set fcom [open "com.lst" r]
      set matchedStarNb 0
      while {-1 != [gets $fcom line1]} {
         incr matchedStarNb
      }
      close $fcom
      return $matchedStarNb
   }

   #------------------------------------------------------------
   ## Retourne le nombre d'etoile du catalogue choisi dont les
   # etoiles peuvent appartenir a l'image
   # @return catalogueStarNb Nombre entier d'etoiles
   #
   proc ::eye::get_catalogueStarNb {  } {
      if {![file exists "usno.lst"]} {
         return 0
      }
      set fcom [open "usno.lst" r]
      set catalogueStarNb 0
      while {-1 != [gets $fcom line1]} {
         incr catalogueStarNb
      }
      close $fcom
      return $catalogueStarNb
   }

   #------------------------------------------------------------
   ## Methode de calibration astrometrique basee sur BOGUMIL
   # Version avec recherche de la rotation
   # @return void
   #
   proc ::eye::bogumil_rot { } {

      set err 1
      set teta 0

      set crval1    $::eye::widget(keys,new,crval1)
      set crval2    $::eye::widget(keys,new,crval2)
      set pixsize1  $::eye::widget(keys,new,pixsize1)
      set pixsize2  $::eye::widget(keys,new,pixsize2)
      set crpix1    $::eye::widget(keys,new,crpix1)
      set crpix2    $::eye::widget(keys,new,crpix2)
      set crval1    $::eye::widget(keys,new,crval1)
      set crval2    $::eye::widget(keys,new,crval2)
      set foclen    $::eye::widget(keys,new,foclen)
      set cdelt1    $::eye::widget(keys,new,cdelt1)
      set cdelt2    $::eye::widget(keys,new,cdelt2)

      while {$teta < 360 && $err!=0} {

         buf$::eye::bufNo setkwd [list "RA"       $crval1   float {[deg] coord center frame} "pixel" ]
         buf$::eye::bufNo setkwd [list "DEC"      $crval2   float {[deg] coord center frame} "pixel" ]
         buf$::eye::bufNo setkwd [list "PIXSIZE1" $pixsize1 float {[um] Pixel size along naxis1} "um" ]
         buf$::eye::bufNo setkwd [list "PIXSIZE2" $pixsize2 float {[um] Pixel size along naxis2} "um" ]
         buf$::eye::bufNo setkwd [list "CRPIX1"   $crpix1   float {[pixel] reference pixel for naxis1} "pixel" ]
         buf$::eye::bufNo setkwd [list "CRPIX2"   $crpix2   float {[pixel] reference pixel for naxis2} "pixel" ]
         buf$::eye::bufNo setkwd [list "CRVAL1"   $crval1   float {[deg] coord center frame} "deg" ]
         buf$::eye::bufNo setkwd [list "CRVAL2"   $crval2   float {[deg] coord center frame} "deg" ]
         buf$::eye::bufNo setkwd [list "FOCLEN"   $foclen   double "Focal length" "m"]
         buf$::eye::bufNo setkwd [list "CROTA2"   $teta     double "position angle" "deg"]
         buf$::eye::bufNo setkwd [list "CDELT1"   $cdelt1   double "[X scale] deg/pixel" "X scale" ]
         buf$::eye::bufNo setkwd [list "CDELT2"   $cdelt2   double "[Y scale] deg/pixel" "Y scale" ]

        # Appel  a la fonction de calibration Bogumil
        set err [ bogumil ]

         set teta [expr $teta + 10.]
         ::eye::maj_widget_motscles
      }

   }



   #------------------------------------------------------------
   ## Methode de calibration astrometrique basee sur BOGUMIL
   # @return void
   #
   proc ::eye::bogumil_1 { } {

      global conf
      global audace

      set imageStarNb     0
      set catalogueStarNb 0
      set matchedStarNb   0

      set ext [buf$::eye::bufNo extension]
      set tempPath [pwd]
      set fileName "dummy"
      set resultFile "${tempPath}/i$fileName${::eye::extension}"
      file delete -force "${tempPath}/$fileName${::eye::extension}"
      file delete -force "${tempPath}/i$fileName${::eye::extension}"
      file delete -force "${tempPath}/c$fileName${::eye::extension}"

      set searchBox [list 1 1 [buf$::eye::bufNo getpixelswidth] [buf$::eye::bufNo getpixelsheight]]
      set searchBorder [expr $::eye::widget(methode,bogumil,radius) + 2]
      gren_info "searchBorder = $searchBorder\n"
      buf$::eye::bufNo setkwd [list "OBJEFILE" "$resultFile" string "" "" ]
      buf$::eye::bufNo setkwd [list "OBJEKEY" "test" string "" "" ]
      buf$::eye::bufNo setkwd [list "TTNAME" "OBJELIST" string "Table name" "" ]

      gren_info "threshin     = $::eye::widget(methode,bogumil,threshin)  \n"
      gren_info "fwhm         = $::eye::widget(methode,bogumil,fwhm)      \n"
      gren_info "radius       = $::eye::widget(methode,bogumil,radius)    \n"
      gren_info "threshold    = $::eye::widget(methode,bogumil,threshold) \n"
      gren_info "searchBox    = $searchBox \n"
      gren_info "searchBorder = $searchBorder\n"
      gren_info "buf$::eye::bufNo A_starlist $::eye::widget(methode,bogumil,threshin)  \
                                 $resultFile n $::eye::widget(methode,bogumil,fwhm)   \
                                 $::eye::widget(methode,bogumil,radius) $searchBorder \
                                 $::eye::widget(methode,bogumil,threshold) \n"

      set imageStarNb [buf$::eye::bufNo A_starlist $::eye::widget(methode,bogumil,threshin)  \
                                $resultFile n $::eye::widget(methode,bogumil,fwhm)   \
                                $::eye::widget(methode,bogumil,radius) $searchBorder \
                                $::eye::widget(methode,bogumil,threshold) ]
      gren_info "CROTA2 1: [lindex [buf$::eye::bufNo getkwd CROTA2] 1] \n"
      gren_info "imageStarNb = $imageStarNb \n"
      buf$::eye::bufNo save "${tempPath}/${fileName}${::eye::extension}"

      ttscript2 "IMA/SERIES \"$tempPath\" \"$fileName\" . . \"${::eye::extension}\" \"$tempPath\" \"$fileName\" . \"${::eye::extension}\" CATCHART \"path_astromcatalog=$audace(rep_userCatalogUsnoa2)\" astromcatalog=USNO \"catafile=${tempPath}/c$fileName${::eye::extension}\" \"magrlim=$::eye::widget(methode,magnitude)\" \"magblim=$::eye::widget(methode,magnitude)\""
      gren_info "CROTA2 2: [lindex [buf$::eye::bufNo getkwd CROTA2] 1] \n"

      set catalogueStarNb [::eye::get_catalogueStarNb]
      gren_info "catalogueStarNb = $catalogueStarNb \n"

      if { $imageStarNb != 0 && $catalogueStarNb !=  0 } {

         createFileConfigSextractor
         gren_info "sextractor [ file join $tempPath $fileName${::eye::extension} ] -c [ file join $tempPath config.sex ] \n"
         sextractor [ file join $tempPath $fileName${::eye::extension} ] -c [ file join $tempPath config.sex ]
         ttscript2 "IMA/SERIES \"$tempPath\" \"$fileName\" . . \"${::eye::extension}\" \"$tempPath\" \"$fileName\" . \"${::eye::extension}\" ASTROMETRY objefile=catalog.cat nullpixel=-10000 delta=$::eye::widget(methode,delta) epsilon=$::eye::widget(methode,epsilon) file_ascii=ascii.txt"
         gren_info "CROTA2 3: [lindex [buf$::eye::bufNo getkwd CROTA2] 1] \n"
         set matchedStarNb [::eye::get_matchedStarNb]
         gren_info "matchedStarNb = $matchedStarNb \n"
         if { $matchedStarNb > 2 } {
            buf$::eye::bufNo save "${tempPath}/${fileName}${::eye::extension}"
            loadima "${tempPath}/${fileName}${::eye::extension}"
            gren_info "CROTA2 4: [lindex [buf$::eye::bufNo getkwd CROTA2] 1] \n"
            return 0
         }
      }

      return 1

   }

