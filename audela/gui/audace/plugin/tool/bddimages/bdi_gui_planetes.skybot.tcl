

# SKYBOT_-_2012_BT18
   #----------------------------------------------------------------------------
   ## Action du bouton de visualisation des objets Skybot dans les images
   #  @return void
   proc ::bdi_gui_planetes::skybot_voir {  } {
      
      global audace
      global bddconf

      # Effacement des marques dans la Visu
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot_solo

      if { [$::bdi_gui_planetes::widget(skybot,voir) cget -relief] == "raised"} {
      
         # bouton NON selectionne
         $::bdi_gui_planetes::widget(skybot,voir) configure -relief "sunken"
         
         # selection du buffer
         set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$::bdi_gui_planetes::scrollbar)

         # initialisation du tableau de donnees skybot
         array set tab $::bdi_gui_planetes::skybot_results

         # initialisation
         set color_ini red
         set color_end "LawnGreen"
         set long  10
         set decal 5
         set radius  10
         set width   2
         set nbi $::bdi_gui_planetes::widget(nbimages)

         # on affiche des ronds pour les asteroides qui n ont pas de positions finales
if {0} {         
         foreach aster $tab(index,init) {
            set pos [lsearch $tab(index,end) $aster]
            if {$pos == -1} {
               set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) 0]
               set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
               set x [lindex $img_xy 0]
               set y [lindex $img_xy 1]
               set xi [expr $x - $radius]
               set yi [expr $y - $radius]
               set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
               set cxi [lindex $can_xy 0]
               set cyi [lindex $can_xy 1]
               set xs [expr $x + $radius]
               set ys [expr $y + $radius]
               set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
               set cxs [lindex $can_xy 0]
               set cys [lindex $can_xy 1]
               $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color_ini -tags planetes_skybot -width $width
            }
         }

         # on affiche des ronds pour les asteroides qui n ont pas de positions initiales
         foreach aster $tab(index,end) {
            set pos [lsearch $tab(index,init) $aster]
            if {$pos == -1} {
               set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) end]
               set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
               set x [lindex $img_xy 0]
               set y [lindex $img_xy 1]
               set xi [expr $x - $radius]
               set yi [expr $y - $radius]
               set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
               set cxi [lindex $can_xy 0]
               set cyi [lindex $can_xy 1]
               set xs [expr $x + $radius]
               set ys [expr $y + $radius]
               set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
               set cxs [lindex $can_xy 0]
               set cys [lindex $can_xy 1]
               $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color_end -tags planetes_skybot -width $width
            }
         }
}
         # Affichage des asteroides presents dans tout le film
         foreach aster $tab(index,init) {
            set pos [lsearch $tab(index,end) $aster]
            if {$pos == -1} {continue}

            set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) 0]
            set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
            lassign $img_xy xi yi
            set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) end]
            set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
            lassign $img_xy xf yf

            # vecteur deplacement
            set un [expr sqrt(pow(($xf-$xi),2)+pow(($yf-$yi),2))]
            set ux [expr ($xf-$xi)/$un]
            set uy [expr ($yf-$yi)/$un]

            # Marque position initiale
            set x0 [expr $xi - $ux * $long]
            set y0 [expr $yi - $uy * $long]
            set x1 [expr $xi - $ux * $decal]
            set y1 [expr $yi - $uy * $decal]

            # coordonnees canvas position initiale
            set can_xy [ ::audace::picture2Canvas [list $x0 $y0] ]
            lassign $can_xy cxi cyi
            set can_xy [ ::audace::picture2Canvas [list $x1 $y1] ]
            lassign $can_xy cxf cyf
            $audace(hCanvas) create line $cxi $cyi $cxf $cyf -fill $color_ini -tags planetes_skybot -width $width

            # Marque position initiale
            set x0 [expr $xf + $ux * $long]
            set y0 [expr $yf + $uy * $long]
            set x1 [expr $xf + $ux * $decal]
            set y1 [expr $yf + $uy * $decal]

            # coordonnees canvas position initiale
            set can_xy [ ::audace::picture2Canvas [list $x0 $y0] ]
            lassign $can_xy cxi cyi
            set can_xy [ ::audace::picture2Canvas [list $x1 $y1] ]
            lassign $can_xy cxf cyf
            $audace(hCanvas) create line $cxi $cyi $cxf $cyf -fill $color_end -tags planetes_skybot -width $width

         }
      
      } else {

         # bouton Selectionne
         $::bdi_gui_planetes::widget(skybot,voir) configure -relief "raised"
         
      }
   
      return
   }









   proc ::bdi_gui_planetes::skybot_charge_webservice_no_thread {  } {


      if { ! [info exists ::bdi_gui_planetes::widget(type_image,selected)]} {
         tk_messageBox -message  "Vous devez centrer les images -> Step 2" -type ok
         return
      }

      if { $::bdi_gui_planetes::widget(type_image,selected) != "centre"} {
         tk_messageBox -message  "Vous devez centrer les images -> Step 2" -type ok
         return
      }

      set tt0 [clock clicks -milliseconds]
      array set obs [array get ::bdi_gui_planetes::obs]
      
      $::bdi_gui_planetes::skybot_table delete 0 end

      # Calcul date 1
      lassign $obs(first) dateiso ra dec jd1
      gren_info "CMD1  = get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)\n"
      set stt0 [clock clicks -milliseconds]
      set err [ catch {get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)} skybot1 ]
      if {$err} {
         gren_info "Erreur appel skybot \n"
         return
      }
      set t [format "%4.1f sec" [expr ([clock clicks -milliseconds]-$stt0)/1000.0]]
      gren_info "Duree requete SkyBot : $t\n"

      # Calcul date 2
      lassign $obs(last) dateiso ra dec jd2
      gren_info "CMD2  = get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)\n"
      set stt0 [clock clicks -milliseconds]
      set err [ catch {get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)} skybot2 ]
      if {$err} {
         gren_info "Erreur appel skybot \n"
         return
      }
      set t [format "%4.1f sec" [expr ([clock clicks -milliseconds]-$stt0)/1000.0]]
      gren_info "Duree requete SkyBot : $t\n"

      # On recupere la liste des asteroides et leur position a la premiere date
      array unset tab
      set fields  [lindex $skybot1 0]
      set sources [lindex $skybot1 1]
      foreach s $sources { 
         set cata                [lindex $s 0]
         set aster               [::manage_source::naming $s SKYBOT]
         set cm                  [lindex $cata 1]
         set id                  [lindex $cata {2 0}]
         set name                [lindex $cata {2 1}]
         lappend tab(index,init) $aster
         set tab($aster,jd,1)    $jd1
         set tab($aster,ra,1)    [lindex $cm 0]
         set tab($aster,dec,1)   [lindex $cm 1]
         set tab($aster,poserr)  [lindex $cm 2]
         set tab($aster,mag)     [lindex $cm 3]
         set tab($aster,classe)  [lindex $cata {2 4}]
         set tab($aster,id)      [lindex $cata {2 0}]
         set tab($aster,name)    [lindex $cata {2 1}]
         set tab($aster,poserr)  [format "%0.3f" $tab($aster,poserr)]
      }
      gren_info "Nombre d objet Skybot recuperes a la date initiale : [llength $sources]\n"

      # On recupere la liste des asteroides et leur position a la derniere date
      set fields  [lindex $skybot2 0]
      set sources [lindex $skybot2 1]
      foreach s $sources { 
         set cata                 [lindex $s 0]
         set aster                [::manage_source::naming $s SKYBOT]
         set cm                   [lindex $cata 1]
         set id                   [lindex $cata {2 0}]
         set name                 [lindex $cata {2 1}]
         lappend tab(index,end)   $aster
         set tab($aster,jd,end)   $jd2
         set tab($aster,ra,end)   [lindex $cm 0]
         set tab($aster,dec,end)  [lindex $cm 1]
      }
      gren_info "Nombre d objet Skybot recuperes a la date finale : [llength $sources]\n"

      # Selection des objets qui sont visibles sur la premiere et derniere image
      set tab(index,visible) ""
      foreach aster $tab(index,init) {
         set pos [lsearch $tab(index,end) $aster]
         if {$pos == -1} {continue}
         lappend tab(index,visible) $aster
      }
      gren_info "Nombre d objet visibles dans toutes les images : [llength $tab(index,visible)]\n"

      # Selection de tous les objets visibles sur la premiere et derniere image
      set tab(index,complete) ""
      foreach aster $tab(index,init) {
         lappend tab(index,complete) $aster
      }
      foreach aster $tab(index,end) {
         lappend tab(index,complete) $aster
      }
      set tab(index,complete) [lsort -uniq -ascii $tab(index,complete)]
      gren_info "Nombre d objet au total : [llength $tab(index,complete)]\n"

      gren_info "Interpolation des positions des asteroides  :\n"
      foreach dateobs $obs(index,dateobs) {
         #gren_info "Thread:: dateobs = $dateobs"
         set jdmp $obs(index,$dateobs,jdmp)
         #gren_info "Thread::    jdmp = $jdmp"
         foreach aster $tab(index,visible) {
            #gren_info "Thread::       aster = $aster"
            set ra  [expr ($jdmp - $tab($aster,jd,1)) / ( $tab($aster,jd,end) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,ra,end) - $tab($aster,ra,1) ) + $tab($aster,ra,1) ]
            set dec [expr ($jdmp - $tab($aster,jd,1)) / ( $tab($aster,jd,end) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,dec,end) - $tab($aster,dec,1) ) + $tab($aster,dec,1) ]
            set tab($aster,ra,$dateobs)  $ra
            set tab($aster,dec,$dateobs) $dec
         }
      }


      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo   $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      set naxis1 $::bdi_gui_planetes::obs(naxis1)
      set naxis2 $::bdi_gui_planetes::obs(naxis2)

      foreach aster $tab(index,visible) {
         set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) 0]
         set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
         lassign $img_xy x y
         if {$x < 0} {continue}
         if {$y < 0} {continue}
         if {$x > $naxis1} {continue}
         if {$y > $naxis2} {continue}
        
         set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) end]
         set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
         lassign $img_xy x y
         if {$x < 0} {continue}
         if {$y < 0} {continue}
         if {$x > $naxis1} {continue}
         if {$y > $naxis2} {continue}
         $::bdi_gui_planetes::skybot_table insert end [list $aster $tab($aster,id) $tab($aster,name) $tab($aster,classe) $tab($aster,mag) $tab($aster,poserr)]
      }

      set ::bdi_gui_planetes::skybot_results [array get tab]
      gren_info "Skybot Charge no_thread : Fin"
      return

   }   




   #----------------------------------------------------------------------------
   ## Appel a Skybot, et Calcul des parametres en vue de leur affichage dans les images
   #  Partie 1: appel au webservice
   #  @return void
   proc ::bdi_gui_planetes::skybot_charge_webservice_no_thread_obsolete {  } {


      $::bdi_gui_planetes::skybot_table delete 0 end

      if { $::bdi_gui_planetes::widget(type_image,selected) != "centre"} {
         tk_messageBox -message  "Vous devez centrer les images -> Step 2" -type ok
         return
      }

      # Premiere image
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,1)
      set dateiso [string trim [lindex [ buf$bufNo getkwd DATE-OBS] 1] ]
      set idimg [::bdi_tools_planetes::get_idimg $dateiso]
      set img [lindex $::bdi_gui_planetes::imglist $idimg]
      set tabkey [::bddimages_liste::lget $img "tabkey"]
      set date_obs [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
      set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set ra       [lindex [::bddimages_liste::lget $tabkey RA] 1]
      set dec      [lindex [::bddimages_liste::lget $tabkey DEC] 1]
      set iau_code [lindex [::bddimages_liste::lget $tabkey IAU_CODE] 1]
      set naxis1   [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2   [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x  [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
      set scale_y  [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
      
      gren_info "date_obs = $date_obs\n"
      gren_info "exposure = $exposure\n"
      
      set jd       [expr [mc_date2jd $date_obs] + $exposure / 86400.0 / 2.0]
      set dateiso  [mc_date2iso8601 $jd ]
      set mscale   [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
      set radius   [format "%0.0f" [expr [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale] * 2.0 * 60.0] ]

      gren_info "date_obs  = $date_obs\n"
      gren_info "dateiso   = $dateiso\n"
      gren_info "ra        = [mc_angle2hms $ra 360 zero 1 auto string]\n"
      gren_info "dec       = [mc_angle2dms $dec 90 zero 1 + string]\n"
      gren_info "radius    = $radius arcmin\n"
      gren_info "iau_code  = $iau_code\n"
      gren_info "naxis1    = $naxis1\n"
      gren_info "naxis2    = $naxis2\n"

      gren_info "CMD  = get_skybot $dateiso $ra $dec $radius $iau_code\n"

      set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} skybot ]
      if {$err} {
         gren_info "Erreur appel skybot \n"
         return
      }

      # On recupere la liste des asteroides et leur position a la premiere date
      array unset tab
      set fields  [lindex $skybot 0]
      #gren_info "$fields\n" ; return
      set sources [lindex $skybot 1]
      foreach s $sources { 
         set cata                [lindex $s 0]
         set aster               [::manage_source::naming $s SKYBOT]
         set cm                  [lindex $cata 1]
         set id                  [lindex $cata {2 0}]
         set name                [lindex $cata {2 1}]
         lappend tab(index,init) $aster
         set tab($aster,jd,1)    $jd
         set tab($aster,ra,1)    [lindex $cm 0]
         set tab($aster,dec,1)   [lindex $cm 1]
         set tab($aster,poserr)  [lindex $cm 2]
         set tab($aster,mag)     [lindex $cm 3]
         set tab($aster,classe)  [lindex $cata {2 4}]
         set tab($aster,id)      [lindex $cata {2 0}]
         set tab($aster,name)    [lindex $cata {2 1}]
         set tab($aster,poserr)  [format "%0.3f" $tab($aster,poserr)]
      }
      gren_info "Nombre d objet Skybot recuperes a la date initiale : [llength $sources]\n"
      
      # On recupere leur position a la derniere date
      set nbi $::bdi_gui_planetes::widget(nbimages)
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$nbi)
      set dateiso [string trim [lindex [ buf$bufNo getkwd DATE-OBS] 1] ]
      set idimg [::bdi_tools_planetes::get_idimg $dateiso]
      set img [lindex $::bdi_gui_planetes::imglist $idimg]
      set tabkey [::bddimages_liste::lget $img "tabkey"]
      set date_obs [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
      set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set jd       [expr [mc_date2jd $date_obs] + $exposure / 86400.0 / 2.0]
      set dateiso  [mc_date2iso8601 $jd ]
      set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} skybot ]
      if {$err} {
         gren_info "Erreur appel skybot \n"
         return
      }
      set fields  [lindex $skybot 0]
      set sources [lindex $skybot 1]
      foreach s $sources { 
         set cata                 [lindex $s 0]
         set aster                [::manage_source::naming $s SKYBOT]
         set cm                   [lindex $cata 1]
         set id                   [lindex $cata {2 0}]
         set name                 [lindex $cata {2 1}]
         lappend tab(index,end)   $aster
         set tab($aster,jd,$nbi)  $jd
         set tab($aster,ra,$nbi)  [lindex $cm 0]
         set tab($aster,dec,$nbi) [lindex $cm 1]
      }
      gren_info "Nombre d objet Skybot recuperes a la date finale : [llength $sources]\n"

      # Selection des objets qui sont visibles sur la premiere et derniere image
      set tab(index,complete) ""
      foreach aster $tab(index,init) {
         set pos [lsearch $tab(index,end) $aster]
         if {$pos == -1} {continue}
         lappend tab(index,complete) $aster
      }


       # insertion dans la table des asteroides present dans toutes les images
      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo   $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)

      foreach aster $tab(index,complete) {

         set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,1) $tab($aster,dec,1) ] ]
         lassign $img_xy x y
         if {$x < 0} {continue}
         if {$y < 0} {continue}
         if {$x > $naxis1} {continue}
         if {$y > $naxis2} {continue}
         
         set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$nbi) $tab($aster,dec,$nbi) ] ]
         lassign $img_xy x y
         if {$x < 0} {continue}
         if {$y < 0} {continue}
         if {$x > $naxis1} {continue}
         if {$y > $naxis2} {continue}

         $::bdi_gui_planetes::skybot_table insert end [list $aster $tab($aster,id) $tab($aster,name) $tab($aster,classe) $tab($aster,mag) $tab($aster,poserr)]
      }

      # insertion dans la table des asteroides present partiellement dans les images
      gren_erreur "TODO: On ne s occupe pas des asteroides qui sont presents"
      gren_erreur " sur la premiere image et absent sur la dernier, et inversement\n"
      if {0} {
         foreach aster $tab(index,init) {
            set pos [lsearch $tab(index,end) $aster]
            if {$pos == -1} {
               $::bdi_gui_planetes::skybot_table insert end [list $aster $tab($aster,id) $tab($aster,name) $tab($aster,classe) $tab($aster,mag) $tab($aster,poserr)]
            }
         }
         foreach aster $tab(index,end) {
            set pos [lsearch $tab(index,init) $aster]
            if {$pos == -1} {
               $::bdi_gui_planetes::skybot_table insert end [list $aster $tab($aster,id) $tab($aster,name) $tab($aster,classe) $tab($aster,mag) $tab($aster,poserr)]
            }
         }
      }


      # interpolation des positions des asteroides dans les images
      gren_info "interpolation des positions des asteroides : \n"
      
      for {set i 1} {$i <= $nbi} {incr i} {
         set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$i)
         set dateiso [string trim [lindex [ buf$bufNo getkwd DATE-OBS] 1] ]
         set idimg [::bdi_tools_planetes::get_idimg $dateiso]
         set img [lindex $::bdi_gui_planetes::imglist $idimg]
         set tabkey   [::bddimages_liste::lget $img "tabkey"]
         set date_obs [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
         set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
         set jd       [expr [mc_date2jd $date_obs] + $exposure / 86400.0 / 2.0]
         
         foreach aster $tab(index,complete) {
            # on interpole les coordonnees de facon lineaire
            set ra  [expr ($jd - $tab($aster,jd,1)) / ( $tab($aster,jd,$nbi) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,ra,$nbi) - $tab($aster,ra,1) ) + $tab($aster,ra,1) ]
            set dec [expr ($jd - $tab($aster,jd,1)) / ( $tab($aster,jd,$nbi) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,dec,$nbi) - $tab($aster,dec,1) ) + $tab($aster,dec,1) ]

            if {$idimg==1 || $idimg==$nbi} {
               #gren_info "verif interpol $aster: $idimg => [expr $ra - $tab($aster,ra,$idimg)] [expr $dec - $tab($aster,dec,$idimg)]\n"
            } else {
               set tab($aster,ra,$idimg)  $ra
               set tab($aster,dec,$idimg) $dec
               #gren_info "interpol: $idimg => [expr $ra - $tab($aster,ra,$idimg)] [expr $dec - $tab($aster,dec,$idimg)]\n"
            }

         }

      }
      
      # sauvegarde de la structure de donnees SkyBot
      set ::bdi_gui_planetes::skybot_results [array get tab]

      gren_info "Fin\n"
      return
   }





   proc ::bdi_gui_planetes::get_dateiso_from_obs { dateisoi } {
       set jdi  [mc_date2jd $dateisoi]
      foreach dateiso $::bdi_gui_planetes::obs(index,dateobs) {
         set jd  [mc_date2jd $dateiso]
         set diff [expr abs($jd-$jdi)]
         if {$diff<0.000001} {
            return $dateiso
         }
      }
      return -code 1 "no date"
   }
   





   #----------------------------------------------------------------------------
   ## Lors d un clic dans la table skybot
   #  Affiche l objet dans l image
   #  @return void
   proc ::bdi_gui_planetes::cmdButton1Click_skybot_table { w args } {
      
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















#  ::bddimages::ressource  ; ::bdi_gui_planetes::skybot_charge

   proc ::bdi_gui_planetes::skybot_charge {  } {

      global bddconf
 
      set thread 0
      
      gren_info "Actual buf list : [lsort -integer [::buf::list] ]\n"

      if { [$::bdi_gui_planetes::widget(skybot,charge) cget -relief] == "raised"} {
   
         # Gestion des boutons
         #$::bdi_gui_planetes::widget(skybot,charge) configure -relief "sunken" -state disabled
         $::bdi_gui_planetes::widget(skybot,voir) configure -relief "raised"

         # Effacement des marques dans la Visu
         $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot
         $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot_solo

         # Appel au Webservice
         if {$thread} {
             gren_info "Lancement Skybot dans un Thread\n"
            ::bdi_gui_planetes::skybot_charge_webservice_thread
         } else {
             gren_info "Lancement Skybot no Thread\n"
            ::bdi_gui_planetes::skybot_charge_webservice_no_thread
         }

         # Visualisation des resultats
         $::bdi_gui_planetes::widget(skybot,voir) configure -relief "raised"
         #::bdi_gui_planetes::skybot_voir


         # Activation du bouton
         $::bdi_gui_planetes::widget(skybot,charge) configure -relief "raised" -state active
      }
      
      gren_info "New buf list : [lsort -integer [::buf::list] ]\n"
      return
   }


















   proc ::bdi_gui_planetes::skybot_charge_webservice_thread {  } {

      if { [info exists ::bdi_tools_planetes::skybot_threadName]} {
         if {$::bdi_tools_planetes::skybot_threadName != ""} {
            tk_messageBox -message  "Recherche Skybot deja en cours d execution, attendre l arret" -type ok
            return
         }
      }

      if {[::bdi_tools_planetes::skybot_charge_webservice_thread_exist]==1} {
          gren_info "Fermeture du thread existant.\n"
         ::bdi_tools_planetes::skybot_charge_webservice_thread_close
      }

      
      gren_info "Creation du thread\n"
      set ::bdi_tools_planetes::skybot_threadName [::bdi_tools_thread::create]
      
      gren_info "Intialisation du thread\n"
      ::bdi_gui_planetes::skybot_charge_webservice_thread_init

      gren_info "Lancement du thread\n"
      ::thread::send -async  $::bdi_tools_planetes::skybot_threadName "::bdi_tools_planetes::skybot_charge_webservice_on_thread"
      
      return
   }












#::bddimages::ressource ; ::bdi_gui_planetes::skybot_charge_webservice_thread_init
   proc ::bdi_gui_planetes::skybot_charge_webservice_thread_init {  } {

      tsv::set application result  0
      tsv::set application duree   0
      tsv::set application dispo   1
      tsv::set application lobs [array get ::bdi_gui_planetes::obs]

      # Effacement de la tablelist 
      $::bdi_gui_planetes::skybot_table delete 0 end

      return
   }










   proc ::bdi_gui_planetes::skybot_charge_webservice_result {  } {

      if { ! [info exists ::bdi_gui_planetes::widget(type_image,selected)]} {
         tk_messageBox -message  "Vous devez centrer les images -> Step 2" -type ok
         return
      }

      if { $::bdi_gui_planetes::widget(type_image,selected) != "centre"} {
         tk_messageBox -message  "Vous devez centrer les images -> Step 2" -type ok
         return
      }

      $::bdi_gui_planetes::skybot_table delete 0 end

      tsv::get application dispo dispo
      if {$dispo!=1} {
         tk_messageBox -message  "Calcul en cours d execution" -type ok
         return
      }

      tsv::get application ltab ltab
      set ::bdi_gui_planetes::skybot_results $ltab
      array set tab $ltab

      # insertion dans la table des asteroides present dans toutes les images
      
      
      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo   $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      set naxis1 $::bdi_gui_planetes::obs(naxis1)
      set naxis2 $::bdi_gui_planetes::obs(naxis2)

      foreach aster $tab(index,visible) {
         set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) 0]
         set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
         lassign $img_xy x y
         if {$x < 0} {continue}
         if {$y < 0} {continue}
         if {$x > $naxis1} {continue}
         if {$y > $naxis2} {continue}
        
         set dateobs [lindex $::bdi_gui_planetes::obs(index,dateobs) end]
         set img_xy [ buf$bufNo radec2xy [ list $tab($aster,ra,$dateobs) $tab($aster,dec,$dateobs) ] ]
         lassign $img_xy x y
         if {$x < 0} {continue}
         if {$y < 0} {continue}
         if {$x > $naxis1} {continue}
         if {$y > $naxis2} {continue}
         $::bdi_gui_planetes::skybot_table insert end [list $aster $tab($aster,id) $tab($aster,name) $tab($aster,classe) $tab($aster,mag) $tab($aster,poserr)]
      }


      return
   }





