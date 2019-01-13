




   # $::audace(bufNo)
   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::charge_cata {  } {
      
      gren_info "Charge Cata\n"
      
      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo   $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      set dateiso [string trim [lindex [ buf$bufNo getkwd DATE-OBS] 1] ]
      gren_info "idframe = $idframe\n"
      gren_info "bufNo = $bufNo\n"
      gren_info "dateiso buffer = $dateiso\n"
      
      # on cherche l id de l image dans imglist
      set idimg [::bdi_tools_planetes::get_idimg $dateiso]
      gren_info "idimg = $idimg\n"
      
      # on cherche l id de l image dans imglist
      set ::tools_cata::current_image [lindex $::bdi_gui_planetes::imglist $idimg]
      set dateiso [string trim [lindex [::bddimages_liste::lget [::bddimages_liste::lget $::tools_cata::current_image "tabkey"] "DATE-OBS"] 1] ]
      gren_info "dateiso imglist = $dateiso\n"
      
      # on charge le cata
      set nbs [::bdi_gui_cata::load_cata]
      if { $nbs == 0 } {
         tk_messageBox -message "Erreur : Sources non trouvees" -type ok
         return
      }
      gren_info "Nb source lues dans le cata : $nbs\n"

      return
      
      set sources [lindex  $::tools_cata::current_listsources 1]

      # on cherche la source
      set ids -1
      foreach s $sources {
         incr ids

         set name [::manage_source::namincata $s]
         if {$name == ""} {continue}
         
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set flux [::bdi_tools_psf::get_val othf flux]
         set mag [::bdi_tools_psf::get_val othf mag]
         if {$flux=="" || $mag==""} {continue}

         gren_info [format "%-30s %10.0f %10.3f\n" $name $flux $mag]
         
      }

   }






   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::select_star {  } {

   }







   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::starref_nocata_select_box {  } {
      gren_info "select etoile NOCATA\n"

   }









   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::free_results {  } {

      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,ra)   ""
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,dec)  ""
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,mag)  ""
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,name) ""

   }









   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::starref_usecata_select_box_view {  } {

      global bddconf

      gren_info "view etoile USECATA : $::bdi_gui_planetes::scrollbar\n"
      cleanmark
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,ra)   ""
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,dec)  ""
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,mag)  ""
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,name) ""
      
      if { ! $::bdi_gui_planetes::widget(starref,usecata,manu)} {
         return
      }
      
      $::bdi_gui_planetes::widget(starref,usecata,box) configure -state disabled    
      
      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      set dateiso [string trim [lindex [ buf$bufNo getkwd DATE-OBS ] 1] ]
      
      gren_info "idframe = $idframe\n"
      gren_info "bufNo = $bufNo\n"
      gren_info "dateiso buffer = $dateiso\n"

      # on cherche l id de l image dans imglist
      set idimg [::bdi_tools_planetes::get_idimg $dateiso]
      gren_info "idimg = $idimg\n"

      set ::tools_cata::current_image [lindex $::bdi_gui_planetes::imglist $idimg]
      set nbs [::bdi_gui_cata::load_cata]
      if { $nbs == 0 } {
         tk_messageBox -message "Erreur : Sources non trouvees" -type ok
         return
      }
      gren_info "Nb source lues dans le cata : $nbs\n"

      set sources [lindex  $::tools_cata::current_listsources 1]
      set newsources ""
      
      set ids -1
      foreach s $sources {
         incr ids

         set name [::manage_source::namincata $s]
         if {$name == ""} {continue}
         
         set othf    [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set flux    [::bdi_tools_psf::get_val othf flux]
         set mag     [::bdi_tools_psf::get_val othf mag]
         set err_psf [::bdi_tools_psf::get_val othf err_psf]
         set pixmax  [::bdi_tools_psf::get_val othf pixmax]
         if {$flux==""}     {continue}
         if {$mag==""}      {continue}
         if {$err_psf!="-"} {continue}
         if {$pixmax>20000} {continue}

         lappend newsources $s
         gren_info [format "%35s %10s %10s %5s %+10s \n" $name $flux $mag $err_psf $pixmax]
      }
      set ::tools_cata::current_listsources [list [lindex  $::tools_cata::current_listsources 0] $newsources]
      
      # on recharge l image dans le buffer principal
      set outfile "$::bdi_gui_planetes::widget(step2,file).$::bdi_gui_planetes::scrollbar$bddconf(extension_tmp)"
      gren_info "Charge : $outfile\n"
      visu$bddconf(visuno) buf $bddconf(bufno)
       buf$bddconf(bufno) load $outfile
      ::audace::autovisu $bddconf(visuno)

      affich_rond $::tools_cata::current_listsources UCAC4 blue 4
      $::bdi_gui_planetes::widget(starref,usecata,box) configure -state active    

   }








   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::starref_usecata_select_box {  } {

      global bddconf

      gren_info "select etoile USECATA\n"
      
      if { ! [info exists ::bdi_gui_planetes::scrollbar]} {
         gren_info "no scroll\n"
         return
      }
      
      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      set refcata [string trim [lindex [buf$bufNo getkwd "BDDIMAGES CATAASTROM"] 1] ]

      set err [ catch {set rect  [ ::confVisu::getBox $bddconf(visuno) ]} msg ]
      if {$err>0 || $rect==""} {
         set getbox "no"
      } else {
         set getbox "yes"
         
      }

      gren_info "Rect   : $rect  \n"
      gren_info "getbox : $getbox  \n"
      set selected "no"

      set listsources [::manage_source::extract_sources_by_catalog $::tools_cata::current_listsources $refcata]

      set sources [lindex  $listsources 1]
      set ids -1
      gren_info "Nb sources : [llength  $sources] \n"
      foreach s $sources {
         incr ids
         
         set err [ catch {set xy  [::bdi_tools_psf::get_xy s]} msg ]
         if {$err} {
            continue
         }
         set x [lindex $xy 0]
         set y [lindex $xy 1]
         if { $x < [lindex $rect 2] &&  $x > [lindex $rect 0] &&
              $y < [lindex $rect 3] &&  $y > [lindex $rect 1] } {
            
            
            if { $selected == "yes"} {
               return -code 1 "Selectionner une seule etoile"
            }
            set selected "yes"
            
         }

      }
      
      if { $selected == "no"} {
         return -code 1 "Pas d etoile connue dans le champ"
      }
      
      # ok on a une etoile $s
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      set ra   [::bdi_tools_psf::get_val othf ra]
      set dec  [::bdi_tools_psf::get_val othf dec]
      set mag  [::bdi_tools_psf::get_val othf mag]
      
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,ra)   [::bdi_tools_psf::get_val othf ra]
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,dec)  [::bdi_tools_psf::get_val othf dec]
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,mag)  [::bdi_tools_psf::get_val othf mag]
      set ::bdi_gui_planetes::widget(starref_usecata,manuel,star,name) [::manage_source::namincata $s]

   }
