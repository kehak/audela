   #----------------------------------------------------------------------------
   ## Action du bouton de calcul des objets NEWASTER dans les images
   #  @return void
   proc ::bdi_gui_planetes::newast_calcul {  } {
      
      set data [split [$::bdi_gui_planetes::newaster_orbit_entry get 0.0 end] "\n" ]
      gren_info "data = $data\n"
      
      foreach line $data {
         set line [string trim $line]
         set tab [split $line "," ]
         if {[lindex $tab 0] == "linear"} {
            set id_obj [lindex $tab 1]
            set mag    [lindex $tab 2]
            set param  [lindex $tab 8]
            lassign [lindex $param 0] ra_a ra_b dec_a dec_b
            #gren_info "a b c d = $ra_a $ra_b $dec_a $dec_b\n"
            ::bdi_gui_planetes::newast_calcul_by_obj $id_obj $mag $ra_a $ra_b $dec_a $dec_b
         }
      }
      return
   }

   proc ::bdi_gui_planetes::newast_calcul_by_obj { id_obj mag ra_a ra_b dec_a dec_b } {
      gren_info "id_obj = $id_obj $mag\n"
      gren_info "ra_a ra_b dec_a dec_b = $ra_a $ra_b $dec_a $dec_b\n"

      return
   }

   #----------------------------------------------------------------------------
   ## Action du bouton de visualisation des objets NEWASTER dans les images
   #  @return void
   proc ::bdi_gui_planetes::newast_voir {  } {

      
      global audace
      global bddconf

      # Effacement des marques dans la Visu
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_newaster 

      if { [$::bdi_gui_planetes::widget(newast,voir) cget -relief] == "raised"} {

         # bouton NON selectionne
         $::bdi_gui_planetes::widget(newast,voir) configure -relief "sunken"


         set data [split [$::bdi_gui_planetes::newaster_orbit_entry get 0.0 end] "\n" ]
         gren_info "data = $data\n"

         foreach line $data {
            set line [string trim $line]
            set tab [split $line "," ]
            if {[lindex $tab 0] == "linear"} {
               set id_obj [lindex $tab 1]
               set mag    [lindex $tab 2]
               set param  [lindex $tab 8]
               lassign [lindex $param 0] ra_a ra_b dec_a dec_b
               #gren_info "a b c d = $ra_a $ra_b $dec_a $dec_b\n"
               ::bdi_gui_planetes::newast_voir_by_obj $id_obj $mag $ra_a $ra_b $dec_a $dec_b
            }
         }

      } else {
      
         # bouton Selectionne
         $::bdi_gui_planetes::widget(newast,voir) configure -relief "raised"
      
      }

      return
   }


   proc ::bdi_gui_planetes::newast_voir_by_obj { id_obj mag ra_a ra_b dec_a dec_b } {

      if {![info exists ::bdi_gui_planetes::buffer_list(frame2buf,$::bdi_gui_planetes::scrollbar)]} {return}
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$::bdi_gui_planetes::scrollbar)

      gren_info "id_obj = $id_obj $mag\n"
      gren_info "ra_a ra_b dec_a dec_b = $ra_a $ra_b $dec_a $dec_b\n"
      
      # Premiere image
      set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) 0]
      set jdmp    $::bdi_gui_planetes::obs(index,$dateobs,jdmp)
      set ra      [ expr $ra_a + $ra_b * $jdmp ]
      set dec     [ expr $dec_a + $dec_b * $jdmp ]
      set img_xy [ buf$bufNo radec2xy [ list $ra $dec ] ]
      lassign $img_xy xi yi

      # Derniere image
      set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) end]
      set jdmp    $::bdi_gui_planetes::obs(index,$dateobs,jdmp)
      set ra      [ expr $ra_a + $ra_b * $jdmp ]
      set dec     [ expr $dec_a + $dec_b * $jdmp ]
      set img_xy [ buf$bufNo radec2xy [ list $ra $dec ] ]
      lassign $img_xy xf yf
      
      set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
      lassign $can_xy cxi cyi
      set can_xy [ ::audace::picture2Canvas [list $xf $yf] ]
      lassign $can_xy cxf cyf

      set color yellow
      set width 2
      $::audace(hCanvas) create line $cxi $cyi $cxf $cyf -fill $color -tags planetes_newaster -width $width
      $::audace(hCanvas) create text [expr $cxi - 1] [expr $cyi -10] -text $id_obj -justify center -fill $color -tags planetes_newaster

      return
   }

   #----------------------------------------------------------------------------
   ## Lors d un clic dans la table skybot
   #  Affiche l objet dans l image
   #  @return void
   proc ::bdi_gui_planetes::cmdButton1Click_newast_table { w args } {
      
      # TODO
      return
      
      global audace
      global bddconf

      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot_solo
      
      set curselection [$::bdi_gui_planetes::skybot_table curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}

      set aster [lindex [$::bdi_gui_planetes::skybot_table get [lindex $curselection 0] ] 0]
      #gren_info "aster_selected = $aster\n"
      
      # initialisation du tableau de donnees skybot
      array set tab $::bdi_gui_planetes::skybot_results
      
      set idframe $::bdi_gui_planetes::scrollbar
      #gren_info "scrollbar = $idframe\n"

      if { ! [info exists ::bdi_gui_planetes::buffer_list(frame2buf,$idframe)]} {
         return
      }
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)

      #gren_info "bufNo = $bufNo\n"
      set dateiso [lindex [buf$bufNo getkwd "DATE-OBS"] 1]
      #gren_info "dateiso = $dateiso\n"
      
      set idimg [::bdi_tools_planetes::get_idimg $dateiso]
      #gren_info "idimg = $idimg\n"
      set color  yellow
      set width  2
      set radius 10
      
      set err [ catch {::bdi_gui_planetes::get_dateiso_from_obs $dateiso} dateiso ]
      if {$err} {
         gren_info "Erreur de date : $msg \n"
         return
      }
      
      set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateiso) $tab($aster,dec,$dateiso) ] ]
      lassign $img_xy x y
      set xi [expr $x - $radius]
      set yi [expr $y - $radius]
      set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
      lassign $can_xy cxi cyi
      set xs [expr $x + $radius]
      set ys [expr $y + $radius]
      set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
      lassign $can_xy cxs cys
      $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags planetes_skybot_solo -width $width
      
      return
   }

