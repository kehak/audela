







   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::mesure_create {  } {

      global bddconf
      gren_info "Creation Rapport Mesure\n"


      set filecsv [file join $bddconf(dirtmp) "mesure.csv"]
      if {![file exists $filecsv]} {
         set handler [open $filecsv "w"]
         puts $handler "#id, dateiso_mp, jd_mp, ra, dec, mag"
      } else {
         set handler [open $filecsv "a+"]
      }

      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {

            set dateiso_mp $::bdi_gui_planetes::tab_mesure_data($id,dateiso_mp)
            set jd_mp      $::bdi_gui_planetes::tab_mesure_data($id,jd_mp)
            set ra         $::bdi_gui_planetes::tab_mesure_data($id,ra) 
            set dec        $::bdi_gui_planetes::tab_mesure_data($id,dec)
            set mag        $::bdi_gui_planetes::tab_mesure_data($id,mag)
            set filtre     $::bdi_gui_planetes::tab_mesure_data($id,filtre)
            puts $handler [format "%3s, %23s, %18s, %12s, %12s, %12s" $id $dateiso_mp $jd_mp $ra $dec $mag $filtre]

         }
      }
      close $handler

   }



   # set jd_mp [::bdi_gui_planetes::date_to_jd_mp $dateiso $exposure]
   proc ::bdi_gui_planetes::date_to_jd_mp { dateiso exposure } {
      set jd_mp [mc_date2jd $dateiso]
      set jd_mp [expr $jd_mp + $exposure / 172800.0]
      return $jd_mp
   }


   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::keep { } {

      global bddconf
      global private

      set visuNo  $bddconf(visuno)
      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo   $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)

      gren_info "Mesure\n"
      set base [ ::confVisu::getBase $visuNo ]
      gren_info "base = $base\n"
      set frm "$base.psfimcce$visuNo"
      gren_info "frm = $frm\n"
      if {! [ winfo exists $frm ]} {
         tk_messageBox -message "Il faut lancer PsfToolBox" -type ok
         return
      }

      gren_info "Mesure\n"

      set xsm  $private(psf_toolbox,$visuNo,psf,xsm)
      set ysm  $private(psf_toolbox,$visuNo,psf,ysm)
      set flux $private(psf_toolbox,$visuNo,psf,flux)
      gren_info "X,Y = $xsm $ysm\n"
      set a [buf$bufNo xy2radec [list $xsm $ysm]]
      set ra  [lindex $a 0]
      set dec [lindex $a 1]
      gren_info "ra,dec = $ra $dec\n"

      gren_info "Star Ref = $::bdi_gui_planetes::widget(starref_usecata,manuel,star,name)\n"

      #::bdi_gui_planetes::widget(starref_usecata,manuel,star,ra) 
      #::bdi_gui_planetes::widget(starref_usecata,manuel,star,dec)
      #::bdi_gui_planetes::widget(starref_usecata,manuel,star,mag)   

      ::bdi_gui_planetes::charge_cata

      set ids [::manage_source::name2ids $::bdi_gui_planetes::widget(starref_usecata,manuel,star,name) ::tools_cata::current_listsources]
      set s [lindex $::tools_cata::current_listsources [list 1 $ids]]
      set name [::manage_source::namincata $s]
      gren_info "Star Ref in cata = $name \n"
      set othf    [::bdi_tools_psf::get_astroid_othf_from_source $s]
      set fluxref [::bdi_tools_psf::get_val othf flux]
      set magref  [::bdi_tools_psf::get_val othf mag]
      ::bdi_tools_psf::gren_astroid othf

      set mag [format "%0.2f" [expr $magref -2.5 * log10(1.0 * $flux / $fluxref) ] ]

      set dateiso  [lindex [buf$bufNo getkwd "DATE-OBS"] 1]
      set exposure [lindex [buf$bufNo getkwd "EXPOSURE"] 1]
      set filtre   [lindex [buf$bufNo getkwd "FILTER"] 1]

      set jd         [mc_date2jd $dateiso]
      set jd_mp      [::bdi_gui_planetes::date_to_jd_mp $dateiso $exposure]
      set dateiso_mp [ mc_date2iso8601 $jd_mp]

      set ::bdi_gui_planetes::tab_mesure_index($idframe)           1
      set ::bdi_gui_planetes::tab_mesure_data($idframe,dateiso)    $dateiso
      set ::bdi_gui_planetes::tab_mesure_data($idframe,jd)         $jd
      set ::bdi_gui_planetes::tab_mesure_data($idframe,dateiso_mp) $dateiso_mp
      set ::bdi_gui_planetes::tab_mesure_data($idframe,jd_mp)      $jd_mp
      set ::bdi_gui_planetes::tab_mesure_data($idframe,xsm)        $xsm
      set ::bdi_gui_planetes::tab_mesure_data($idframe,ysm)        $ysm
      set ::bdi_gui_planetes::tab_mesure_data($idframe,ra)         $ra
      set ::bdi_gui_planetes::tab_mesure_data($idframe,dec)        $dec
      set ::bdi_gui_planetes::tab_mesure_data($idframe,mag)        $mag
      set ::bdi_gui_planetes::tab_mesure_data($idframe,filtre)     $filtre
      
      # Affiche la table et pointe sur l entree qui vient d etre mesuree
      ::bdi_gui_planetes::view_table_mesure

      # Visualise l entree qui vient d etre mesuree
      set nbmesure [$::bdi_gui_planetes::data_source size]
      for {set i 0} {$i < $nbmesure} {incr i} {
         set date [lindex [$::bdi_gui_planetes::data_source get $i ] 1]
         if {$date == $dateiso} {break}
      }
      $::bdi_gui_planetes::data_source selection clear 0 end
      $::bdi_gui_planetes::data_source selection set $i $i
      $::bdi_gui_planetes::data_source see $i
      
      # Nettoyage de la visu
      ::audace::psf_clean_mark $visuNo

      return 
   }






   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::delete_table_mesure { } {
      $::bdi_gui_planetes::data_source delete 0 end
      catch { unset ::bdi_gui_planetes::tab_mesure_index}
      catch { unset ::bdi_gui_planetes::tab_mesure_data}
   }







   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::delete_table_mesure_sel { } {

      gren_info "Supprime selection"
      foreach select [$::bdi_gui_planetes::data_source curselection] {
         set id [lindex [$::bdi_gui_planetes::data_source get $select] 0]
         unset ::bdi_gui_planetes::tab_mesure_index($id)
      }
      ::bdi_gui_planetes::view_table_mesure
   }






   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::view_table_mesure { } {

      $::bdi_gui_planetes::data_source delete 0 end
      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {
            $::bdi_gui_planetes::data_source insert end [list $id \
                                                              $::bdi_gui_planetes::tab_mesure_data($id,dateiso_mp) \
                                                              [mc_angle2hms $::bdi_gui_planetes::tab_mesure_data($id,ra) 360 zero 1 auto string] \
                                                              [mc_angle2dms $::bdi_gui_planetes::tab_mesure_data($id,dec) 90 zero 1 + string] \
                                                              $::bdi_gui_planetes::tab_mesure_data($id,mag) \
                                                              $::bdi_gui_planetes::tab_mesure_data($id,filtre) \
                                                        ]
         }

      }

   }




   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::bind_mesure {  } {
      
      global bddconf

      set err [ catch {::audace::refreshPSF $bddconf(visuno) } msg ]
      if {$err} {
         gren_erreur "$msg\n"
         tk_messageBox -message  "PsfToolBox n est pas lance ? (erreur dans la console)" -type ok
         
      }
   }






