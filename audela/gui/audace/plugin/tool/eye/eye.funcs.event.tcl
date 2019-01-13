


   proc ::eye::start_boucle { { who "" } }  {
      
      if {[$::eye::widget(event).start cget -relief ] == "sunken"} {return 0}
      $::eye::widget(event).start configure -relief sunken
      
      # Debut de la boucle d evement
      while {[$::eye::widget(event).start cget -relief ] == "sunken"} {

         set tt0 [clock clicks -milliseconds]

         if {$::eye::widget(event,check,uneimg)==1}      { 
            set ttp_0 [clock clicks -milliseconds]
            ::eye::evt_uneimg 
            set ::eye::widget(event,duree,uneimg) [format "%4.1f" [expr ([clock clicks -milliseconds]-$ttp_0)/1000.0]]
         }

         if {$::eye::widget(event,check,calibration)==1} { 
            set ttp_0 [clock clicks -milliseconds]
            ::eye::evt_calibration $who
            set ::eye::widget(event,duree,calibration) [format "%4.1f" [expr ([clock clicks -milliseconds]-$ttp_0)/1000.0]]
         }

         if {$::eye::widget(event,check,objet)==1}       { 
            set ttp_0 [clock clicks -milliseconds]
            ::eye::evt_objet $who
            set ::eye::widget(event,duree,objet) [format "%4.1f" [expr ([clock clicks -milliseconds]-$ttp_0)/1000.0]]
         }

         if {$::eye::widget(event,check,telescope)==1}   { 
            set ttp_0 [clock clicks -milliseconds]
            ::eye::evt_telescope 
            set ::eye::widget(event,duree,telescope) [format "%4.1f" [expr ([clock clicks -milliseconds]-$ttp_0)/1000.0]]
         }
         
         # Timing
         set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
         if { $tt_total < .1 } { 
            after 100 
            set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
         }

         # fin iteration boucle d evenement
         #gren_info "temps total : $tt_total\n"
      }
      
      gren_info "Fin boucle d evement $who\n"

      return 0
   }




   proc ::eye::stop_boucle {  }  {
   
      $::eye::widget(event).start configure -relief raised
      $::eye::widget(fov,tools).meca configure -relief raised
      
      # telescope au parking
      if {[::eye::tel_isconnected]==1} {
         tel$::eye::tel radec stop
         tel$::eye::tel speedtrack diurnal 0
         after 1000
        ::eye::tel_goto_parking
      }

      return 0
   }








   proc ::eye::evt_uneimg {  }  {

      #gren_info "Une image\n"
      $::eye::widget(event).feu_uneimg configure -image .iorange

      if {$::eye::widget(game,demo)==1} {
        # atos avi
        set pack 10
        
        for {set i 1} {$i<=$pack} {incr i} {
           #gren_erreur "***\n"
           ::atos_tools_avi::next_image
           visu$::eye::visuNo disp
        }
      }

      # copie le buffer
      buf$::eye::bufNo copyto $::eye::evt_bufNo
      
      $::eye::widget(event).feu_uneimg configure -image .igreen
      update
      return 0
   }








   proc ::eye::evt_calibration { { who "wcs" } }  {
      
      set log 0
      #gren_erreur "who = $who\n"
      switch $who {

         "meca" - "wcs" - "celeste" - "" {

            if {$log==1} {gren_info "Calibration\n"}
            $::eye::widget(event).feu_calibration configure -image .iorange
            set ::eye::list_star_ok ""
            if {$log==1} { 
              gren_info "Nb etoiles de reference : [llength $::eye::list_star]\n"
              gren_info "Nb etoiles de reference OK : [llength $::eye::list_star_ok]\n"
            }
            # on remesure les etoiles de ref
            set cpt 0
            foreach star $::eye::list_star {

               incr cpt
               if {$log==1} { 
                  gren_info "On remesure star $star\n"
                  gren_info "X= $::eye::stars($star,cam,crpix1)\n"
                  gren_info "Y= $::eye::stars($star,cam,crpix2)\n"
               }
               set x [expr int($::eye::stars($star,cam,crpix1))]
               set y [expr int($::eye::stars($star,cam,crpix2))]
               if {$log==1} { gren_info "Effacement $star\n" }
               #catch {$::eye::fov_canvas delete cible_$star }
               catch {$::eye::hCanvas    delete cible_$star }
               update

               if {$log==1} { gren_info "mesure $star\n" }

               #::eye::fov_select $::eye::fov_canvas \
               #                  [expr int($::eye::stars($star,simu,crpix1))] \
               #                  [expr int($::eye::stars($star,simu,crpix2))] \
               #                  $::eye::fov_visuNo \
               #                  $::eye::fov_bufNo \
               #                  simu \
                #                 $star

               ::eye::fov_select $::eye::hCanvas \
                                 $::eye::stars($star,cam,crpix1) \
                                 $::eye::stars($star,cam,crpix2) \
                                 $::eye::visuNo \
                                 $::eye::evt_bufNo \
                                 cam \
                                 $star

               if {$log==1} { gren_info "XnYn= $::eye::stars(1,cam,crpix1) $::eye::stars(1,cam,crpix2)\n"}

               if {$log==1} { 
                 gren_info "Xn= $::eye::stars($star,cam,crpix1)\n"
                 gren_info "Yn= $::eye::stars($star,cam,crpix2)\n"
               }
               if {$::eye::stars($star,cam,success)==0 && $star == 1} {
                  if { [winfo exists .starreflist] } { ::eye::table_ref_stars_load }
               }
               if {$::eye::stars($star,cam,success)==1} {
                  lappend ::eye::list_star_ok $star
                  lappend ::eye::stars_move($star) [list $::eye::stars($star,cam,crpix1) $::eye::stars($star,cam,crpix2)]
               }

            }

            if {$log==1} { 
               gren_info "Nb etoiles de reference : [llength $::eye::list_star] { $::eye::list_star }\n"
               gren_info "Nb etoiles de reference OK : [llength $::eye::list_star_ok] { $::eye::list_star_ok }\n"
            }
            
            if {$log==1} {gren_info "nb star ok = [llength $::eye::list_star_ok]\n"}
            
            # si y a au moins 3 etoiles on fait le WCS
            if {[llength $::eye::list_star_ok] >= 3} {
               if {$log==1} { gren_info "On recalcule le wcs\n" }
               ::eye::fov_wcs
               $::eye::widget(event).feu_calibration configure -image .igreen
               update
            } else {
               gren_erreur "Nb etoiles de calibration mesurées: $cpt\n"
               $::eye::widget(event).feu_calibration configure -image .ired
               update
            }

            # si y a au moins 1 etoile dans la liste qui n est pas dans ok on remesure
            if {[llength $::eye::list_star_ok] >= 3 && [llength $::eye::list_star] != [llength $::eye::list_star_ok]} {
               if {$log==1} {gren_info "on reprends les etoiles qui ont merdé\n"}
               set cpt 0
               foreach star $::eye::list_star {
                  if {!($star in $::eye::list_star_ok)} {
                     gren_erreur "on reprends l etoile $star\n"

                     set err [catch { lassign [buf$::eye::evt_bufNo radec2xy [list $::eye::stars($star,simu,ra) $::eye::stars($star,simu,dec)]] x y } msg ]
                     if {$err} {
                        gren_erreur "$star radec2xy : $err $msg\n"
                        continue
                     }

                     ::eye::fov_select $::eye::hCanvas \
                                       $x \
                                       $y \
                                       $::eye::visuNo \
                                       $::eye::evt_bufNo \
                                       cam \
                                       $star

                     if {$::eye::stars($star,cam,success)==1} {
                        lappend ::eye::list_star_ok $star
                        lappend ::eye::stars_move($star) [list $::eye::stars($star,cam,crpix1) $::eye::stars($star,cam,crpix2)]
                        incr cpt
                     }
                  }
               }

               if {$cpt >0} {
                  # Il y a au moins une etoile qui rerentre dans la liste OK
                  ::eye::fov_wcs
                  $::eye::widget(event).feu_calibration configure -image .igreen
                  update
               }
            }

            #gren_info "crota2 = $::eye::widget(fov,orient) \n" 

            
 
            #gren_info "crota2 = $::eye::widget(fov,orient) \n" 

            # On met a jour la table des etoiles de ref
            if { [winfo exists .starreflist] } { ::eye::table_ref_stars_load }

            if {$who==""} {::eye::fov_simulimage}

         }
         
         "onestar" {

            set radius $::eye::widget(fov,boxradius)
            set box [list [expr { int($::eye::widget(fov,onestar,xw)) - $radius }] [expr { int($::eye::widget(fov,onestar,yw)) - $radius }] \
                          [expr { int($::eye::widget(fov,onestar,xw)) + $radius }] [expr { int($::eye::widget(fov,onestar,yw)) + $radius }]]
            
            #gren_info "xw [expr int($::eye::widget(fov,onestar,xw))] yw [expr int($::eye::widget(fov,onestar,yw))]\n"
            #gren_info "xo [expr int($::eye::widget(fov,onestar,xo))] yo [expr int($::eye::widget(fov,onestar,yo))]\n"
            #gren_info ":: buf$::eye::evt_bufNo fitgauss $box\n"
            
            lassign [buf$::eye::evt_bufNo fitgauss $box] -> ::eye::widget(fov,onestar,xm) -> -> -> ::eye::widget(fov,onestar,ym)

            set distpix [expr sqrt( pow(($::eye::widget(fov,onestar,xm) - $::eye::widget(fov,onestar,xw))*$::eye::fov(cddelt1),2) \
                                  + pow(($::eye::widget(fov,onestar,ym) - $::eye::widget(fov,onestar,yw))*$::eye::fov(cddelt2),2) ) ]

            catch {$::eye::align_onestar_can delete -tag "distancef"}
            $::eye::align_onestar_can create text 10 25 \
                       -text "Diff poles final : [::eye::coord_to_write $distpix]" -tags "distancef" -anchor w \
                       -fill black 


            #set distpix [expr sqrt( pow(($::eye::widget(fov,onestar,xo) - $::eye::widget(fov,onestar,xw))*$::eye::fov(cddelt1),2) \
            #                      + pow(($::eye::widget(fov,onestar,yo) - $::eye::widget(fov,onestar,yw))*$::eye::fov(cddelt2),2) ) ]
            
            ::eye::onestar_move
            
         }
         
         default {
         
         }

      }


      return 0
   }






   proc ::eye::evt_objet { who }  {
     
      set log 0
      set w 2
      set r 3

      if {$log==1} { gren_info "Calcul sur l Objet\n" }
      $::eye::widget(event).feu_objet configure -image .iorange
      
      # Recherche du pole mecanique de la monture
      if {$log==1} {
         gren_info "Recherche du pole mecanique de la monture\n"
         gren_info "Nb etoiles de reference : [llength $::eye::list_star]\n"
         gren_info "Nb etoiles de reference OK : [llength $::eye::list_star_ok]\n"
      }
            
      foreach star $::eye::list_star_ok {
         
         set idm [expr int([llength $::eye::stars_move($star)]/2)]

         lassign [lindex $::eye::stars_move($star)    0] x1 y1
         lassign [lindex $::eye::stars_move($star) $idm] x2 y2
         lassign [lindex $::eye::stars_move($star)  end] x3 y3

         if {$star == 1 && $log==1} { gren_info "$star : $x1 $y1 $x2 $y2 $x3 $y3 \n" }

         if {$star == 1 && $log==1} { 
            gren_info "$star : index : 0 $idm [llength $::eye::stars_move($star)] \n" 
            gren_info "$star : [expr $y3-$y2] [expr $y2-$y1] \n" 
         }

         # Centre 

         # Mediatrice
         set err [catch {
            set a32 [expr   - ($x3-$x2)/($y3-$y2) ]
            set b32 [expr   ($x3*$x3-$x2*$x2+$y3*$y3-$y2*$y2) / 2.0 / ($y3-$y2)]
         } msg ]
         if {$err} {
            gren_erreur "$star : Mediatrice [expr ($y3-$y2)]\n"
            continue
         }

         set err [catch {
            set a21 [expr   - ($x2-$x1)/($y2-$y1) ]
            set b21 [expr   ($x2*$x2-$x1*$x1+$y2*$y2-$y1*$y1) / 2.0 / ($y2-$y1)]
         } msg ]
         if {$err} {
            gren_erreur "$star : Mediatrice [expr ($y2-$y1)]\n"
            continue
         }

         set err [catch {
            set xc [expr  - ( $b21 - $b32 ) / ( $a21 - $a32 ) ]
            set yc [expr  $a32 * $xc + $b32 ]
         } msg ]

         #set err [catch {
         #   set xc [expr   ( ($x3*$x3-$x2*$x2+$y3*$y3-$y2*$y2)/(2.0*($y3-$y2))   \
         #                   -($x2*$x2-$x1*$x1+$y2*$y2-$y1*$y1)/(2.0*($y2-$y1)) ) \
         #                / ( ($x2-$x1)/($y2-$y1) - ($x3-$x2)/($y3-$y2) ) ]
         #   set yc [expr   - ($x2-$x1)/($y2-$y1) * $xc   \
         #                  + ($x2*$x2-$x1*$x1+$y2*$y2-$y1*$y1) / (2.0*($y2-$y1))]
         #} msg ]

         if {$err} {
            if {$log==1} {gren_erreur "$star : centre calcul   expr ($a21 - $a32) $err $msg\n"}
            #gren_erreur "$star : centre calcul [expr ($y3-$y2)] [expr ($y2-$y1)]\n"
            continue
         }
         
         lappend ::eye::lxc $xc
         lappend ::eye::lyc $yc

         if {$log==1} { 
            gren_info "$star : centre : $xc $yc \n"
         }

         set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xc $yc]]} msg]

         if {$err} {
            gren_erreur "$star : centre picture2Canvas $xc $yc $msg $err\n"
            continue
         }

         if {$coord==""} {
            gren_erreur "$star : centre picture2Canvas 2 : $xc $yc $msg $err\n"
            continue
         }

         set xc  [lindex $coord 0]
         set yc  [lindex $coord 1]

         set tag centre_$star
         catch {$::eye::hCanvas delete $tag}
         $::eye::hCanvas create oval [expr int($xc-$r)] [expr int($yc-$r)] \
                       [expr int($xc+$r)] [expr int($yc+$r)] -outline cyan -tag $tag -width $w
         update 

         # Mediatrice
         set err [catch {
            set a [expr   - ($x3-$x1)/($y3-$y1) ]
            set b [expr   ($x3*$x3-$x1*$x1+$y3*$y3-$y1*$y1) / 2.0 / ($y3-$y1)]
         } msg ]

         if {$err} {continue}
            
         if {$log==1} { 
            gren_erreur "$star : mediatrice : y = $a x + $b \n"
         }

         set err [catch {
            
         set xa 1
         set ya [expr int($a * $xa + $b)]
         set xb [lindex [buf$::eye::fov_bufNo getkwd NAXIS1] 1]
         set yb [expr int($a * $xb + $b)]

         set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xa $ya]]} msg]
         set xa  [lindex $coord 0]
         set ya  [lindex $coord 1]
         set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xb $yb]]} msg]
         set xb  [lindex $coord 0]
         set yb  [lindex $coord 1]

         } msg ]

         if {$err} {continue}

         set tag mediatrice_$star
         catch {$::eye::hCanvas delete $tag}

         if {$log==1} {gren_erreur "$star : mediatrice : $xa $ya $xb $yb \n"}
         $::eye::hCanvas create line $xa $ya $xb $yb -fill blue -tag $tag -width 1

         # Arc de cercle 
         set err [catch {

            set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $x1 $y1]]} msg]
            set x1  [lindex $coord 0]
            set y1  [lindex $coord 1]
            set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $x2 $y2]]} msg]
            set x2  [lindex $coord 0]
            set y2  [lindex $coord 1]
            set err [catch {set coord [::confVisu::picture2Canvas $::eye::visuNo [list $x3 $y3]]} msg]
            set x3  [lindex $coord 0]
            set y3  [lindex $coord 1]

         } msg ]

         if {$err} {continue}

         set tag arc_$star
         catch {$::eye::hCanvas delete $tag}

         $::eye::hCanvas create oval [expr int($x1-$r)] [expr int($y1-$r)] \
                       [expr int($x1+$r)] [expr int($y1+$r)] -outline yellow -tag $tag -width $w
         $::eye::hCanvas create oval [expr int($x2-$r)] [expr int($y2-$r)] \
                       [expr int($x2+$r)] [expr int($y2+$r)] -outline yellow -tag $tag -width $w
         $::eye::hCanvas create oval [expr int($x3-$r)] [expr int($y3-$r)] \
                       [expr int($x3+$r)] [expr int($y3+$r)] -outline yellow -tag $tag -width $w

         update

      }
      
      if {[llength $::eye::lxc]>0 && [llength $::eye::lyc]>0} {

         if {$log==1} {gren_erreur "nbv = [llength $::eye::lxc] / [llength $::eye::lyc] \n"}
         set xc [::math::statistics::median $::eye::lxc]
         set yc [::math::statistics::median $::eye::lyc]
         set ::eye::fov(meca,x) $xc
         set ::eye::fov(meca,y) $yc

         set radec [buf$::eye::evt_bufNo xy2radec [list $xc $yc ] ]
         set ::eye::fov(meca,ra)  [lindex $radec 0]
         set ::eye::fov(meca,dec) [lindex $radec 1]

         ::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(meca,ra) $::eye::fov(meca,dec) magenta M
         ::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(meca,ra) $::eye::fov(meca,dec) magenta M

         catch {$::eye::fov_canvas delete cible_C }
         catch {$::eye::hCanvas delete cible_C }
         ::eye::affiche_pole_celeste

         #set xy [buf$::eye::evt_bufNo radec2xy [list $::eye::fov(celeste,ra) $::eye::fov(celeste,dec)]]
         #set ::eye::fov(celeste,x) [lindex $xy 0]
         #set ::eye::fov(celeste,y) [lindex $xy 1]

         #::eye::fov_tools_point_radec $::eye::fov_canvas $::eye::fov_bufNo $::eye::fov_visuNo $::eye::fov(celeste,ra) $::eye::fov(celeste,dec) $::eye::fov(celeste,color) C
         #::eye::fov_tools_point_radec $::eye::hCanvas    $::eye::evt_bufNo $::eye::visuNo     $::eye::fov(celeste,ra) $::eye::fov(celeste,dec) $::eye::fov(celeste,color) C

         update 

      }      
      
      #after 1000
      #$::eye::widget(event).feu_objet configure -image .igreen
      
      return 0
   }
   
   
   
   proc ::eye::evt_telescope {  }  {

      gren_info "Telescope\n"

      
      return 0
   }
