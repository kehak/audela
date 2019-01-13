   proc ::eye::init_mesure { visuNo } {

      global private

      set private(psf_toolbox,$visuNo,gui)                 0
      set private(psf_toolbox,$visuNo,radius)              $::eye::widget(fov,boxradius)
      set private(psf_toolbox,$visuNo,radius,min)          1
      set private(psf_toolbox,$visuNo,radius,max)          $::eye::widget(fov,boxradius)
      set private(psf_toolbox,$visuNo,globale)             0
      set private(psf_toolbox,$visuNo,globale,min)         5
      set private(psf_toolbox,$visuNo,globale,max)         $::eye::widget(fov,boxradius)
      set private(psf_toolbox,$visuNo,globale,confidence)  90
      set private(psf_toolbox,$visuNo,saturation)          250
      set private(psf_toolbox,$visuNo,threshold)           $::eye::widget(fov,rdiff)
      set private(psf_toolbox,$visuNo,globale)             1
      set private(psf_toolbox,$visuNo,ecretage)            1
      set private(psf_toolbox,$visuNo,methode)             "photom"
      set private(psf_toolbox,$visuNo,precision)           high
      set private(psf_toolbox,$visuNo,photom,r1)           1
      set private(psf_toolbox,$visuNo,photom,r2)           2
      set private(psf_toolbox,$visuNo,photom,r3)           2.6
      set private(psf_toolbox,$visuNo,marks,cercle)        1
      set private(psf_toolbox,$visuNo,globale,arret)       1
      set private(psf_toolbox,$visuNo,globale,nberror)     3
      set private(psf_toolbox,$visuNo,gaussian_statistics) 1
      set private(psf_toolbox,$visuNo,read_out_noise)      0
      set private(psf_toolbox,$visuNo,beta)                -3

      return 0
   }






   #------------------------------------------------------------
   ## Fonction qui mesure le photocentre d'une source
   # pour un seul rayon de mesure et ne fournissant que les
   # positions X Y pixel dans l image.
   #
   # @brief Cette fonction dialogue avec une GUI ou non
   #
   # @param visuNo numéro de la visu
   # @param bufNo numéro du buffer
   # @param x : coordonnee pixel de la source dans l'image
   # @param y : coordonnee pixel de la source dans l'image
   #
   # @return void
   #
   proc ::eye::PSF_one_radius { visuNo bufNo x y } {

      global private

      set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]

      if { $x>1 && $x<$naxis1 && $y>1 && $y<$naxis2 } {
      } else {
         set private(psf_toolbox,$visuNo,psf,err_psf) "Out of image"
         return
      }

      # Mesure
      set xs0 [expr int($x - $private(psf_toolbox,$visuNo,radius))]
      set ys0 [expr int($y - $private(psf_toolbox,$visuNo,radius))]
      set xs1 [expr int($x + $private(psf_toolbox,$visuNo,radius))]
      set ys1 [expr int($y + $private(psf_toolbox,$visuNo,radius))]
      set box [list $xs0 $ys0 $xs1 $ys1]
      set r [ buf$bufNo fitgauss $box ]
      set r1  [expr int($private(psf_toolbox,$visuNo,photom,r1) * $private(psf_toolbox,$visuNo,radius))]
      set r2  [expr int($private(psf_toolbox,$visuNo,photom,r2) * $private(psf_toolbox,$visuNo,radius))]
      set r3  [expr int($private(psf_toolbox,$visuNo,photom,r3) * $private(psf_toolbox,$visuNo,radius))]
      set err [ catch { set photom [buf$bufNo photom $box square $r1 $r2 $r3 ] } msg ]
      if {$err} {
         set private(psf_toolbox,$visuNo,psf,err_psf)  "Erreur buf photom"
         return -code -1 "Erreur buf photom : $photom"
      }
      set err [ catch { set stat [buf$bufNo stat $box ] } msg ]
      if {$err} {
         set private(psf_toolbox,$visuNo,psf,err_psf)  "Erreur buf stat"
         return -code -1 "Erreur buf stat : $stat"
      }
      set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]
      set private(psf_toolbox,$visuNo,psf,xsm)       [format "%.4f" [lindex $r 1] ]
      set private(psf_toolbox,$visuNo,psf,ysm)       [format "%.4f" [lindex $r 5] ]
      set private(psf_toolbox,$visuNo,psf,err_xsm)   "-"
      set private(psf_toolbox,$visuNo,psf,err_ysm)   "-"
      set private(psf_toolbox,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
      set private(psf_toolbox,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
      set private(psf_toolbox,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
      set private(psf_toolbox,$visuNo,psf,flux)      [format "%.2f" [lindex $photom 0] ]
      set private(psf_toolbox,$visuNo,psf,err_flux)  "-"
      set private(psf_toolbox,$visuNo,psf,pixmax)    [format "%.2f" [lindex $stat 2] ]
      set private(psf_toolbox,$visuNo,psf,intensity) [format "%.2f" [expr [lindex $stat 2] - [lindex $photom 2] ] ]
      set private(psf_toolbox,$visuNo,psf,sky)       [format "%.2f" [lindex $photom 2] ]
      set private(psf_toolbox,$visuNo,psf,err_sky)   [format "%.2f" [lindex $photom 3] ]
      set private(psf_toolbox,$visuNo,psf,snint)     [format "%.2f" [expr [lindex $photom 0] / sqrt ([lindex $photom 0]+[lindex $photom 4]*[lindex $photom 2] ) ] ]
      set private(psf_toolbox,$visuNo,psf,radius)    $private(psf_toolbox,$visuNo,radius)
      set private(psf_toolbox,$visuNo,psf,err_psf)   "-"

      # Ecretage
      if {[info exists private(psf_toolbox,$visuNo,psf,rdiff)]} {
         if { $private(psf_toolbox,$visuNo,psf,rdiff) > $private(psf_toolbox,$visuNo,threshold) } {
            set private(psf_toolbox,$visuNo,psf,err_psf) "Too Far"
         }
      }

      return
   }

   #------------------------------------------------------------
   ## Fonction qui mesure le photocentre d'une source
   # pour un ensemble de rayons de mesure et ne fournissant
   # que les positions X Y pixel dans l image.
   #
   # @brief la variable globale private permet de fixer
   # les parametres pour dialoguer avec une gui et/ou
   # stoquer les resultats pour effectuer des graphes
   #
   # @param visuNo numéro de la visu
   # @param bufNo numéro du buffer
   # @param x : coordonnee pixel de la source dans l'image
   # @param y : coordonnee pixel de la source dans l'image
   #
   # @return void
   #
#::eye::ressource ; ::eye::PSF_globale 1 1 402 243

   proc ::eye::PSF_globale { visuNo bufNo x y } {

      global private
      global private_graph

      #gren_info "USAGE : ::eye::PSF_globale $visuNo $bufNo $x $y\n"

      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {

         set private(psf_toolbox,$visuNo,radius) $radius

         # methode de mesure ayant la methode globale en interne
         ::eye::PSF_one_radius $visuNo $bufNo $x $y

         # Action si pas d erreur
         if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {

            # Si ca marche le compteur d erreur consecutives retombent a zero
            set nberror 0

            # Recupere les donnees intermediaires
            foreach key [::audace::get_fields_current_psf] {
               set private_graph($radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
            }

         } else {
            incr nberror
         }

         # Arret si trop d erreurs
         if {$private(psf_toolbox,$visuNo,globale,arret) && $nberror>=$private(psf_toolbox,$visuNo,globale,nberror)} {
            break
         }

      }



      # on supprime les valeurs dont le flux diminue en debut de courbe
      set cpt 0
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} \
              {$radius <= $private(psf_toolbox,$visuNo,globale,max)} \
                 {incr radius} {

         if {[info exists private_graph($radius,flux)]} {
            incr cpt

            # premier contact
            if {$cpt==1} {
               set flux $private_graph($radius,flux)
               set last_radius $radius
               continue
            }

            if {$private_graph($radius,flux)>$flux} {
               # le flux est croissant, on sort
               break
            } else {
               # le flux est decroissant
               foreach key [::audace::get_fields_current_psf] {
                  unset private_graph($last_radius,$key)
               }
               set flux $private_graph($radius,flux)
               set last_radius $radius
            }
         }
      }

      # on cherche les meilleurs rayons
      # par critere sur le fond du ciel minimal
      set list_radius [::audace::calcule_solution $visuNo]

      # calcul des distances aux solutions de Flux
      if {$private(psf_toolbox,$visuNo,methode)!="fitgauss"} {
         ::audace::suppression_par_distance_solution $visuNo
         set list_radius [::audace::calcule_solution $visuNo]
      }

      return
   }







   proc ::eye::photom_methode { visuNo bufNo xsm ysm star } {

      global private

      #gren_info "USAGE : ::eye::photom_methode $visuNo $bufNo $xsm $ysm $star\n"

      set log 0

      if {$private(psf_toolbox,$visuNo,globale)} {
         set err [catch {::eye::PSF_globale $visuNo $bufNo $xsm $ysm} msg]
      } else {
         set err [catch {::eye::PSF_one_radius $visuNo $bufNo $xsm $ysm} msg]
      }

      if {$err} {
         gren_erreur "Erreur dans mesure de PSF (PSF ToolBox)\n"
         gren_erreur "Err= $err\n"
         gren_erreur "Msg= $msg\n"
      }

      set  xsm          $private(psf_toolbox,$visuNo,psf,xsm)
      set  ysm          $private(psf_toolbox,$visuNo,psf,ysm)
      set  pixmax       $private(psf_toolbox,$visuNo,psf,pixmax)
      set  intensite    $private(psf_toolbox,$visuNo,psf,intensity)
      set  sky          $private(psf_toolbox,$visuNo,psf,sky)
      set  err_sky      $private(psf_toolbox,$visuNo,psf,err_sky)
      set  snint        $private(psf_toolbox,$visuNo,psf,snint)
      set  err_psf      $private(psf_toolbox,$visuNo,psf,err_psf)

      if {$err_psf=="Saturated"} { set err_psf "-" }

      if {$err_psf=="-"} {
         set success 1
      } else {
         set success 0
      }
      if {$snint<1} { set success 0 }

      if {$log==1 && $star == 1 && $success == 0 } {
         gren_erreur "Star $star\n"
         gren_erreur "xsm          $private(psf_toolbox,$visuNo,psf,xsm)       \n"
         gren_erreur "ysm          $private(psf_toolbox,$visuNo,psf,ysm)       \n"
         gren_erreur "pixmax       $private(psf_toolbox,$visuNo,psf,pixmax)    \n"
         gren_erreur "intensite    $private(psf_toolbox,$visuNo,psf,intensity) \n"
         gren_erreur "sky          $private(psf_toolbox,$visuNo,psf,sky)       \n"
         gren_erreur "err_sky      $private(psf_toolbox,$visuNo,psf,err_sky)   \n"
         gren_erreur "snint        $private(psf_toolbox,$visuNo,psf,snint)     \n"
         gren_erreur "err_psf      $private(psf_toolbox,$visuNo,psf,err_psf)   \n"
         gren_erreur "success      $success                                           \n"
      }

      return [ list $success $xsm $ysm $pixmax $intensite $sky $err_sky $snint ]

   }


   proc ::eye::mesure_star { x y bufNo } {

      set log 0

      set radius $::eye::widget(fov,boxradius)
      set xb [expr int($x)]
      set yb [expr int($y)]
      set box [list [expr {$xb-$radius}] [expr {$yb-$radius}] [expr { $xb+$radius }] [expr { $yb+$radius }]]
      if {$log==1} {
         gren_info "box = $box \n"
      }

      lassign [buf$bufNo fitgauss $box] xi xc -> xs yi yc -> ys



      return
   }

# ::eye::ressource ; ::eye::get_mag_star 02h31m53s +89d15m44s
#  ::eye::ressource ; ::eye::get_mag_star 22h13m02s +86d6m34s

   proc ::eye::get_mag_star { ra dec } {

      global audace
      set mag ""
      set radius 10
      
      #set ra [mc_angle2deg $ra]
      #set dec [mc_angle2deg $dec]
      
      gren_info "get_mag_star $ra $dec\n"

      # recherche dans les etoiles brillantes
      set filestars [file join $audace(rep_catalogues) catagoto etoiles_brillantes.txt]
      gren_info "Catalogue etoiles brillantes : $filestars\n"
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
               if {$cpt == 9} {set m     $x}
               incr cpt
            }
         }
         set name2 "${name2}_${name3}"
         set ras  [mc_angle2deg "${ra_h}h${ra_m}m${ra_s}s"]
         set decs [mc_angle2deg "${dec_h}d${dec_m}m${dec_s}s"]
         #gren_info "$ra $ras $dec $decs\n"
         #gren_info "[expr abs($ra-$ras)*60] [expr abs($dec-$decs)*60]\n"
         
         if { [expr abs($ra-$ras)*60]<$radius &&
              [expr abs($dec-$decs)*60]<$radius } {

            set ras  [format "%0.5f" $ras]
            set decs [format "%0.5f" $decs]

            gren_info "Star : $name2\n"
            gren_info "ras decs : $ras $decs\n"
            gren_info "mag : $m\n"
            
            return [format "%0.1f" $m]
         }
      }
      close $chan
      
      
      # recherche dans tycho
      set cmd cstycho2_fast
      if {[info exists ::tools_cata::catalog_tycho2]} {
         set path $::tools_cata::catalog_tycho2
      } else {
         set path $audace(rep_userCatalogTycho2_fast)
      }
      set commonfields { RAdeg DEdeg 5.0 VT e_VT }
      
      set limitmag 8
      set listsources [$cmd $path $ra $dec $radius $limitmag 0]
      set listsources [::manage_source::set_common_fields $listsources TYCHO2 $commonfields]
      set nb [::manage_source::get_nb_sources $listsources]
      gren_info "nb = $nb\n"
      
      if {$nb==1} {
         # on pren la mag dans le catalogue
         set mag [format "%0.1f" [lindex $listsources {1 0 0 1 3}]]
      }
      if {$nb>1} {
         # Prendre l etoile la plus brillante
         set mag 99
         foreach s [lindex $listsources 1] {
            set m [format "%0.1f" [lindex $s {0 1 3}]]
            gren_info "m = $m\n"
            if {$m < $mag} {set mag $m}
         }
      }
      
      return $mag
   }






   proc ::eye::add_star { ra dec xc yc mag pixmax intensity sky err_sky snint rdiff} {
      set star [expr [llength $::eye::list_star] + 1]
      lappend ::eye::list_star $star
      lappend ::eye::list_star_ok $star
      set ::eye::stars($star,simu,ra)       $ra
      set ::eye::stars($star,simu,dec)      $dec
      set ::eye::stars($star,cam,crpix1)    [format "%.1f" $xc]
      set ::eye::stars($star,cam,crpix2)    [format "%.1f" $yc]
      set ::eye::stars($star,cam,mag)       [format "%.1f" $mag]
      set ::eye::stars($star,simu,mag)      [format "%.1f" $mag]
      set ::eye::stars($star,cam,pixmax)    [format "%.1f" $pixmax]
      set ::eye::stars($star,cam,intensity) [format "%.1f" $intensity]
      set ::eye::stars($star,cam,sky)       [format "%.1f" $sky]
      set ::eye::stars($star,cam,err_sky)       [format "%.1f" $err_sky]
      set ::eye::stars($star,cam,snint)       [format "%.1f" $snint]
      set ::eye::stars($star,cam,rdiff)     [format "%.1f" $rdiff]
      set img_xy [ buf$::eye::fov_bufNo radec2xy [ list $ra $dec ] ]
      set x [lindex $img_xy 0]
      set y [lindex $img_xy 1]
      set ::eye::stars($star,simu,crpix1)      $xc
      set ::eye::stars($star,simu,crpix2)      $yc
      return
   }



   proc ::eye::star_exist { ra dec } {

      foreach star $::eye::list_star {
         set pi 3.14159265359
         set r [expr sqrt(  pow(($::eye::stars($star,simu,ra)  - $ra)*cos($pi/180.*$dec)/$::eye::fov(evt,scalex),2) \
                          + pow(($::eye::stars($star,simu,dec) - $dec)/$::eye::fov(evt,scaley),2))]
         if {$r<$::eye::widget(fov,boxradius)} {return 0}

      }

      return 1
   }






   #------------------------------------------------------------
   ## recupere et affiche la liste des etoiles de reference
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   # @return void
   #
   proc ::eye::table_ref_stars { } {

      global audace

      set fen .starreflist
      if { [winfo exists $fen] } {
         ::eye::table_ref_stars_load
         wm withdraw $fen
         wm deiconify $fen
         focus $fen
         return
      }
      toplevel $fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]

      wm geometry $fen "680x240+[expr $posx_config + 265]+[expr $posy_config + 55]"
      wm resizable $fen 1 1
      wm title $fen "Liste des Etoiles de Reference"
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"

      set frm $fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set liste [frame $frm.frm  -borderwidth 1 -relief groove]
         pack $liste -in $frm -expand yes -fill both

         set cols [list 0  "Id"            right \
                        0  "RaJ2000"       left  \
                        0  "DecJ2000"      left  \
                        0  "nb mes"        left  \
                        0  "Mag"           right  \
                        0  "Xsm"           right  \
                        0  "Ysm"           right  \
                        0  "pixmax"        right  \
                        0  "Int"           right  \
                        0  "sky"           right  \
                        0  "err_sky"       right  \
                        0  "snint"         right  \
                        0  "Rdiff"         right  \
                  ]

         set ::eye::table_ref_stars_tab $liste.tab
         tablelist::tablelist $::eye::table_ref_stars_tab \
            -columns $cols \
            -labelcommand tablelist::sortByColumn \
            -yscrollcommand [ list $liste.vsb set ] \
            -selectmode extended \
            -activestyle none \
            -stripebackground "#e0e8f0" \
            -showseparators 1

         scrollbar $liste.vsb -orient vertical -command [list $::eye::table_ref_stars_tab yview]
         pack $liste.vsb -in $liste -side left -fill y
         bind [$::eye::table_ref_stars_tab bodypath] <Double-1> [ list ::eye::select_starlist $::eye::table_ref_stars_tab]
         pack $::eye::table_ref_stars_tab -in $liste -expand yes -fill both

         $::eye::table_ref_stars_tab columnconfigure 0 -sortmode dictionary
         $::eye::table_ref_stars_tab columnconfigure 1 -sortmode dictionary

      ::eye::table_ref_stars_load

      return 0
   }



   proc ::eye::table_ref_stars_load { } {

         $::eye::table_ref_stars_tab delete 0 end
         foreach star $::eye::list_star {

            if {![info exists ::eye::stars($star,cam,nbmes)]}     {set ::eye::stars($star,cam,nbmes) ""}
            if {![info exists ::eye::stars($star,simu,mag)]}      {set ::eye::stars($star,simu,mag) ""}
            if {![info exists ::eye::stars($star,cam,crpix1)]}    {set ::eye::stars($star,cam,crpix1) ""}
            if {![info exists ::eye::stars($star,cam,crpix2)]}    {set ::eye::stars($star,cam,crpix2) ""}
            if {![info exists ::eye::stars($star,cam,pixmax)]}    {set ::eye::stars($star,cam,pixmax) ""}
            if {![info exists ::eye::stars($star,cam,intensity)]} {set ::eye::stars($star,cam,intensity) ""}
            if {![info exists ::eye::stars($star,cam,sky)]}       {set ::eye::stars($star,cam,sky) ""}
            if {![info exists ::eye::stars($star,cam,err_sky)]}     {set ::eye::stars($star,cam,err_sky) ""}
            if {![info exists ::eye::stars($star,cam,snint)]}     {set ::eye::stars($star,cam,snint) ""}
            if {![info exists ::eye::stars($star,cam,rdiff)]}     {set ::eye::stars($star,cam,rdiff) ""}

            $::eye::table_ref_stars_tab insert end [ list $star \
                                      [mc_angle2hms $::eye::stars($star,simu,ra) 360 zero 0 auto string] \
                                      [mc_angle2dms $::eye::stars($star,simu,dec) 90 nozero 0 + string]  \
                                      $::eye::stars($star,cam,nbmes)     \
                                      $::eye::stars($star,simu,mag)      \
                                      $::eye::stars($star,cam,crpix1)    \
                                      $::eye::stars($star,cam,crpix2)    \
                                      $::eye::stars($star,cam,pixmax)    \
                                      $::eye::stars($star,cam,intensity) \
                                      $::eye::stars($star,cam,sky)       \
                                      $::eye::stars($star,cam,err_sky)   \
                                      $::eye::stars($star,cam,snint)     \
                                      $::eye::stars($star,cam,rdiff)     \
                               ]
            # Couleur :
         }

   }
