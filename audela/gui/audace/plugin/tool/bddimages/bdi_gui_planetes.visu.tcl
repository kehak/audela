


   #------------------------------------------------------------
   ## Nettoyage des ecritures sur canvas
   #  @return void
   #
   proc ::bdi_gui_planetes::clean_canvas { } {
      
      global bddconf

      # Nettoyage des ecritures sur canvas
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot_solo

   }




   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::get_filename { idframe { type "" } } {
      
      global bddconf

      if { $type != ""} {
         set stype $type
      } else {
         set stype $::bdi_gui_planetes::widget(type_image,selected)
      }
      
      switch $stype {
         "init" {
             return "$::bdi_gui_planetes::widget(step1,file)$idframe$bddconf(extension_tmp)"
         }
         "centre" {
             return "$::bdi_gui_planetes::widget(step2,file).$idframe$bddconf(extension_tmp)"
         }
      }
   }



      


   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::slide { idframe } {
      
      global bddconf

      if { ! [info exists ::bdi_gui_planetes::widget(type_image,selected)]} {return}
      
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot_solo
      switch $::bdi_gui_planetes::widget(type_image,selected) {

         "init" {
             # Eqv Step 1
             set outfile "$::bdi_gui_planetes::widget(step1,file)$idframe$bddconf(extension_tmp)"
             gren_info "DISK: $outfile\n"
             visu$bddconf(visuno) buf $bddconf(bufno)
              buf$bddconf(bufno) load $outfile
             ::audace::autovisu $bddconf(visuno)
             return

         }
         "centre" {
             # Eqv Step 2
             set bufno $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
             #gren_info "slide init, idframe=$idframe  bufno=$bufno\n"
             visu$bddconf(visuno) buf $bufno
             ::audace::autovisu $bddconf(visuno)

         }
         
         
      }
      
      #gren_info "scrollbar = $::bdi_gui_planetes::scrollbar\n"

   }





   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::move_scroll { } {

      #gren_info "Move scroll\n"
      #gren_info "visuNo    = $visuNo\n"
      #gren_info "scrollbar = $::bdi_gui_planetes::scrollbar\n"
      #gren_info "frame     = $::bdi_gui_planetes::widget(scrollbar,frame)\n"
      #gren_info "value     = [$::bdi_gui_planetes::widget(scrollbar,frame) get]\n"

      return
   }







   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::next_scroll { } {

      #gren_info "type image = $::bdi_gui_planetes::widget(type_image,selected)\n"
      #gren_info "nbwrite = $::bdi_gui_planetes::widget(type_image,$::bdi_gui_planetes::widget(type_image,selected),nbwrite)\n"
      if { $::bdi_gui_planetes::scrollbar < $::bdi_gui_planetes::widget(nbimages)  } {
         incr ::bdi_gui_planetes::scrollbar
         ::bdi_gui_planetes::slide $::bdi_gui_planetes::scrollbar
      } 
      return
   }








   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::previous_scroll { } {
      #gren_info "type image = $::bdi_gui_planetes::widget(type_image,selected)\n"
      #gren_info "nbwrite = $::bdi_gui_planetes::widget(type_image,$::bdi_gui_planetes::widget(type_image,selected),nbwrite)\n"
      if { $::bdi_gui_planetes::scrollbar > 1 } {
         incr ::bdi_gui_planetes::scrollbar -1
         ::bdi_gui_planetes::slide $::bdi_gui_planetes::scrollbar
      } 
      return
   }





   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::delete_image_init { } {


      gren_info "Delete image\n"
      gren_info "scrollbar = $::bdi_gui_planetes::scrollbar\n"
      set scrollbar_orig $::bdi_gui_planetes::scrollbar

      gren_info "Buffer avant effacement :\n"
      
      for {set i $::bdi_gui_planetes::scrollbar} {$i < $::bdi_gui_planetes::widget(nbimages)} { incr i} {
         
         set filesou [::bdi_gui_planetes::get_filename [expr $i+1] "init"]
         set filedes [::bdi_gui_planetes::get_filename $i "init"]
         if {[file exists $filesou]} {
            gren_info "move : $filesou -> $filedes\n"
            file rename -force -- $filesou $filedes
            set ::bdi_gui_planetes::scrollbar [expr $i+1]
         }
         
         set filesou [::bdi_gui_planetes::get_filename [expr $i+1] "centre"]
         set filedes [::bdi_gui_planetes::get_filename $i "centre"]
         if {[file exists $filesou]} {
            gren_info "move : $filesou -> $filedes\n"
            file rename -force -- $filesou $filedes
         }

      }
      
      incr ::bdi_gui_planetes::widget(nbimages) -1

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $::bdi_gui_planetes::widget(nbimages)
      #::bdi_gui_planetes::widget(type_image,$::bdi_gui_planetes::widget(type_image,selected),nbwrite)      
      if {$::bdi_gui_planetes::widget(nbimages) == 0} {
         $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 0
         $::bdi_gui_planetes::widget(scrollbar,frame) configure -to 0
         $::bdi_gui_planetes::widget(scrollbar,frame) configure -state disabled
      } else {
         set ::bdi_gui_planetes::scrollbar $scrollbar_orig
         ::bdi_gui_planetes::slide $::bdi_gui_planetes::scrollbar
      }
      
      return
   }




   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::delete_image_center { } {

      if { ! [info exists ::bdi_gui_planetes::buffer_list(frame2buf,$::bdi_gui_planetes::scrollbar)]} {return}

      gren_info "Delete image\n"
      gren_info "scrollbar = $::bdi_gui_planetes::scrollbar\n"
      set scrollbar_orig $::bdi_gui_planetes::scrollbar

      gren_info "Buffer avant effacement :\n"
      for {set idframe 1} {$idframe <= $::bdi_gui_planetes::widget(nbimages)} { incr idframe} {
         gren_info "idframe = $idframe -> bufno = $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)\n"
      }
      set bufno_todel $::bdi_gui_planetes::buffer_list(frame2buf,$scrollbar_orig)
      
      for {set i $::bdi_gui_planetes::scrollbar} {$i < $::bdi_gui_planetes::widget(nbimages)} { incr i} {
         
         set filesou [::bdi_gui_planetes::get_filename [expr $i+1] "init"]
         set filedes [::bdi_gui_planetes::get_filename $i "init"]
         if {[file exists $filesou]} {
            gren_info "move : $filesou -> $filedes\n"
            file rename -force -- $filesou $filedes
            set ::bdi_gui_planetes::scrollbar [expr $i+1]
         }
         
         set filesou [::bdi_gui_planetes::get_filename [expr $i+1] "centre"]
         set filedes [::bdi_gui_planetes::get_filename $i "centre"]
         if {[file exists $filesou]} {
            gren_info "move : $filesou -> $filedes\n"
            file rename -force -- $filesou $filedes
         }

         set ::bdi_gui_planetes::buffer_list(frame2buf,$i) $::bdi_gui_planetes::buffer_list(frame2buf,[expr $i+1])
         
      }
      
      
      gren_info "Delete from Buffer scroll : $scrollbar_orig\n"
      gren_info "Delete Buffer : $bufno_todel\n"
      ::buf::delete $bufno_todel
      unset ::bdi_gui_planetes::buffer_list(frame2buf,$::bdi_gui_planetes::widget(nbimages))
      gren_info "Delete Buffer exist last? : [info exists ::bdi_gui_planetes::buffer_list(frame2buf,$::bdi_gui_planetes::widget(nbimages))]\n"
      gren_info "Buffer list : [::buf::list]\n"

      gren_info "change scroll\n"
      incr ::bdi_gui_planetes::widget(nbimages) -1

      gren_info "Buffer apres effacement :\n"
      for {set idframe 1} {$idframe <= $::bdi_gui_planetes::widget(nbimages)} { incr idframe} {
         gren_info "idframe = $idframe -> bufno = $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)\n"
      }

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $::bdi_gui_planetes::widget(nbimages)
      #::bdi_gui_planetes::widget(type_image,$::bdi_gui_planetes::widget(type_image,selected),nbwrite)      
      if {$::bdi_gui_planetes::widget(nbimages) == 0} {
         $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 0
         $::bdi_gui_planetes::widget(scrollbar,frame) configure -to 1
         $::bdi_gui_planetes::widget(scrollbar,frame) configure -state disabled
      } else {
         set ::bdi_gui_planetes::scrollbar $scrollbar_orig
         ::bdi_gui_planetes::slide $::bdi_gui_planetes::scrollbar
      }
      
      return
   }









   #------------------------------------------------------------
   ## liberation des buffer pour la construction du film
   #  @return void
   #
   proc ::bdi_gui_planetes::buffer_clear {  } {
      
      if {![info exists ::bdi_gui_planetes::buffer_list]} {return}
      
      for {set idframe 1} {$idframe <= $::bdi_gui_planetes::widget(nbimages)} {incr idframe} {
         if {![info exists ::bdi_gui_planetes::buffer_list(frame2buf,$idframe)]} {continue}
         set bufno $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
         set err [catch {::buf::delete $bufno} msg]
         if {!$err} { gren_info "buf delete : $bufno\n" }
      }
      
      array unset ::bdi_gui_planetes::buffer_list
      return
   }







   #------------------------------------------------------------
   ## creation des buffer pour la construction du film
   #  @return void
   #
   proc ::bdi_gui_planetes::buffer_create {  } {

      gren_info "Creation des buffer\n"
      set r [lsort [::buf::list] ]
      gren_info "Actual buf list : [lsort [::buf::list] ]\n"
      set lastbuf [lindex $r end]
      gren_info "Last buf : $lastbuf\n"
      gren_info "Nombre d images en frame : $::bdi_gui_planetes::widget(nbimages)\n"

      for {set idframe 1} {$idframe <= $::bdi_gui_planetes::widget(nbimages)} {incr idframe} {
         set bufno [::buf::create]
         gren_info " idframe : $idframe -> buf create : $bufno\n"
         set ::bdi_gui_planetes::buffer_list(buf2frame,$bufno)   $idframe
         set ::bdi_gui_planetes::buffer_list(frame2buf,$idframe) $bufno
      }
      set r [lsort [::buf::list] ]
      gren_info "New buf list : [lsort [::buf::list] ]\n"

   }







   #------------------------------------------------------------
   ## creation des buffer pour la construction du film
   #  @return void
   #
   proc ::bdi_gui_planetes::buffer_load {  } {

      if {![info exists ::bdi_gui_planetes::buffer_list]} {return}

      for {set idframe 1} {$idframe <= $::bdi_gui_planetes::widget(nbimages)} {incr idframe} {
         set bufno $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
         set outfile [::bdi_gui_planetes::get_filename $idframe]
         gren_info " idframe = $idframe -> bufno = $bufno -> outfile = $outfile\n"
         buf$bufno load $outfile
      }

   }








   #------------------------------------------------------------
   ## Lance le film Va et Vient en continu
   #  @return void
   #
   proc ::bdi_gui_planetes::visu_boucle_va_et_vient_action {  } {

      global bddconf

      if {![info exists ::bdi_gui_planetes::buffer_list]} {return}

      # Cosntruction des listes de buffer
      set buf_list_vision ""
      for {set idframe 1} {$idframe < $::bdi_gui_planetes::widget(nbimages)} {incr idframe} {
         lappend buf_list_vision $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      }
      for {set idframe $::bdi_gui_planetes::widget(nbimages)} {$idframe > 1} {incr idframe -1} {
         lappend buf_list_vision $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      }

      while { 1 } {
         if {[$::bdi_gui_planetes::widget(film,ar) cget -relief] == "raised"} {break}
      
         if {![info exists ::bdi_gui_planetes::buffer_list]} {break}

         set tt0 [clock clicks -milliseconds]

         foreach bufno $buf_list_vision {
            if {[$::bdi_gui_planetes::widget(film,ar) cget -relief] == "raised"} {break}
            set ::bdi_gui_planetes::scrollbar $::bdi_gui_planetes::buffer_list(buf2frame,$bufno)
            visu$bddconf(visuno) buf $bufno
            ::audace::autovisu $bddconf(visuno)
            #after 1
            update
         }
         
         set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
         gren_info "un aller-retour : $tt_total ms\n"  
         
      }
      
      gren_info "Fin: boucle_va_et_vient\n"  
      
   }


   #------------------------------------------------------------
   ## Appuie sur bouton Va et Vient. Demarre ou arrete le film. 
   #  @return void
   #
   proc ::bdi_gui_planetes::visu_boucle_va_et_vient {  } {

      if { [$::bdi_gui_planetes::widget(film,ar) cget -relief] == "raised"} {
      
         if { [$::bdi_gui_planetes::widget(film,a) cget -relief] == "sunken"} {
            $::bdi_gui_planetes::widget(film,a) configure -relief "raised"
         }

         $::bdi_gui_planetes::widget(film,ar) configure -relief "sunken"
         gren_info "DEBUT : boucle_va_et_vient\n"  
         ::bdi_gui_planetes::visu_boucle_va_et_vient_action
         

      } else {

         # bouton Selectionne
         $::bdi_gui_planetes::widget(film,ar) configure -relief "raised"
         
      }

   }
   
   
   
   
   #------------------------------------------------------------
   ## creation des buffer pour la construction du film
   #  @return void
   #
   proc ::bdi_gui_planetes::visu_boucle_un_sens_action {  } {
      
      global bddconf
      
      if {![info exists ::bdi_gui_planetes::buffer_list]} {return}

      # Cosntruction des listes de buffer
      set buf_list_vision ""
      for {set idframe 1} {$idframe <= $::bdi_gui_planetes::widget(nbimages)} {incr idframe} {
         lappend buf_list_vision $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      }

      while { 1 } {
         if {[$::bdi_gui_planetes::widget(film,a) cget -relief] == "raised"} {break}
      
         if {![info exists ::bdi_gui_planetes::buffer_list]} {break}

         set tt0 [clock clicks -milliseconds]

         foreach bufno $buf_list_vision {
            if {[$::bdi_gui_planetes::widget(film,a) cget -relief] == "raised"} {break}
            set ::bdi_gui_planetes::scrollbar $::bdi_gui_planetes::buffer_list(buf2frame,$bufno)
            visu$bddconf(visuno) buf $bufno
            ::audace::autovisu $bddconf(visuno)
            #after 1
            update
         }
         
         set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
         gren_info "un aller : $tt_total ms\n"  
         
      }
      
      gren_info "Fin: boucle_un_sens\n"  
      
   }
   
   #------------------------------------------------------------
   ## creation des buffer pour la construction du film
   #  @return void
   #
   proc ::bdi_gui_planetes::visu_boucle_un_sens {  } {

      if { [$::bdi_gui_planetes::widget(film,a) cget -relief] == "raised"} {

         if { [$::bdi_gui_planetes::widget(film,ar) cget -relief] == "sunken"} {
            $::bdi_gui_planetes::widget(film,ar) configure -relief "raised"
         }

         $::bdi_gui_planetes::widget(film,a) configure -relief "sunken"
         gren_info "DEBUT : boucle_un_sens\n"  
         ::bdi_gui_planetes::visu_boucle_un_sens_action
         

      } else {

         $::bdi_gui_planetes::widget(film,a) configure -relief "raised"
         
      }
   }







   #------------------------------------------------------------
   ## Visualisation des images. bufferisation
   #  @return void
   #
   proc ::bdi_gui_planetes::voir { step } {

      gren_info "Actual buf list : [lsort -integer [::buf::list] ]\n"

      for {set i 1} {$i <=2} {incr i } {
         $::bdi_gui_planetes::widget(step$i,voir,button) configure -relief raised 
      }
      $::bdi_gui_planetes::widget(step$step,voir,button) configure -relief sunken

      switch $step {

         "1" {
             # Eqv Step 1
             $::bdi_gui_planetes::widget(step1,voir,button) configure -state disabled
             set ::bdi_gui_planetes::widget(type_image,selected) "init"
             ::bdi_gui_planetes::buffer_clear
             ::bdi_gui_planetes::slide $::bdi_gui_planetes::scrollbar
             $::bdi_gui_planetes::widget(step1,voir,button) configure -state active
             $::bdi_gui_planetes::widget(manage_img,rejected) configure -command "::bdi_gui_planetes::delete_image_init" -state active
         }

         "2" {
             # Eqv Step 2
             set ::bdi_gui_planetes::widget(type_image,selected) "centre"
             ::bdi_gui_planetes::buffer_clear
             ::bdi_gui_planetes::buffer_create
             ::bdi_gui_planetes::buffer_load
             $::bdi_gui_planetes::widget(manage_img,rejected) configure -command "::bdi_gui_planetes::delete_image_center" -state active
         }
      
      }


      gren_info "New buf list : [lsort -integer [::buf::list] ]\n"
      return
   }





   #------------------------------------------------------------
   ## Visualisation des images. bufferisation
   #  @return void
   #
   proc ::bdi_gui_planetes::scroll_to_gif {  } {

      # voir : 
      # ./gui/audace/plugin/tool/spcaudace/spc_operations.tcl
      # ligne 592
   }







