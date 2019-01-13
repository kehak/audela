## @file      eye.funcs.fov.tcl
#  @brief     Outil de simulation d'image representant le champs de vue
#             du chercheur electronique
#  @author    Frederic Vachier
#  @date      2013
#  @copyright GNU Public License.
#  @warning   Outil en developpement
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool eye.funcs.fov.tcl]
#  @endcode
#  @version   1.3
#  $Id: eye.funcs.fov.tcl 14055 2016-10-01 00:20:40Z fredvachier $

##
# @defgroup eye_fov_fr Simulation d'image
# @ingroup  eye_notice_fr
#
# @warning Outil en developpement
#
# Outils de simulation d'image représentant le champs de vue du chercheur électronique
# @image html eye.fov.png
# Permet de choisir la position du réticule dans l'image du chercheur électronique
# pour fixer la zone observée par la caméra au foyer primaire.
# Un outil de simulation d'image pour répresenter au mieux ce qui est vu
# dans le chercheur électronique, en ajoutant des étoiles et en effectuant une rotation dans l'image.
# Un outil de mesure du centre mécanique de la monture, et de son alignement avec le pôle céleste.
#






   #------------------------------------------------------------
   ## Calcule et affiche le FOV du chercheur
   # @return void
   #
   proc ::eye::fov_view {  }  {

      if {[info exists ::eye::fov(crval1)]} {unset ::eye::fov(crval1)}
      if {[info exists ::eye::fov(crval2)]} {unset ::eye::fov(crval2)}

      # copie du buffer vers le buffer d evenement
      ::eye::evt_uneimg

      gren_info "methode : $::eye::widget(fov,methode)\n"
      if {$::eye::widget(fov,methode) == ""} {
         gren_erreur "Choisir une Methode de simulation"
         return
      }

      if {[info exists ::eye::fov_visuNo]} {
         if {$::eye::fov_visuNo in [visu::list]} {
            gren_info "visu exist\n"
         } else {
            gren_info "visu not exist\n"
            unset ::eye::fov_visuNo
         }
      }
      
      if {![info exists ::eye::fov_visuNo]} {
         set ::eye::fov_visuNo [::confVisu::create]
         set ::eye::fov_canvas [::confVisu::getCanvas $::eye::fov_visuNo]
         set ::eye::fov_bufNo  [::confVisu::getBufNo  $::eye::fov_visuNo]

         set in [frame .visu${::eye::fov_visuNo}.tool.fov]
         set ::eye::fov_view_frame_button $in
         grid $in
         button $in.but_clear  -borderwidth 1 -text "C" -command "::eye::fov_tools_clear"
         button $in.but_1      -borderwidth 1 -text "1" -command "::eye::fov_tools 1"
         button $in.but_2      -borderwidth 1 -text "2" -command "::eye::fov_tools 2"
         button $in.but_3      -borderwidth 1 -text "3" -command "::eye::fov_tools 3"
         button $in.but_p      -borderwidth 1 -text "+" -command "::eye::fov_tools_onemore"
         button $in.but_wcs    -borderwidth 1 -text "W" -command "::eye::fov_wcs ; ::eye::fov_wcs_review"
         button $in.but_cata   -borderwidth 1 -text "A" -command "::eye::fov_cata"
         button $in.but_tab    -borderwidth 1 -text "T" -command "::eye::table_ref_stars"
         button $in.but_res    -borderwidth 1 -text "R" -command "::eye::ressource"
         button $in.but_centi  -borderwidth 1 -text "I" -command "::eye::select_center_image"
         button $in.but_centc  -borderwidth 1 -text "C" -command "::eye::select_pole_celeste"
         grid $in.but_clear
         grid $in.but_1
         grid $in.but_2
         grid $in.but_3
         grid $in.but_p
         grid $in.but_wcs
         grid $in.but_cata
         grid $in.but_tab
         grid $in.but_res
         grid $in.but_centi
         grid $in.but_centc

         DynamicHelp::add $in.but_clear -text "RAZ du matching"
         DynamicHelp::add $in.but_1     -text "Selection de l etoile 1"
         DynamicHelp::add $in.but_2     -text "Selection de l etoile 2"
         DynamicHelp::add $in.but_3     -text "Selection de l etoile 3"
         DynamicHelp::add $in.but_p     -text "Selection d une etoile supplementaire"
         DynamicHelp::add $in.but_wcs   -text "Calcul du WCS"
         DynamicHelp::add $in.but_cata  -text "ASTROID: ajoute des etoiles du catalogue Tycho"
         DynamicHelp::add $in.but_tab   -text "Affiche la table des etoiles de reference"
         DynamicHelp::add $in.but_res   -text "Ressource les scripts pour le developpeur"
         DynamicHelp::add $in.but_centi -text "Affiche le centre de l image du chercheur"
         DynamicHelp::add $in.but_centc -text "Affiche le pole celeste"

      }

      if {$::eye::widget(fov,methode)=="simulimage"} {
         ::eye::fov_simulimage
      }

      ::eye::fov_tools_clear
      return
   }






   proc ::eye::fov_close {  }  {
      catch {::confVisu::close $::eye::fov_visuNo}
      catch {unset ::eye::fov_canvas}
      catch {unset ::eye::fov_visuNo}
      catch {unset ::eye::fov_bufNo}
      return
   }

   proc ::eye::affiche_center_image { } {
      if {[$::eye::fov_view_frame_button.but_centi cget -relief ] == "sunken" && 
          [info exists ::eye::fov(crval1)] && [info exists ::eye::fov(crval2)] } {
         ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(crval1) $::eye::fov(crval2) blue I
         ::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(crval1) $::eye::fov(crval2) blue I
      }
   }

   proc ::eye::select_center_image { } {
      if {[$::eye::fov_view_frame_button.but_centi cget -relief ] == "sunken"} {
         set ::eye::widget(marque,centerimg) 0
         catch {$::eye::fov_canvas delete cible_I }
         catch {$::eye::hCanvas delete cible_I }
         $::eye::fov_view_frame_button.but_centi configure -relief "raised"
      } else {
         set ::eye::widget(marque,centerimg) 1
         $::eye::fov_view_frame_button.but_centi configure -relief "sunken"
         ::eye::affiche_center_image
      }
      return
   }

   proc ::eye::affiche_pole_celeste { } {
      set ::eye::fov(j2000,ra) 0
      set ::eye::fov(j2000,dec) 90
      set radec [list $::eye::fov(j2000,ra) $::eye::fov(j2000,dec) ]
      # calcul coordonnees celestes
      set now [mc_date2jd now]
      set radec [mc_aberrationradec annual $radec $now]
      set radec [mc_precessradec $radec "J2000" $now ]
      set radec [mc_nutationradec $radec $now]
      set ::eye::fov(celeste,ra)  [lindex $radec 0]
      set ::eye::fov(celeste,dec) [lindex $radec 1]
      set ::eye::fov(celeste,color) "#b1f098"
      ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(celeste,ra) $::eye::fov(celeste,dec) $::eye::fov(celeste,color) C
      ::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(celeste,ra) $::eye::fov(celeste,dec) $::eye::fov(celeste,color) C
   }

   proc ::eye::select_pole_celeste { } {
      if {[$::eye::fov_view_frame_button.but_centc cget -relief ] == "sunken"} {
         set ::eye::widget(marque,celeste) 0
         catch {$::eye::fov_canvas delete cible_C }
         catch {$::eye::hCanvas delete cible_C }
         $::eye::fov_view_frame_button.but_centc configure -relief "raised"
      } else {
         set ::eye::widget(marque,celeste) 1
         $::eye::fov_view_frame_button.but_centc configure -relief "sunken"
         ::eye::affiche_pole_celeste
      }
      return
   }



   proc ::eye::fov_simulimage { } {

      global audace

      gren_info "Visu principal : $::eye::visuNo buf = $::eye::bufNo\n"

      gren_info "nbstars = $::eye::widget(fov,nbstars)\n"
      gren_info "orient  = $::eye::widget(fov,orient)\n"
      gren_info "xflip   = $::eye::widget(fov,xflip)\n"
      gren_info "yflip   = $::eye::widget(fov,yflip)\n"

      if {[info exists ::eye::fov_bufNo] } {
         gren_info "::eye::fov_bufNo = $::eye::fov_bufNo\n"
      } else {
         gren_info "::eye::fov_bufNo = not exist\n"
      }

      # --- 752 x 576 => 8.6 x 8.4 µm F = 25e-3
      if {[info exists ::eye::fov(crval1)] && [info exists ::eye::fov(crval2)]} {

         set ra  $::eye::fov(crval1)
         set dec $::eye::fov(crval2)
         gren_info "from ::eye::fov(crval)\n"
         
      } else {
         set ra  $::eye::widget(coord,wanted,raJ2000)
         set dec $::eye::widget(coord,wanted,decJ2000)
         set ra  [mc_angle2deg $ra ]
         set dec [mc_angle2deg $dec]
         gren_info "from wanted\n"
      }
      set ra  [format "%0.5f" $ra]
      set dec [format "%0.5f" $dec]

      gren_info "Center = $ra $dec\n"

      set simunaxis1 720
      set simunaxis2 576
      set pixsize1 8.6
      set pixsize2 8.3
      set foclen 25e-3
      # --- utiliser uniquement le cataloguie TYCHO2 au format USNO
      set path_usno $::eye::widget(simu,catalog)
      # --- parametres de simulation
      set exposure_s [expr $::eye::widget(fov,nbstars)/100.]
      set fwhm_pix 3.2
      set teldiam_m [expr $foclen/1.4]
      set colfilter C
      set sky_brightness_mag [expr 14 + log($::eye::widget(fov,nbstars))]
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
      buf$::eye::fov_bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      set dateobs [get_date_sys2ut]
      set commande "buf$::eye::fov_bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      set err1 [catch {eval $commande} msg]
      set commande "buf$::eye::fov_bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      set err1 [catch {eval $commande} msg]

      simulimage $ra $dec $pixsize1 $pixsize2 $foclen USNO $path_usno $exposure_s $fwhm_pix $teldiam_m $colfilter $sky_brightness_mag $quantum_efficiency $gain_e $readout_noise_e $shutter_mode $bias_level_ADU $thermic_response_e $Tatm $Topt $EMCCD_mult 0 none 0 0 0 $::eye::widget(fov,orient) $simunaxis1 $simunaxis2 $::eye::fov_bufNo
      set crpix1 [buf$::eye::fov_bufNo getkwd CRPIX1]
      gren_info "crpix1 : $crpix1\n"
      
      
      
      
      # Affiche etoiles brillantes
      $::eye::fov_canvas delete brightstars
      set filestars [file join $audace(rep_catalogues) catagoto etoiles_brillantes.txt]
      gren_info "Catalogue etoiles brillantes : $filestars\n"
      set star_list ""
      set chan [open $filestars "r"]
      while {[gets $chan line] >= 0} {
         set cpt 0
         foreach x [split $line " "] {

            if {$x != ""} {
               if {$cpt == 0} {set name  $x}
               if {$cpt == 1} {set name2 $x}
               if {$cpt == 2} {set name3 $x}
               if {$cpt == 3} {set ra_h  $x}
               if {$cpt == 4} {set ra_m  $x}
               if {$cpt == 5} {set ra_s  $x}
               if {$cpt == 6} {set dec_h $x}
               if {$cpt == 7} {set dec_m $x}
               if {$cpt == 8} {set dec_s $x}
               if {$cpt == 9} {set mag   $x}
               incr cpt
            }
         }
         set name2 "${name2}_${name3}"
         set ra [format "%0.5f" [mc_angle2deg "${ra_h}h${ra_m}m${ra_s}s"]]
         set dec [format "%0.5f" [mc_angle2deg "${dec_h}d${dec_m}m${dec_s}s"]]
         set xy [buf$::eye::fov_bufNo radec2xy [list $ra $dec]]
         set x [lindex $xy 0]
         set y [lindex $xy 1]
         if {$name2 == "Alpha_Umi" } {
            gren_info "Star : $name2 $x $simunaxis1 $y $simunaxis2\n"
            gren_info "buf$::eye::fov_bufNo radec2xy { $ra $dec }\n"
            gren_info "x y : $x $y\n"
            gren_info "simuaxis : $simunaxis1 $simunaxis2\n"
            gren_info "ra dec : $ra $dec\n"
            
         }
         if {$x>0 && $x<$simunaxis1 && $y > 0 && $y < $simunaxis2} {
            gren_info "BrightStar in FOV : $name2 $x $y\n"

            if { 1 == 1 } {

               buf$::eye::fov_bufNo synthegauss [list $x $y 200 7 7]

            } else {

               set val 10000
               set err [ catch {
                  set xx      [expr round($x)]
                  set yy      [expr round($y)]

                  #buf1 setpix [list $xx $yy] $val
                  set radius 3
                  set xi [expr $xx - $radius]
                  set yi [expr $yy - $radius]
                  set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
                  set cxi [lindex $can_xy 0]
                  set cyi [lindex $can_xy 1]

                  set xs [expr $xx + $radius]
                  set ys [expr $yy + $radius]
                  set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
                  set cxs [lindex $can_xy 0]
                  set cys [lindex $can_xy 1]


                  $::eye::fov_canvas create oval $cxi $cyi $cxs $cys -outline white -tag brightstars -width 10
                  $::eye::fov_canvas create text [ expr $cxi + 20. ] [ expr $cyi - 20. ] -text $name -fill white -tag brightstars

                  console::affiche_resultat "RADEC = ($ra $dec) MAG=($mag) XY=($xx $yy) $val\n"
               } msg ]
               gren_info "err = $err , msg = $msg"
            }
         }
      }
      close $chan


      if {$::eye::widget(fov,xflip)} {buf$::eye::fov_bufNo mirrorx}
      if {$::eye::widget(fov,yflip)} {buf$::eye::fov_bufNo mirrory}

      ::confVisu::autovisu $::eye::fov_visuNo


      # Affiche points d interets

      return
   }



   #------------------------------------------------------------
   ## Efface la memoire concernant le fov
   # @return void
   #
   proc ::eye::fov_tools_clear { } {

      bind $::eye::hCanvas     <ButtonPress-1> [list ]
      bind $::eye::fov_canvas  <ButtonPress-1> [list ]

      ::eye::deleteStar

      $::eye::fov_view_frame_button.but_1   configure -bg "#d9d9d9"
      $::eye::fov_view_frame_button.but_2   configure -bg "#d9d9d9"
      $::eye::fov_view_frame_button.but_3   configure -bg "#d9d9d9"
      $::eye::fov_view_frame_button.but_p   configure -bg "#d9d9d9"
      $::eye::fov_view_frame_button.but_wcs configure -bg "#d9d9d9"

      # Caracteristique du champs simul爠     array unset ::eye::fov

      # Table des etoiles de reference
      array unset ::eye::stars
      set ::eye::list_star ""
      set ::eye::list_star_ok ""

      # copie du buffer vers le buffer d evenement
      ::eye::evt_uneimg

      return
   }


   #------------------------------------------------------------
   ## Teste si la mesure de l etoile est correcte
   # @return 0 : Correct  1 : Erreur
   #
   proc ::eye::star_test { naxis1 naxis2 x xi xc xs y yi yc ys} {

      set log 0

      set intensity [expr sqrt(pow($xi,2)+pow($yi,2))]
      set sky [expr sqrt(pow($xs,2)+pow($ys,2))]
      set r [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]


      if {$log==1} {
         gren_info "fitgauss = $xc $yc \n"
         gren_info "intensity=$intensity > $sky\n"
         gren_info "r=$r\n"
      }
      if {$intensity<[expr $sky/1.0]} {
         #gren_erreur "rejected too faint\n"
         return 1
      }
      if {$r > $::eye::widget(fov,rdiff)} {
         #gren_erreur "rejected to far\n"
         return 1
      }
      if {$xc < $::eye::widget(fov,boxradius) || $xc > [expr $naxis1 - $::eye::widget(fov,boxradius)] } {
         #gren_erreur "rejected to near the border X\n"
         return 1
      }
      if {$yc < $::eye::widget(fov,boxradius) || $yc > [expr $naxis2 - $::eye::widget(fov,boxradius)] } {
         #gren_erreur "rejected to near the border Y\n"
         return 1
      }

      return 0
   }


   #------------------------------------------------------------
   ## @brief sélection dans le canvas d'une étoile avec mesure du photocentre
   #  @param  w        : canvas
   #  @param  x        : pos X dans l'image
   #  @param  y        : pos Y dans l'image
   #  @param  visuNo   : numéro de la visu
   #  @param  bufNo    : numéro du buffer
   #  @param  camsimu  : s'applique pour la caméra (cam) ou la simu (simu)
   #  @param  star     : numéro de l'étoile
   #  @return
   #  - 0 : Correct
   #  - 1 : Erreur
   #
   proc ::eye::fov_select { w x y visuNo bufNo camsimu star } {

      set log 0

      if {$camsimu=="cam"} {
         lassign [::eye::photom_methode $visuNo $bufNo $x $y $star] success xc yc pixmax intensite sky err_sky snint

         set ::eye::stars($star,cam,crpix1)    [format "%.1f" $xc]
         set ::eye::stars($star,cam,crpix2)    [format "%.1f" $yc]
         set ::eye::stars($star,cam,pixmax)    [format "%.1f" $pixmax]
         set ::eye::stars($star,cam,intensity) [format "%.1f" $intensite ]
         set ::eye::stars($star,cam,sky)       [format "%.1f" $sky]
         set ::eye::stars($star,cam,err_sky)   [format "%.1f" $err_sky]
         set ::eye::stars($star,cam,snint)     [format "%.1f" $snint]
         set ::eye::stars($star,cam,rdiff)     [format "%.1f" [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]]
         set ::eye::stars($star,cam,success)   $success
         if {$success==1 } {
            incr ::eye::stars($star,cam,nbmes)
            if {$::eye::stars($star,cam,pixmax) < 254} {
               ::eye::fov_tools_point  $::eye::hCanvas $::eye::visuNo $xc $yc green $star
            } else {
               ::eye::fov_tools_point  $::eye::hCanvas $::eye::visuNo $xc $yc orange $star
            }
               
         } else {
            ::eye::fov_tools_point $::eye::hCanvas $::eye::visuNo $xc $yc red $star
         }
      } else {
         set radius $::eye::widget(fov,boxradius)
         set box [list [expr {$x-$radius}] [expr {$y-$radius}] [expr { $x+$radius }] [expr { $y+$radius }]]
         lassign [buf$bufNo fitgauss $box] -> xc -> -> -> yc
         set ::eye::stars($star,simu,crpix1)    [format "%.1f" $xc]
         set ::eye::stars($star,simu,crpix2)    [format "%.1f" $yc]
         set radec [buf$::eye::fov_bufNo xy2radec [list $xc $yc] ]
         set ::eye::stars($star,simu,ra)        $::eye::stars($star,simu,crpix1)
         set ::eye::stars($star,simu,dec)       $::eye::stars($star,simu,crpix2)
         ::eye::fov_tools_point $::eye::fov_canvas $::eye::fov_visuNo $xc $yc yellow $star
      }

      return
   }






   #------------------------------------------------------------
   ## @brief sélection dans le canvas d'une étoile avec mesure du photocentre
   #  @details en mode manuel oneclick
   #  @param  w       : canvas
   #  @param  x       : pos X dans le canvas
   #  @param  y       : pos Y dans le canvas
   #  @param  visuNo  : numéro de la visu
   #  @param  bufNo   : numéro du buffer
   #  @param  camsimu : s'applique pour la caméra (cam) ou la simu (simu)
   #  @param  star    : numéro de l'étoile
   #  @return 0
   #
   proc ::eye::fov_manual_select { w x y visuNo bufNo camsimu star } {

      set log 1

      if {$log==1} {
         gren_info "fov_manual_select \n"
         gren_info "w =$w \n"
         gren_info "x =$x \n"
         gren_info "y =$y \n"
         gren_info "visuNo =$visuNo \n"
         gren_info "bufNo =$bufNo \n"
         gren_info "camsimu =$camsimu \n"
         gren_info "star =$star \n"
      }

      #--   convertit les coordonnees canvas en coordonnees image
      set coord [list $x $y]
      lassign [::confVisu::canvas2Picture $visuNo $coord] x y
      if {$log==1} {
        gren_info "xp =$x \n"
        gren_info "yp =$y \n"
      }

      #--   definit une boite de selection
      #set radius $::eye::widget(fov,boxradius)
      #set box [list [expr {$x-$radius}] [expr {$y-$radius}] [expr { $x+$radius }] [expr { $y+$radius }]]
      #if {$log==1} {
      #   gren_info "box = $box \n"
      #}

      #--   cherche le centre FWHM de l'etoile recouverte
      #--   et remplace x,y par ces nouvelles coordonnees
      #lassign [buf$bufNo fitgauss $box] xi xc -> xs yi yc -> ys
      if {$camsimu=="cam"} {
         lassign [::eye::photom_methode $visuNo $bufNo $x $y $star] success xc yc pixmax intensite sky err_sky snint

         if {$success==1} {
            set ::eye::stars($star,cam,crpix1)    [format "%.1f" $xc]
            set ::eye::stars($star,cam,crpix2)    [format "%.1f" $yc]
            set ::eye::stars($star,cam,pixmax)    [format "%.1f" $pixmax]
            set ::eye::stars($star,cam,intensity) [format "%.1f" $intensite ]
            set ::eye::stars($star,cam,sky)       [format "%.1f" $sky]
            set ::eye::stars($star,cam,err_sky)   [format "%.1f" $err_sky]
            set ::eye::stars($star,cam,snint)     [format "%.1f" $snint]
            set ::eye::stars($star,cam,rdiff)     [format "%.1f" [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]]
            set ::eye::stars($star,cam,nbmes)     $success

            set radec [buf$::eye::fov_bufNo xy2radec [list $::eye::stars($star,simu,crpix1) $::eye::stars($star,simu,crpix2) ] ]

            set ::eye::stars($star,simu,ra)  [lindex $radec 0]
            set ::eye::stars($star,simu,dec) [lindex $radec 1]
            set ::eye::stars($star,simu,mag) [::eye::get_mag_star $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec)]
            #gren_info "::eye::get_mag_star $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec)\n"
            #gren_info "MAG = $::eye::stars($star,simu,mag)\n"
         } else {
            set ::eye::stars($star,cam,crpix1)    [format "%.1f" 0]
            set ::eye::stars($star,cam,crpix2)    [format "%.1f" 0]
            set ::eye::stars($star,cam,pixmax)    [format "%.1f" 0]
            set ::eye::stars($star,cam,intensity) [format "%.1f" 0 ]
            set ::eye::stars($star,cam,sky)       [format "%.1f" 0]
            set ::eye::stars($star,cam,err_sky)   [format "%.1f" 0]
            set ::eye::stars($star,cam,snint)     [format "%.1f" 0]
            set ::eye::stars($star,cam,rdiff)     [format "%.1f" 0]
            set ::eye::stars($star,cam,nbmes)     0
         }

         if {$log==1} {
            gren_info "::eye::stars($star,cam,crpix1)    = $::eye::stars($star,cam,crpix1)    \n"
            gren_info "::eye::stars($star,cam,crpix2)    = $::eye::stars($star,cam,crpix2)    \n"
            gren_info "::eye::stars($star,cam,pixmax)    = $::eye::stars($star,cam,pixmax)    \n"
            gren_info "::eye::stars($star,cam,intensity) = $::eye::stars($star,cam,intensity) \n"
            gren_info "::eye::stars($star,cam,sky)       = $::eye::stars($star,cam,sky)       \n"
            gren_info "::eye::stars($star,cam,err_sky)   = $::eye::stars($star,cam,err_sky)   \n"
            gren_info "::eye::stars($star,cam,snint)     = $::eye::stars($star,cam,snint)     \n"
            gren_info "::eye::stars($star,cam,rdiff)     = $::eye::stars($star,cam,rdiff)     \n"
            gren_info "::eye::stars($star,cam,nbmes)     = $::eye::stars($star,cam,nbmes)     \n"
            gren_info "success = $success     \n"
         }

         if {$::eye::stars($star,cam,pixmax) < 254 } {
            ::eye::fov_tools_point $w $visuNo $xc $yc yellow $star
         } else {
            ::eye::fov_tools_point $w $visuNo $xc $yc orange $star
         }

      } else {
         set radius $::eye::widget(fov,boxradius)
         set box [list [expr {$x-$radius}] [expr {$y-$radius}] [expr { $x+$radius }] [expr { $y+$radius }]]
         lassign [buf$bufNo fitgauss $box] xi xc -> xs yi yc -> ys
         set ::eye::stars($star,simu,crpix1)    [format "%.1f" $xc]
         set ::eye::stars($star,simu,crpix2)    [format "%.1f" $yc]
         set ::eye::stars($star,simu,pixmax)    0
         set ::eye::stars($star,simu,intensity) [expr sqrt(pow($xi,2)+pow($yi,2))]
         set ::eye::stars($star,simu,sky)       [expr sqrt(pow($xs,2)+pow($ys,2))]
         set ::eye::stars($star,simu,err_sky)   0
         set ::eye::stars($star,simu,snint)     0
         set ::eye::stars($star,simu,rdiff)     [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]
         set ::eye::stars($star,simu,nbmes)     1
         ::eye::fov_tools_point $w $visuNo $xc $yc yellow $star
      }

      return 0
   }



   proc ::eye::fov_tools_onemore {  } {

      set butcol [$::eye::fov_view_frame_button.but_p cget -bg]
      set butcol1 [$::eye::fov_view_frame_button.but_1 cget -bg]
      set butcol2 [$::eye::fov_view_frame_button.but_2 cget -bg]
      set butcol3 [$::eye::fov_view_frame_button.but_3 cget -bg]

      if { $butcol1 == "red" || $butcol2 == "red" || $butcol3 == "red" } { return }
      set star [expr [llength $::eye::list_star]+1]

      switch $butcol {
         "red" {

            $::eye::fov_view_frame_button.but_p configure -bg green
            gren_info "Select Star $star\n"

            bind $::eye::hCanvas    <ButtonPress-1> [list ]
            bind $::eye::fov_canvas <ButtonPress-1> [list ]

            catch {$::eye::hCanvas    itemconfigure cible_$star -outline "#00d300" }
            catch {$::eye::fov_canvas itemconfigure cible_$star -outline "#00d300" }

            set radec [buf$::eye::fov_bufNo xy2radec [list $::eye::stars($star,simu,crpix1) $::eye::stars($star,simu,crpix2) ] ]
            set ::eye::stars($star,simu,ra)  [lindex $radec 0]
            set ::eye::stars($star,simu,dec) [lindex $radec 1]
            gren_info "RADEC $star =  $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) \n"

            # Nouvelle entree dans la liste d etoile
            if {[lsearch $::eye::list_star $star]==-1} {
               lappend ::eye::list_star $star
            }

            # Nouvelle entree dans la liste des etoiles mesurees
            if {[lsearch $::eye::list_star_ok $star]==-1} {
               lappend ::eye::list_star_ok $star
            }

            # Rafraichissement de la table
            if { [winfo exists .starreflist] } { ::eye::table_ref_stars_load }

            return
         }
         "green" {
            $::eye::fov_view_frame_button.but_p configure -bg red
         }
         default {
            $::eye::fov_view_frame_button.but_p configure -bg red
         }
      }

      bind $::eye::hCanvas    <ButtonPress-1> [list ::eye::fov_manual_select %W %x %y $::eye::visuNo     $::eye::bufNo     "cam"  $star]
      bind $::eye::fov_canvas <ButtonPress-1> [list ::eye::fov_manual_select %W %x %y $::eye::fov_visuNo $::eye::fov_bufNo "simu" $star]
      return 0
   }







   proc ::eye::fov_tools { star } {

      set butcol1 [$::eye::fov_view_frame_button.but_1 cget -bg]
      set butcol2 [$::eye::fov_view_frame_button.but_2 cget -bg]
      set butcol3 [$::eye::fov_view_frame_button.but_3 cget -bg]

      switch $star {
         "1" {
            if { $butcol2 == "red" || $butcol3 == "red" } { return }
            set butcol $butcol1
         }
         "2" {
            if { $butcol1 == "red" || $butcol3 == "red" } { return }
            set butcol $butcol2
         }
         "3" {
            if { $butcol1 == "red" || $butcol2 == "red" } { return }
            set butcol $butcol3
         }
      }

      switch $butcol {
         "red" {

            $::eye::fov_view_frame_button.but_$star configure -bg green
            gren_info "Select Star $star\n"

            bind $::eye::hCanvas    <ButtonPress-1> [list ]
            bind $::eye::fov_canvas <ButtonPress-1> [list ]

            catch {$::eye::hCanvas    itemconfigure cible_$star -outline "#00d300" }
            catch {$::eye::fov_canvas itemconfigure cible_$star -outline "#00d300" }
            #catch {$::eye::hCanvas    itemconfigure cible_$star -fill "#00d300"}
            #catch {$::eye::fov_canvas itemconfigure cible_$star -fill "#00d300"}

            set radec [buf$::eye::fov_bufNo xy2radec [list $::eye::stars($star,simu,crpix1) $::eye::stars($star,simu,crpix2) ] ]
            set ::eye::stars($star,simu,ra)  [lindex $radec 0]
            set ::eye::stars($star,simu,dec) [lindex $radec 1]
            
            gren_info "RADEC $star =  $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) \n"

            if {[lsearch $::eye::list_star $star]==-1} {
               lappend ::eye::list_star $star
            }

            if {[lsearch $::eye::list_star_ok $star]==-1} {
               lappend ::eye::list_star_ok $star
            }

            return
         }
         "green" {
            $::eye::fov_view_frame_button.but_$star configure -bg red
         }
         default {
            $::eye::fov_view_frame_button.but_$star configure -bg red
         }
      }

      gren_info "Selecting Star $star\n"
      bind $::eye::hCanvas    <ButtonPress-1> [list ::eye::fov_manual_select %W %x %y $::eye::visuNo     $::eye::bufNo     "cam"  $star]
      bind $::eye::fov_canvas <ButtonPress-1> [list ::eye::fov_manual_select %W %x %y $::eye::fov_visuNo $::eye::fov_bufNo "simu" $star]
      return
   }






   #------------------------------------------------------------
   ## Calcule un WCS pour le buffer
   # @return void
   #
   proc ::eye::fov_wcs { } {

      $::eye::fov_view_frame_button.but_wcs configure -bg "#d9d9d9"
      if {![info exists ::eye::stars]} {return}

      if {[llength $::eye::list_star_ok]<3} {return}

      #foreach star $::eye::list_star_ok {
      #   if {![info exists ::eye::stars($i,cam,crpix1)  ]} {return}
      #   if {![info exists ::eye::stars($i,cam,crpix2)  ]} {return}
      #   if {![info exists ::eye::stars($i,simu,crpix1) ]} {return}
      #   if {![info exists ::eye::stars($i,simu,crpix2) ]} {return}
      #   if {![info exists ::eye::stars($i,simu,ra)     ]} {return}
      #   if {![info exists ::eye::stars($i,simu,dec)    ]} {return}
      #}
      #gren_info "Ok donnees completes\n"

      set pairs ""
      lappend pairs {xs ys coordc idc xc yc fluxs fluxc ks kc totweight ntotvotes ntotquartet}
      set couples ""
      foreach star $::eye::list_star_ok {
         lappend couples [list $::eye::stars($star,cam,crpix1) $::eye::stars($star,cam,crpix2)  \
                             [list $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) 0 $star J2000 J2000 0 0 0] \
                             $star $::eye::stars($star,simu,crpix1) $::eye::stars($star,simu,crpix2) \
                             10 10 $star $star 1 1 1]
      }
      lappend pairs $couples
      lappend pairs [list {1 0 0} {0 1 0}]

      set polydeg 1
      set xoptc [expr 720/2.] ; # naxis1 /2
      set yoptc [expr 576/2.] ; # naxis2 /2

      set err [catch { set ::eye::wcs [wcs_focaspairs2wcs $pairs $polydeg $xoptc $yoptc]
                       wcs_wcs2buf $::eye::wcs $::eye::evt_bufNo
                      } msg ]

      if {$err} {
         gren_erreur "Calibration impossible (err = $err) (msg = $msg)\n"
         return
      }

      # on reaffiche la cam avec le buffer maj
      #::confVisu::autovisu $::eye::visuNo

      set crval1 ""
      set pos [lsearch -index 0 $::eye::wcs CRVAL1]
      if {$pos >= 0} { set crval1 [lindex $::eye::wcs $pos 1] }
      set crval2 ""
      set pos [lsearch -index 0 $::eye::wcs CRVAL2]
      if {$pos >= 0} { set crval2 [lindex $::eye::wcs $pos 1] }
      if { $crval1 == "" || $crval2 == "" } {
         return
      }
      set crota2 ""
      set pos [lsearch -index 0 $::eye::wcs CROTA2]
      if {$pos >= 0} { set crota2 [lindex $::eye::wcs $pos 1] }
      if { $crota2 != "" } {
         if {$crota2<0} {
            set crota2 [expr $crota2 + 360]
         }
         set ::eye::widget(fov,orient) $crota2
      }


      # calculer le centre de l image cam par xy2radec
      # calculer le centre de la simu par xy2radec
      set ::eye::fov(crval1) $crval1
      set ::eye::fov(crval2) $crval2
      set ::eye::fov(cddelt1) [lindex [buf$::eye::evt_bufNo getkwd "CDELT1"] 1]
      set ::eye::fov(cddelt2) [lindex [buf$::eye::evt_bufNo getkwd "CDELT2"] 1]

      #gren_info "crval1, crval2 du centre du nouveau wcs de l image cam = $crval1 $crval2\n"


      # attention ne marche pas encore...
      #set ::eye::stars(crval1) $crval1
      #set ::eye::stars(crval2) $crval2

      $::eye::fov_view_frame_button.but_wcs configure -bg green

   }


   proc ::eye::fov_wcs_review {  } {

      if {[$::eye::fov_view_frame_button.but_centi cget -relief ] ==  "sunken"} {set okaffimg "yes"} else {set okaffimg "no"}
      

      ::eye::cleanmark_simu
      ::eye::cleanmark_visu
      ::eye::fov_simulimage

      if {[info exists ::eye::fov(crval1)] && [info exists ::eye::fov(crval2)]} {
         
         # affiche le centre de l image
         if {$okaffimg == "yes"} {::eye::select_center_image}

         if {$::eye::widget(telescope,fov,pos) !="" && [llength $::eye::widget(telescope,fov,pos)]==2} {
            #lassign [split $::eye::widget(telescope,fov,pos)] x y
            set radec [buf$::eye::evt_bufNo xy2radec [split $::eye::widget(telescope,fov,pos)] ]
            set ::eye::widget(coord,reticule,raJ2000) [mc_angle2hms [lindex $radec 0] 360 zero 1 auto string ]
            set ::eye::widget(coord,reticule,decJ2000) [mc_angle2dms [lindex $radec 1] 90 zero 0 + string ]
         }
         

      }



      foreach star $::eye::list_star_ok {
      
         if {$::eye::stars($star,cam,pixmax) < 254} {
            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) green $star
            ::eye::fov_tools_point_radec $::eye::hCanvas $::eye::evt_bufNo $::eye::visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) green $star
         } else {
            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) orange $star
            ::eye::fov_tools_point_radec $::eye::hCanvas $::eye::evt_bufNo $::eye::visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) orange $star
         }
      }

   }



   proc ::eye::fov_cata {  } {

      global audace

      if {[$::eye::fov_view_frame_button.but_centi cget -relief ] ==  "sunken"} {set okaffimg "yes"} else {set okaffimg "no"}
      
      # cstycho2_fast /astrodata/Catalog/Stars/TYCHO2_FAST 50.73744687472936477 86.03815323569999407 1147.4419512319009 7.3 0

      # Effacement des traces
      ::eye::deleteStar

      # Effacement des etoiles de reference sauf les 3 premieres
      set l ""
      foreach star $::eye::list_star_ok {
         if {$star <=3} {
            lappend l $star
         }
      }
      set ::eye::list_star_ok $l
      set ::eye::list_star $l

      # Calcul des coordonnees de l image
      # Necessite d avoir cree le WCS auparavant
      set ra      [lindex [ buf$::eye::evt_bufNo getkwd "CRVAL1"] 1]
      set dec     [lindex [ buf$::eye::evt_bufNo getkwd "CRVAL2"] 1]
      set naxis1  [lindex [ buf$::eye::evt_bufNo getkwd "NAXIS1"] 1]
      set naxis2  [lindex [ buf$::eye::evt_bufNo getkwd "NAXIS2"] 1]
      set scale_x [lindex [ buf$::eye::evt_bufNo getkwd "CDELT1"] 1]
      set scale_y [lindex [ buf$::eye::evt_bufNo getkwd "CDELT2"] 1]

      # Cas ou le WCS a merd爠     if {$scale_x==""} {return}

      # Geometrie
      set mscale  [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
      set radius  [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]

      set ::eye::fov(evt,scalex) $scale_x
      set ::eye::fov(evt,scaley) $scale_y

      # Appel au catalogue d etoile TYCHO2
      set limitmag 8
      set cmd cstycho2_fast
      if {[info exists ::tools_cata::catalog_tycho2]} {
         set path $::tools_cata::catalog_tycho2
      } else {
         set path $audace(rep_userCatalogTycho2_fast)
      }
      set commonfields { RAdeg DEdeg 5.0 VT e_VT }
      
      set listsources [$cmd $path $ra $dec $radius $limitmag 0]
      set listsources [::manage_source::set_common_fields $listsources TYCHO2 $commonfields]

      # recup des etoiles de ref
      # creation d une liste ( ra dec magnitude )
      set cf [lindex $listsources 0]
      set sources [lindex $listsources 1]
      set newsources ""
      set cpt [llength $::eye::list_star]
      set zl ""
      foreach s $sources {
         set lcf [lindex $s 0 1]
         set ra  [lindex $lcf 0]
         set dec [lindex $lcf 1]
         set mag [lindex $lcf 3]
         set name [::manage_source::namincata $s]
         lappend zl [list $ra $dec $mag $name]
      }
      set zl [lsort -increasing -real -index 2 $zl]

      # Mesure des etoiles dans le buffer
      foreach z $zl {

         set ra   [lindex $z 0]
         set dec  [lindex $z 1]
         set mag  [lindex $z 2]
         set star [lindex $z 3]

         # si la liste est pleine on sort
         if {[llength $::eye::list_star]>=$::eye::widget(fov,nbref)} {
            break
         }

         # L etoile existe dans la liste ?
         if {[::eye::star_exist $ra $dec]==0} {
            #gren_erreur "star exist\n"
            continue
         }

         lassign [ buf$::eye::evt_bufNo radec2xy [ list $ra $dec ] ] x y

         if { $x < 0 || $x>$naxis1 || $y<0 || $y > $naxis2} { continue }

         set x [expr int($x)]
         set y [expr int($y)]

         lassign [::eye::photom_methode $::eye::visuNo $::eye::evt_bufNo $x $y $star] success xc yc pixmax intensity sky err_sky snint
         set rdiff [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]
         if {$snint < 6} {continue}

         # accepte
         incr cpt

         ::eye::add_star $ra $dec $xc $yc $mag $pixmax $intensity $sky $err_sky $snint $rdiff

         set ::eye::stars($star,simu,ra) $ra
         set ::eye::stars($star,simu,dec) $dec
         #set radius $::eye::widget(fov,boxradius)
         #set box [list [expr {$x-$radius}] [expr {$y-$radius}] [expr { $x+$radius }] [expr { $y+$radius }]]
         #lassign [buf$::eye::evt_bufNo fitgauss $box] xi xc -> xs yi yc -> ys
         #if {[::eye::star_test $naxis1 $naxis2 $x $xi $xc $xs $y $yi $yc $ys]==1} {
         #   continue
         #}



         # On ajoute l etoile a liste
         #set intensity [format "%.1f" [expr sqrt(pow($xi,2)+pow($yi,2))]]
         #set sky       [format "%.1f" [expr sqrt(pow($xs,2)+pow($ys,2))]]
         #set rdiff     [format "%.1f" [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]]
         #::eye::add_star $ra $dec $xc $yc $mag $::eye::stars($star,cam,intensity) $::eye::stars($star,cam,sky) $::eye::stars($star,cam,rdiff)

         #gren_info "star ref = $cpt\n"
         if {$okaffimg == "yes"} {::eye::select_center_image}

         foreach star $::eye::list_star_ok {
         
         if {$::eye::stars($star,cam,pixmax) < 254} {
            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) green $star
            ::eye::fov_tools_point_radec $::eye::hCanvas $::eye::evt_bufNo $::eye::visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) green $star
         } else {
            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) orange $star
            ::eye::fov_tools_point_radec $::eye::hCanvas $::eye::evt_bufNo $::eye::visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) orange $star
         }

            set ::eye::stars($star,cam,nbmes) 0

         }


      }

      #  Genere un nouveau WCS

      #  Refait les mesures

      return
   }












   #------------------------------------------------------------
   # searchStarCenter (proc tiree de fieldchart.tcl)
   #     Retourne les coordonnees picture du centre de l'etoile a
   #     partir des cordonnees canvas par ajustement d'une gaussienne
   #------------------------------------------------------------
   proc ::eye::fov_searchStarCenter { visuNo bufNo coord } {

      #--   convertit les coordonnees canvas en coordonnees image
      lassign [::confVisu::canvas2Picture $visuNo $coord]  x y

      #--   definit une boite de selection
      set radius 10
      set box [list [expr {$x-$radius}] [expr {$y-$radius}] [expr { $x+$radius }] [expr { $y+$radius }]]

      #--   cherche le centre FWHM de l'etoile recouverte
      #--   et remplace x,y par ces nouvelles coordonnees
      lassign [buf$bufNo fitgauss $box] -> xc -> -> -> yc

      return [list $xc $yc]
   }






   #------------------------------------------------------------
   # calibration acvec 3 etoiles
   #
   #
   #------------------------------------------------------------
   proc ::eye::calibNstars {  } {

      set pairs ""
      lappend pairs [list $xs $ys [list $ra $dec J2000] 1 $xc $yc 10 10 1 1 1 1 1]
      lappend pairs [list $xs $ys [list $ra $dec J2000] 2 $xc $yc 10 10 2 2 1 1 1]
      lappend pairs [list $xs $ys [list $ra $dec J2000] 3 $xc $yc 10 10 3 3 1 1 1]
      set polydeg 1
      set xoptc "" ; # naxis1 /2
      set yoptc "" ; # naxis2 /2
      set wcs [wcs_focaspairs2wcs $pairs $polydeg $xoptc $yoptc]
      wcs_wcs2buf $wcs $bufNo

   }






   proc ::eye::fov_reset {  } {

      array unset ::eye::stars_move

      if {[info exists ::eye::list_star]} {
         foreach star $::eye::list_star {
            catch {$::eye::hCanvas delete arc_$star}
            catch {$::eye::hCanvas delete centre_$star}
         }
      }

      if {$::eye::widget(game,demo)==1} {
         ::eye::demo_load_meca
      }

      ::eye::fov_wcs_review

   }





   proc ::eye::get_pole { who } {

      # Init des mesure de psf

      if {[info exists ::eye::list_star]} {
         foreach star $::eye::list_star {
            catch {$::eye::hCanvas delete arc_$star}
            catch {$::eye::hCanvas delete centre_$star}
         }
      }

      if {$::eye::widget(game,demo)==1} {
         ::eye::demo_load_meca
      }

      ::eye::fov_wcs_review

      array unset ::eye::stars_move
      set ::eye::lxc ""
      set ::eye::lyc ""

      # Pole Celeste
      set ::eye::widget(marque,celeste) 1
      $::eye::fov_view_frame_button.but_centc configure -relief "sunken"
      ::eye::affiche_pole_celeste


      switch $who {

         "meca" {      
            if {[::eye::tel_isconnected]==1} {
               tel$::eye::tel speedtrack diurnal 0
               set speeddiurne [lindex [tel$::eye::tel speedtrack] 0]
               tel$::eye::tel speedtrack [expr $speeddiurne * 100] 0
               tel$::eye::tel radec motor off
               tel$::eye::tel radec motor on
               gren_info "Mouvement du telescope\n"
            }
         }
         "celeste" {
            if {[::eye::tel_isconnected]==1} {
               tel$::eye::tel radec motor off
            }
         }

      }

      if {[$::eye::widget(fov,tools).meca cget -relief ] == "sunken"} {
         ::eye::stop_boucle
         return 0
      }

      $::eye::widget(fov,tools).meca configure -relief sunken

      # Gestionnaire d evenement
      set ::eye::widget(event,check,uneimg)      1
      set ::eye::widget(event,check,calibration) 1
      set ::eye::widget(event,check,objet)       1
      set ::eye::widget(event,check,telescope)   0
      set ::eye::widget(event,type,objet)        center_move
      $::eye::widget(event).check_uneimg      configure -state normal
      $::eye::widget(event).check_calibration configure -state normal
      $::eye::widget(event).check_objet       configure -state normal
      $::eye::widget(event).check_telescope   configure -state disabled

      # debut de la boucle d evenement
      ::eye::start_boucle $who

      return
      # fin de la boucle d evenement
      # et debut de l alignement
      
      switch $who {

         "meca" -
         "celeste" {

            gren_info "Specificite $who\n"

            ::eye::cleanmark_visu

            $::eye::widget(fov,tools).meca          configure -relief raised
            $::eye::widget(event).check_uneimg      configure -state normal
            $::eye::widget(event).check_calibration configure -state normal
            $::eye::widget(event).check_objet       configure -state normal
            $::eye::widget(event).check_telescope   configure -state normal

            if {1 ==0} {
               # pole meca
               set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $::eye::fov(meca,x) $::eye::fov(meca,y)]]} msg]

               if {$err} {
                  gren_erreur "$star : origine meca $xc $yc $msg $err\n"
                  continue
               }

               if {$coord==""} {
                  gren_erreur "$star : origine meca 2 : $xc $yc $msg $err\n"
                  continue
               }

               set xc  [lindex $coord 0]
               set yc  [lindex $coord 1]
               set r 2
               $::eye::hCanvas create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                             [expr int($xc+$r)] [expr int($yc+$r)] -outline magenta -tag cible_M -width 1

               # pole celeste
               set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $::eye::fov(celeste,x) $::eye::fov(celeste,y)]]} msg]

               if {$err} {
                  gren_erreur "$star : origine celeste $xc $yc $msg $err\n"
                  continue
               }

               if {$coord==""} {
                  gren_erreur "$star : origine celeste 2 : $xc $yc $msg $err\n"
                  continue
               }

               set xc  [lindex $coord 0]
               set yc  [lindex $coord 1]
               set r 2
               $::eye::hCanvas create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                             [expr int($xc+$r)] [expr int($yc+$r)] -outline red -tag cible_C -width 1

            }

            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(meca,ra) $::eye::fov(meca,dec) magenta M
            #::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(meca,ra) $::eye::fov(meca,dec) magenta M

            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(celeste,ra) $::eye::fov(celeste,dec) $::eye::fov(celeste,color) C
            #::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(celeste,ra) $::eye::fov(celeste,dec) $::eye::fov(celeste,color) C

            catch {$::eye::hCanvas delete origine}
            catch {$::eye::hCanvas delete origine}
 
         }
      }


      switch $who {
         "meca" {


            gren_info "ReSpecificite $who\n"

            set w 1
            set r $::eye::widget(fov,boxradius)

            foreach star $::eye::list_star {

               # Origine

               set ::eye::widget(fov,onestar,xo) $::eye::stars($star,cam,crpix1)
               set ::eye::widget(fov,onestar,yo) $::eye::stars($star,cam,crpix2)

               set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $::eye::stars($star,cam,crpix1) $::eye::stars($star,cam,crpix2)]]} msg]

               if {$err} {
                  gren_erreur "$star : origine picture2Canvas $xc $yc $msg $err\n"
                  continue
               }

               if {$coord==""} {
                  gren_erreur "$star : origine picture2Canvas 2 : $xc $yc $msg $err\n"
                  continue
               }

               set xc  [lindex $coord 0]
               set yc  [lindex $coord 1]

               $::eye::hCanvas create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                             [expr int($xc+$r)] [expr int($yc+$r)] -outline cyan -tag origine -width $w


               # destination

               set xc  [expr $::eye::stars($star,cam,crpix1) - $::eye::fov(meca,x) + $::eye::fov(celeste,x) ]
               set yc  [expr $::eye::stars($star,cam,crpix2) - $::eye::fov(meca,y) + $::eye::fov(celeste,y) ]

               set ::eye::widget(fov,onestar,xw) $xc
               set ::eye::widget(fov,onestar,yw) $yc

               set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list  $xc $yc ] ] } msg]
               if {$err} {
                  gren_erreur "$star : destination picture2Canvas $xc $yc $msg $err\n"
                  continue
               }

               if {$coord==""} {
                  gren_erreur "$star : destination picture2Canvas 2 : $xc $yc $msg $err\n"
                  continue
               }

               set xc  [lindex $coord 0]
               set yc  [lindex $coord 1]

               $::eye::hCanvas create rectangle [expr int($xc-$r)] [expr int($yc-$r)] \
                             [expr int($xc+$r)] [expr int($yc+$r)] -outline cyan -tag origine -width $w


               break
            }

            if {$::eye::widget(game,demo)==1} {
               ::eye::demo_load_meca_2
            }

            set ::eye::widget(event,check,uneimg)      1
            set ::eye::widget(event,check,calibration) 1
            set ::eye::widget(event,check,objet)       0
            set ::eye::widget(event,check,telescope)   0
            $::eye::widget(event).check_uneimg      configure -state normal
            $::eye::widget(event).check_calibration configure -state normal
            $::eye::widget(event).check_objet       configure -state disabled
            $::eye::widget(event).check_telescope   configure -state disabled

            ::eye::align_onestar

            tk_messageBox -message "Deplacer l etoile qui se trouve dans le rond bleu au centre du carre bleu" -type ok
            ::eye::start_boucle "onestar"

         }

      }


      # calcul et affichage des centres
      gren_info "Calcul du pole mecanique Termine"
      $::eye::widget(fov,tools).meca          configure -relief raised
      $::eye::widget(event).check_uneimg      configure -state normal
      $::eye::widget(event).check_calibration configure -state normal
      $::eye::widget(event).check_objet       configure -state normal
      $::eye::widget(event).check_telescope   configure -state normal

      # fin boucle par clic sur bouton
   }




   proc ::eye::fov_table_ref_stars { } {

   }






   proc ::eye::align_onestar { } {

      set fen .align_onestar
      if {[winfo exists $fen]} {
         destroy $fen
      }
      toplevel $fen -class Toplevel
      wm geometry $fen 500x500+0+0
      wm focusmodel $fen passive
      wm overrideredirect $fen 0
      wm resizable $fen 1 1
      wm deiconify $fen
      wm title $fen "Centrer le point rouge"
      #bind $fen <Destroy> { ::main_gui::closewindow ; exit}
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"
      wm withdraw .
      focus -force $fen

      set frm $fen.frm

      #--- Cree le frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand yes -fill both  -padx 10 -pady 5

         set width 500
         set height 500

         set ::eye::align_onestar_can [canvas $frm.chart -width $width -height $height -bd 1 -relief groove]

         pack $::eye::align_onestar_can -side top -anchor c

         set off 30
         $::eye::align_onestar_can create line $off [expr $height/2] [expr $width-$off] [expr $height/2]  -fill grey -tag "repere"
         $::eye::align_onestar_can create line [expr $width/2] $off [expr $width/2] [expr $height-$off]        -fill grey -tag "repere"

         set xc  [expr $width/2]
         set yc  [expr $height/2]

         set r 50
         $::eye::align_onestar_can create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                       [expr int($xc+$r)] [expr int($yc+$r)] -outline grey -tag "repere" -width 1

         set r 100
         $::eye::align_onestar_can create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                       [expr int($xc+$r)] [expr int($yc+$r)] -outline grey -tag "repere" -width 1

         set r 150
         $::eye::align_onestar_can create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                       [expr int($xc+$r)] [expr int($yc+$r)] -outline grey -tag "repere" -width 1

        set distpix [expr sqrt( pow(($::eye::widget(fov,onestar,xo) - $::eye::widget(fov,onestar,xw))*$::eye::fov(cddelt1),2) \
                              + pow(($::eye::widget(fov,onestar,yo) - $::eye::widget(fov,onestar,yw))*$::eye::fov(cddelt2),2) ) ]
        set distpix [::eye::coord_to_write $distpix]
        $::eye::align_onestar_can create text 10 10 \
                   -text "Diff poles avant deplacement : $distpix" -tags "distanceo" -anchor w \
                   -fill black

        $::eye::align_onestar_can create text 10 25 \
                   -text "Diff poles final : " -tags "distancef" -anchor w \
                   -fill black

   }




   proc ::eye::onestar_move {  } {

      set width  500
      set height 500
      set r 8

      set xc [expr ($::eye::widget(fov,onestar,xm) - $::eye::widget(fov,onestar,xw)) * $width  / 2.0 / $::eye::widget(fov,boxradius) + $width  / 2.0]
      set yc [expr (-$::eye::widget(fov,onestar,ym) + $::eye::widget(fov,onestar,yw)) * $height / 2.0 / $::eye::widget(fov,boxradius) + $height  / 2.0]

      catch {$::eye::align_onestar_can delete -tag "point"}
      catch {$::eye::hCanvas delete -tag "point"}

      #gren_info "xm $::eye::widget(fov,onestar,xm) ym $::eye::widget(fov,onestar,ym)\n"
      #gren_info "xw $::eye::widget(fov,onestar,xw) yw $::eye::widget(fov,onestar,yw)\n"
      #gren_info "xo $::eye::widget(fov,onestar,xo) yo $::eye::widget(fov,onestar,yo)\n"
      #gren_info "xc $xc yc $yc\n"

      $::eye::align_onestar_can create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                    [expr int($xc+$r)] [expr int($yc+$r)] -fill red -tag "point" -width 1


      #set coord [::confVisu::picture2Canvas $::eye::visuNo [list $::eye::widget(fov,onestar,xm) $::eye::widget(fov,onestar,ym) ]]
      #set xima  [lindex $coord 0]
      #set yima  [lindex $coord 1]

      #$::eye::hCanvas create oval [expr $xima-$r] [expr $yima-$r] \
      #                            [expr $xima+$r] [expr $yima+$r] \
      #                           -fill {} -outline green -width 1 \
      #                           -tag "point"


   }

   proc ::eye::coord_to_write { dist } {

      set dw ""
      if {$dist > 1} {
         set dd [expr floor($dist)]
         set dm [expr ($dist - $dd)*60.0]
      } else {
         set dd 0
         set dm [expr $dist*60.0]
      }
      if {$dm >= 60.0} {
         incr dd
         set dm [expr $dm - 60.0]
      }
      set ds [expr ($dm - floor($dm))*60.0]
      set dm [expr floor($dm)]
      if {$ds >= 60.0} {
         incr dm
         set ds [expr $ds - 60.0]
      }
      if {$dm >= 60.0} {
         incr dd
         set dm [expr $dm - 60]
      }
      return [format "%0.fd%0.fm%0.fs" $dd $dm $ds]
   }







   proc ::eye::center_object { } {
   
      # Effacement des traces de pointage de etoiles de ref
      if {[info exists ::eye::list_star]} {
         foreach star $::eye::list_star {
            catch {$::eye::hCanvas delete centre_$star}
         }
      }

      # on refait le wcs a l instant du lancement de la routine
      ::eye::fov_wcs_review

      array unset ::eye::stars_move
      set ::eye::lxc ""
      set ::eye::lyc ""
      
      # Gestionnaire d evenement
      set ::eye::widget(event,check,uneimg)      1
      set ::eye::widget(event,check,calibration) 0
      set ::eye::widget(event,check,objet)       1
      set ::eye::widget(event,check,telescope)   0
      $::eye::widget(event).check_uneimg      configure -state normal
      $::eye::widget(event).check_calibration configure -state disabled
      $::eye::widget(event).check_objet       configure -state normal
      $::eye::widget(event).check_telescope   configure -state disabled
      
      ::eye::align_onestar
      
      
   }
