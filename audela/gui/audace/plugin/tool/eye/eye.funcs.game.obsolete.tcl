   proc ::eye::game_step_echec_obsolete { } {

      gren_erreur "Echec \n"
      set res [tk_messageBox -message "Avez vous tout essayé ?" -type yesno]
      if {$res == "no"} { return }

      set lfatal [list 101 111]
      set lpass  [list 102 141]
      set lback  [list ]
      set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set id  [lindex $l 0]

      if { $id in $lfatal } {
         ::eye::game_termine_echec
      }

      switch  $id {
         102 {
             $::eye::game_tab insert $::eye::game_step_cpt [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" "" "" default]
             $::eye::game_tab delete [expr $::eye::game_step_cpt+1] [expr $::eye::game_step_cpt+6]
             ::eye::game_step_delete 102
             ::eye::game_step_delete 141
             ::eye::game_step_delete 142
             ::eye::game_step_delete 143
             ::eye::game_step_delete 144
             ::eye::game_step_delete 145
             lappend ::eye::game_storyboard [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" default]
             set ::eye::game_storyboard [lsort -index 0 $::eye::game_storyboard]
             incr ::eye::game_step_cpt -1
             ::eye::game_step_next
         }
         141 {
             $::eye::game_tab insert $::eye::game_step_cpt [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" "" "" default]
             $::eye::game_tab delete [expr $::eye::game_step_cpt+1] [expr $::eye::game_step_cpt+5]
             ::eye::game_step_delete 141
             ::eye::game_step_delete 142
             ::eye::game_step_delete 143
             ::eye::game_step_delete 144
             ::eye::game_step_delete 145
             lappend ::eye::game_storyboard [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" default]
             set ::eye::game_storyboard [lsort -index 0 $::eye::game_storyboard]
             incr ::eye::game_step_cpt -1
             ::eye::game_step_next
         }
         142 {
             $::eye::game_tab insert $::eye::game_step_cpt [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" "" "" default]
             $::eye::game_tab delete [expr $::eye::game_step_cpt+1] [expr $::eye::game_step_cpt+4]
             ::eye::game_step_delete 142
             ::eye::game_step_delete 143
             ::eye::game_step_delete 144
             ::eye::game_step_delete 145
             lappend ::eye::game_storyboard [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" default]
             set ::eye::game_storyboard [lsort -index 0 $::eye::game_storyboard]
             incr ::eye::game_step_cpt -1
             ::eye::game_step_next
         }
         143 {
             $::eye::game_tab insert $::eye::game_step_cpt [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" "" "" default]
             $::eye::game_tab delete [expr $::eye::game_step_cpt+1] [expr $::eye::game_step_cpt+3]
             ::eye::game_step_delete 143
             ::eye::game_step_delete 144
             ::eye::game_step_delete 145
             lappend ::eye::game_storyboard [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" default]
             set ::eye::game_storyboard [lsort -index 0 $::eye::game_storyboard]
             incr ::eye::game_step_cpt -1
             ::eye::game_step_next
         }
         144 {
             $::eye::game_tab insert $::eye::game_step_cpt [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" "" "" default]
             $::eye::game_tab delete [expr $::eye::game_step_cpt+1] [expr $::eye::game_step_cpt+2]
             ::eye::game_step_delete 144
             ::eye::game_step_delete 145
             lappend ::eye::game_storyboard [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" default]
             set ::eye::game_storyboard [lsort -index 0 $::eye::game_storyboard]
             incr ::eye::game_step_cpt -1
             ::eye::game_step_next
         }
         145 {
             $::eye::game_tab insert $::eye::game_step_cpt [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" "" "" default]
             $::eye::game_tab delete [expr $::eye::game_step_cpt+1] [expr $::eye::game_step_cpt+1]
             ::eye::game_step_delete 145
             lappend ::eye::game_storyboard [list 151 "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur" default]
             set ::eye::game_storyboard [lsort -index 0 $::eye::game_storyboard]
             incr ::eye::game_step_cpt -1
             ::eye::game_step_next
         }
         151 {
         }

      }

      return 0
   }

   proc ::eye::game_view_step_obs { id x y rep level } {

      incr level
      if {$level > $::eye::game_level } {
         set ::eye::game_level $level
      }

#      set decalx   300
#      set xbox     200
#      set decaly   80
#      set originx  150
#      set originy  50
      set decalx   60
      set xbox     50
      set decaly   30
      set originx  150
      set originy  50

      if {[info exists ::eye::game_con($id,ok)]} {

         if {[string is integer -strict $::eye::game_con($id,ok)]} {

            if {![info exists ::eye::game_y_level($level)]} {
               set ::eye::game_y_level($level) $originy
            } else {
               incr ::eye::game_y_level($level) $decaly
            }

            set xe [ expr $x + $decalx]
            set ye $::eye::game_y_level($level)
            $::eye::game_can create line [expr $x + $xbox / 2 ] $y [expr $xe - ($xbox / 2 )] $ye

            set ide $::eye::game_con($id,ok)
            set color green
            #$::eye::game_can create text $xe $ye -text "$ide : $::eye::game_con($ide,title)" -tags "text" -justify left -fill $color -width $xbox
            $::eye::game_can create text $xe $ye -text "$ide" -tags "text" -justify left -fill $color -width $xbox
            ::eye::game_view_step $ide $xe $ye "ok" $level
         }

      }

      if {[info exists ::eye::game_con($id,echec)]} {

         if {[string is integer -strict $::eye::game_con($id,echec)]} {

            if {![info exists ::eye::game_y_level($level)]} {
               set ::eye::game_y_level($level) $originy
            } else {
               incr ::eye::game_y_level($level) $decaly
            }


            set xe [ expr $x + $decalx]
            set ye $::eye::game_y_level($level)
            $::eye::game_can create line [expr $x + $xbox / 2 ] $y [expr $xe - ($xbox / 2 )] $ye
            set ide $::eye::game_con($id,echec)
            set color red
            #$::eye::game_can create text $xe $ye -text "$ide : $::eye::game_con($ide,title)" -tags "text" -justify left -fill $color -width 200
            $::eye::game_can create text $xe $ye -text "$ide" -tags "text" -justify left -fill $color -width $xbox
            ::eye::game_view_step $ide $xe $ye "echec" $level
         }

      }


   }



   proc ::eye::game_step_delete_obsolete { id } {
      set pos [lsearch -index 0 $::eye::game_storyboard $id]
      set ::eye::game_storyboard [lreplace $::eye::game_storyboard $pos $pos]
      return 0
   }






   proc ::eye::game_termine_echec_obsolete { } {
      $::eye::widget(game,etape) configure -text "Appuyer sur Run"
      ::eye::game_step_button fin
      $::eye::game_tab delete 0 end
      tk_messageBox -message "Echec de la mission !\nEntrainez vous" -type ok
      return 0
   }




   proc ::eye::game_lecture_arbre_obsolete { } {

      ::eye::game_scenario
      ::eye::game_pdf_creation


      set ide 1
      set xe 150
      set ye 50
      set ::eye::game_level 1
      array unset ::eye::game_t

      ::eye::game_build_t $ide "1" "ok" 1
      ::eye::game_build_coord


      # Cloture et ecriture du pdf
      ::mypdf startPage -paper a4
      ::mypdf canvas $::eye::game_can -x 5 -y 5 -width 1500 -height 730

      ::mypdf finish
      ::mypdf write -file $::eye::game_pdf_filename
      ::mypdf destroy
      catch { exec $::readpdf $::eye::game_pdf_filename & } msg


      return

      array unset ::eye::game_y_level
      $::eye::game_can create text $xe $ye -text "$ide" -tags "text" -justify left -anchor center -width 200
      #$::eye::game_can create text $xe $ye -text "$ide : $::eye::game_con($ide,title)" -tags "text" -justify left -anchor center -width 200
      ::eye::game_view_step $ide $xe $ye "ok" 1
      gren_info "::eye::game_level $::eye::game_level\n"

      # Cloture et ecriture du pdf
      ::mypdf finish
      ::mypdf write -file $::eye::game_pdf_filename
      ::mypdf destroy
      catch { exec $::conf(editnotice_pdf) $::eye::game_pdf_filename & } msg


   }



   ## recupere et affiche les coordonnees dans une carte
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   # @return void
   #
   proc ::eye::game_run_obsolete { } {

      ::console::clear

      # Information
      gren_info "Bonjour ::eye::widget(game,joueur)\n"
      gren_info "La partie commence et vous etes chronometré\n"
      gren_info "Il est \n"
      gren_info "Vos options de jeu sont \n"

      # Resumé
      if { $::eye::widget(game,tel) } {
         gren_info "- Vous avez un Telescope\n"
         if { $::eye::widget(game,con) } {
            gren_info "- Vous le pilotez avec Audela\n"
         } else {
            gren_info "- Vous utilisez la raquete de la monture\n"
         }
         if { $::eye::widget(game,che) } {
            gren_info "- Vous etes muni d'un chercheur electronique\n"
            if { $::eye::widget(game,mes) } {
               gren_info "- Vous allez utiliser un chercheur electronique pour finaliser la mise en station\n"
            }
         } else {
            if { $::eye::widget(game,mes) } {
               gren_info "- Vous allez utiliser un chercheur electronique simulé pour finaliser la mise en station\n"
            }
         }

      } else {
         gren_info "- Vous n'avez pas de telescope\n"
         if { $::eye::widget(game,mes) } {
            gren_info "- Vous allez utiliser un chercheur electronique simulé pour finaliser la mise en station\n"
         }
      }

      # StoryBoard
      set ::eye::game_storyboard ""
      lappend ::eye::game_storyboard [list 1 "Etes Vous pret ?" go]

      if { $::eye::widget(game,tel) } {

         if { $::eye::widget(game,gps) } {
            lappend ::eye::game_storyboard [list 101 "Tout brancher ( avec raquette + Occulaire au foyer )" default]
            lappend ::eye::game_storyboard [list 102 "Dans Audela - Configuration - Position de l'observateur : entrer les infos" default]
         } else {
            lappend ::eye::game_storyboard [list 111 "Tout brancher ( avec raquette + Camera au foyer )" default]
            lappend ::eye::game_storyboard [list 112 "Mettre le telescope en position parking, et alimenter les cameras" default]
            lappend ::eye::game_storyboard [list 113 "Dans Audela - ATOS - Lancer la visualisation continue" default]
            lappend ::eye::game_storyboard [list 114 "Switch video sur le foyer, et eteindre la VTI" default]
            lappend ::eye::game_storyboard [list 115 "Dans Audela - ATOS - Faire un Noir de 1 minute, et finaliser l image de noir" default]
            if { $::eye::widget(game,che) } {
               lappend ::eye::game_storyboard [list 121 "Switch video sur le chercheur electronique, Faire un Noir de 1 minute, et finaliser l image de noir" default]
            }
            lappend ::eye::game_storyboard [list 131 "Switch video sur le foyer, Allumer la VTI et basculer sur l affichage de la position" default]
            lappend ::eye::game_storyboard [list 132 "Dans Audela - Configuration - Position de l'observateur : entrer les infos" default]
            lappend ::eye::game_storyboard [list 133 "Enlever la camera et mettre un occulaire au foyer" default]
         }

         lappend ::eye::game_storyboard [list 141 "Dans Audela - Configuration - Temps : Verifier l'heure du PC" default]
         lappend ::eye::game_storyboard [list 142 "Tourner la monture jusqu a voir le cercle de la polaire au plus bas, mettre la bague sur le 0" default]
         lappend ::eye::game_storyboard [list 143 "Dans Audela - Telescope - Viseur polaire : choisir eq6" default]
         lappend ::eye::game_storyboard [list 144 "Tourner la monture pour mettre la valeur de l angle horaire de la polaire grace la bague (inscription du bas, positif vers l ouest)" default]
         lappend ::eye::game_storyboard [list 145 "Centrer l'etoile polaire avec le rond du viseur polaire en jouant sur les axes azimuth hauteur" default]

         lappend ::eye::game_storyboard [list 161 "Mettre le telescope en position parking, et alimenter prise electrique et monture" default]
         lappend ::eye::game_storyboard [list 162 "Avec la raquette, insérer les paramètres de date et de position, et demarrer l alignement 1 étoile." default]

         if { $::eye::widget(game,con) } {
            # Pilotage avec Audela
            lappend ::eye::game_storyboard [list 171 "Centrer l etoile a l occulaire." default]
            lappend ::eye::game_storyboard [list 172 "Enlever l occulaire et mettre la camera au foyer" default]
            lappend ::eye::game_storyboard [list 173 "Switch video sur le foyer, Centrer l etoile dans l ecran avec la raquette" default]
            lappend ::eye::game_storyboard [list 174 "Synchroniser Synscan" default]
         } else {
            # Pilotage avec Raquette
            lappend ::eye::game_storyboard [list 171 "Stellarium pour choisir l etoile la plus proche de la zone d observation." default]
            lappend ::eye::game_storyboard [list 172 "Centrer l etoile a l occulaire." default]
            lappend ::eye::game_storyboard [list 173 "Synchroniser Synscan" default]
         }
         if { $::eye::widget(game,che) } {
            lappend ::eye::game_storyboard [list 176 "Switch video sur le chercheur electronique, Audela : Selectionner le reticule sur l etoile" default]
         }

         if { $::eye::widget(game,con) } {
            # Pilotage avec Audela
            lappend ::eye::game_storyboard [list 171 "Débrancher la raquette et y mettre l Eqmod (les moteurs sont toujours en route normalement)" default]
            lappend ::eye::game_storyboard [list 172 "Audela : Charger l eqmod" default]
            lappend ::eye::game_storyboard [list 173 "Audela - EYE - Coordonnees : Verifier que les moteurs sont en marche" default]
            lappend ::eye::game_storyboard [list 174 "Audela - EYE - Coordonnees : Choisir l etoile d alignement" default]
            lappend ::eye::game_storyboard [list 175 "Switch video sur le foyer, Verifier que l etoile est toujours au centre du foyer" default]
            lappend ::eye::game_storyboard [list 177 "Audela - EYE - Coordonnees : Synchroniser la position de la monture sur l etoile d alignement." default]
            if { $::eye::widget(game,bat) } {
               lappend ::eye::game_storyboard [list 178 "Affiner les foyers du primaire et du chercheur electronique a l aide du filtre de batinov ou equivalent" default]
            } else {
               lappend ::eye::game_storyboard [list 178 "Affiner les foyers du primaire et du chercheur electronique" default]
            }

         }


         if { $::eye::widget(game,con) } {
            lappend ::eye::game_storyboard [list 179 "Switch video sur le chercheur electronique, Audela - EYE - Coordonnees : Selectionner le prochain objet a observer, puis GOTO" default]
            lappend ::eye::game_storyboard [list 181 "Audela - EYE - FOV : Astrometrie et calcul de la position de l objet voulu dans l image" default]
            lappend ::eye::game_storyboard [list 182 "Audela - EYE - Coordonnees : Deplacement final" default]
            lappend ::eye::game_storyboard [list 183 "Switch video sur le foyer, l'objet est au centre, regler le temps de pose" default]
         }


      }


      # On affiche le story board
      $::eye::game_tab delete 0 end

      foreach step $::eye::game_storyboard {
         lassign $step id lab but
         $::eye::game_tab insert end [list $id $lab "" "" $but]
      }

      # Demarrage
      ::eye::game_go

      return 0
   }


   proc ::eye::game_view_step { id x y rep level } {

      incr level
      if {$level > $::eye::game_level } {
         set ::eye::game_level $level
      }

      if {[info exists ::eye::game_con($id,ok)]} {

         if {[string is integer -strict $::eye::game_con($id,ok)]} {

            if {![info exists ::eye::game_y_level($level)]} {
               set ::eye::game_y_level($level) $originy
            } else {
               incr ::eye::game_y_level($level) $decaly
            }

            set xe [ expr $x + $decalx]
            set ye $::eye::game_y_level($level)
            $::eye::game_can create line [expr $x + $xbox / 2 ] $y [expr $xe - ($xbox / 2 )] $ye

            set ide $::eye::game_con($id,ok)
            set color green
            #$::eye::game_can create text $xe $ye -text "$ide : $::eye::game_con($ide,title)" -tags "text" -justify left -fill $color -width $xbox
            $::eye::game_can create text $xe $ye -text "$ide" -tags "text" -justify left -fill $color -width $xbox
            ::eye::game_view_step $ide $xe $ye "ok" $level
         }

      }

      if {[info exists ::eye::game_con($id,echec)]} {

         if {[string is integer -strict $::eye::game_con($id,echec)]} {

            if {![info exists ::eye::game_y_level($level)]} {
               set ::eye::game_y_level($level) $originy
            } else {
               incr ::eye::game_y_level($level) $decaly
            }


            set xe [ expr $x + $decalx]
            set ye $::eye::game_y_level($level)
            $::eye::game_can create line [expr $x + $xbox / 2 ] $y [expr $xe - ($xbox / 2 )] $ye
            set ide $::eye::game_con($id,echec)
            set color red
            #$::eye::game_can create text $xe $ye -text "$ide : $::eye::game_con($ide,title)" -tags "text" -justify left -fill $color -width 200
            $::eye::game_can create text $xe $ye -text "$ide" -tags "text" -justify left -fill $color -width $xbox
            ::eye::game_view_step $ide $xe $ye "echec" $level
         }

      }


   }

   proc ::eye::fov_cata_obsolete {  } {

      global audace
      #cstycho2_fast /data/astrodata/Catalog/Stars/TYCHO2_FAST 50.73744687472936477 86.03815323569999407 1147.4419512319009 7.3 0

      # voir
      # math::interpolate(n)
      # pour definir une correlation avec $::eye::widget(fov,nbstars)

      ::eye::deleteStar

      #affich_libcata TYCHO2 7.3 red 1

      # Calcul des coordonnees de l image
      set ra  [lindex [ buf$::eye::evt_bufNo getkwd "CRVAL1"] 1]
      set dec [lindex [ buf$::eye::evt_bufNo getkwd "CRVAL2"] 1]
      set naxis1  [lindex [ buf$::eye::evt_bufNo getkwd "NAXIS1"] 1]
      set naxis2  [lindex [ buf$::eye::evt_bufNo getkwd "NAXIS2"] 1]
      set scale_x [lindex [ buf$::eye::evt_bufNo getkwd "CDELT1"] 1]
      set scale_y [lindex [ buf$::eye::evt_bufNo getkwd "CDELT2"] 1]

      if {$scale_x==""} {return}

      set mscale  [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
      set radius  [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]

      set ::eye::fov(evt,scalex) $scale_x
      set ::eye::fov(evt,scaley) $scale_y

      #gren_info "ra = $ra\n"
      #gren_info "dec = $dec\n"
      #gren_info "radius = $radius\n"

      # Appel au catalogue d etoile TYCHO2
      set limitmag 8
      set cmd cstycho2
      if {[info exists ::tools_cata::catalog_tycho2]} {
         set path $::tools_cata::catalog_tycho2
      } else {
         set path $audace(rep_userCatalogTycho2)
      }
      set commonfields { RAdeg DEdeg 5.0 VT e_VT }
      set listsources [$cmd $path $ra $dec $radius $limitmag 0]
      set listsources [::manage_source::set_common_fields $listsources TYCHO2 $commonfields]

      # recup des etoiles de ref
      set cf [lindex $listsources 0]
      set sources [lindex $listsources 1]
      set newsources ""
      set cpt 0
      set zl ""
      foreach s $sources {
         set lcf [lindex $s 0 1]
         set ra  [lindex $lcf 0]
         set dec [lindex $lcf 1]
         set mag [lindex $lcf 3]
         lappend zl [list $ra $dec $mag ]
      }
      set zl [lsort -increasing -real -index 2 $zl]

      foreach z $zl {

         set ra  [lindex $z 0]
         set dec [lindex $z 1]

         set img0_radec [ list $ra $dec ]
         set img0_xy [ buf$::eye::evt_bufNo radec2xy $img0_radec ]
         #set can0_xy [ ::audace::picture2Canvas $img0_xy ]

         set x [lindex $img0_xy 0]
         set y [lindex $img0_xy 1]

         if { $x < 0 || $x>$naxis1 || $y<0 || $y > $naxis2} { continue }

         set x [expr int($x)]
         set y [expr int($y)]
         set radius $::eye::widget(fov,boxradius)
         set box [list [expr {$x-$radius}] [expr {$y-$radius}] [expr { $x+$radius }] [expr { $y+$radius }]]
         lassign [buf$::eye::evt_bufNo fitgauss $box] xi xc -> xs yi yc -> ys

         set intensity [expr sqrt(pow($xi,2)+pow($yi,2))]
         set sky [expr sqrt(pow($xs,2)+pow($ys,2))]
         set r [expr sqrt(pow($xc-$x,2)+pow($yc-$y,2))]

         #gren_info "intensity=$intensity > $sky\n"
         #gren_info "r=$r\n"

         if {$intensity<[expr $sky/2.0]} {
            #gren_erreur "rejected too faint\n"
            continue
         }
         if {$r > $::eye::widget(fov,rdiff)} {
            #gren_erreur "rejected to far\n"
            continue
         }
         if {$xc < $::eye::widget(fov,boxradius) || $xc > [expr $naxis1 - $::eye::widget(fov,boxradius)] } {
            #gren_erreur "rejected to near the border X\n"
            continue
         }
         if {$yc < $::eye::widget(fov,boxradius) || $yc > [expr $naxis2 - $::eye::widget(fov,boxradius)] } {
            #gren_erreur "rejected to near the border Y\n"
            continue
         }

         incr cpt
         #set ::eye::stars($star,$camsimu,crpix1) $xc
         #set ::eye::stars($star,$camsimu,crpix2) $yc
         #set ::eye::stars($star,simu,ra)         $ra
         #set ::eye::stars($star,simu,dec)        $dec
         if {[::eye::star_exist $ra $dec]==0} {
            #gren_erreur "star exist\n"
            continue
         }
         ::eye::add_star $ra $dec $intensity $xc $yc

         if {[llength $::eye::list_star]>$::eye::widget(fov,nbref)} {
            break
         }

         #gren_info "star ref = $cpt\n"
         if {[info exists ::eye::fov(crval1)] && [info exists ::eye::fov(crval2)]} {
            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(crval1) $::eye::fov(crval2) blue I
            ::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(crval1) $::eye::fov(crval2) blue I
         }
         foreach star $::eye::list_star_ok {
            ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) green $star
            ::eye::fov_tools_point_radec $::eye::hCanvas $::eye::evt_bufNo $::eye::visuNo \
                                         $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec) green $star
         }


      }

      #  affich_libcata TYCHO2 7.3 red 1

      return
   }


