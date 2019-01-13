
   #------------------------------------------------------------
   ## Desactivation des boutons de la GUI en fonction des etapes
   #  de traitement.  
   #  @return void
   #
   proc ::bdi_gui_planetes::button_disable_all { deb } {

      $::bdi_gui_planetes::widget(step1,voir,button) configure -state disabled -relief raised 
      $::bdi_gui_planetes::widget(step1,exec,button) configure -state disabled
      $::bdi_gui_planetes::widget(step2,voir,button) configure -state disabled -relief raised 
      $::bdi_gui_planetes::widget(step2,exec,button) configure -state disabled
      

      return

      switch $deb {
         1 {
             $::bdi_gui_planetes::widget(step1,exec,button) configure -state active
             return 
         }
         2 {
             $::bdi_gui_planetes::widget(step1,exec,button) configure -state active
             $::bdi_gui_planetes::widget(step2,exec,button) configure -state active
             return 
         }
      }


      for {set i $deb} {$i <=6} {incr i } {
         $::bdi_gui_planetes::widget(step$i,voir,button) configure -state disabled -relief raised 
         $::bdi_gui_planetes::widget(step$i,exec,button) configure -state disabled
         set ::bdi_gui_planetes::widget(step$i,label) ""
      }
      $::bdi_gui_planetes::widget(step$deb,exec,button) configure -state active


   }







   #------------------------------------------------------------
   ## 1ere etape de traitement par lot : copie des images venant du telescope
   #  telles qu elles ont ete observees.
   #  @return void
   #
   proc ::bdi_gui_planetes::step1 { } {

      global audace
      global bddconf

      gren_info "Actual buf list : [lsort -integer [::buf::list] ]\n"

      ::bdi_gui_planetes::clean_canvas

      visu$bddconf(visuno) buf $bddconf(bufno)

      set ::bdi_gui_planetes::widget(step1,label) "Chargement des images initiales..."
      update

      set nb [llength $::bdi_gui_planetes::imglist]
      gren_info "NB IMG = $nb\n"
      gren_info "PWD = [pwd]\n"
      set $audace(rep_images) $bddconf(dirtmp)
      gren_info "rep_images = $audace(rep_images)\n"
      gren_info "rep_travail = $audace(rep_travail)\n"

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $nb
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $nb / 5]

      ::bdi_gui_planetes::button_disable_all 1
      
      set ::bdi_gui_planetes::index_datebuf_idimg ""
      set i 1
      set ::bdi_gui_planetes::scrollbar $i
      set nbwrite 0
      foreach img $::bdi_gui_planetes::imglist {


         set file [file join $bddconf(dirbase) [::bddimages_liste::lget $img dirfilename] [::bddimages_liste::lget $img filename] ] 
         set outfile "$::bdi_gui_planetes::widget(step1,file)$i$bddconf(extension_tmp)"

         loadima $file
         
         uncosmic 0
         subsky 300 0.4

         gren_info " COPY IMG = $file -> $outfile\n"
         saveima $outfile

         set cnt  [file exists [file join $bddconf(dirtmp) $outfile] ]
         gren_info "File exist $outfile ? $cnt\n"
         set nbwrite [expr $nbwrite + $cnt]
         set ::bdi_gui_planetes::widget(step1,label) "$nbwrite write files / $nb"
         
         # indexation des images / date
         # @warning il y a un probleme de modification des date-obs lorsqu on fait des transformation sur les images.
         set date [string trim [lindex [ buf$bddconf(bufno) getkwd DATE-OBS] 1] ]
         set jd [mc_date2jd $date]
         lappend ::bdi_gui_planetes::index_datebuf_idimg [list [expr $i-1] $date $jd]
         set ::bdi_gui_planetes::widget(datebuf_to_idimg,$date) [expr $i-1]
         set ::bdi_gui_planetes::widget(idimg_to_datebuf,[expr $i-1]) $date

         set date [string trim [lindex [::bddimages_liste::lget [::bddimages_liste::lget $img "tabkey"] "DATE-OBS"] 1] ]
         set ::bdi_gui_planetes::widget(dateimg_to_idimg,$date) [expr $i-1]
         
         # avancement de la scrollbar
         set ::bdi_gui_planetes::scrollbar $i
         incr i
      }

      set ::bdi_gui_planetes::scrollbar 1

      set ::bdi_gui_planetes::widget(step1,label) "Fin : $nbwrite write files"
      set ::bdi_gui_planetes::widget(nbimages)    $nbwrite

      $::bdi_gui_planetes::widget(scrollbar,frame)     configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame)     configure -to $nbwrite
      $::bdi_gui_planetes::widget(scrollbar,frame)     configure -tickinterval [expr $nbwrite / 5]
      $::bdi_gui_planetes::widget(scrollbar,frame)     configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame)     configure -state active
      $::bdi_gui_planetes::widget(manage_img,rejected) configure -command "::bdi_gui_planetes::delete_image_init" -state active

      $::bdi_gui_planetes::widget(step1,exec,button) configure -state active 
      $::bdi_gui_planetes::widget(step1,voir,button) configure -state active 
      $::bdi_gui_planetes::widget(step2,exec,button) configure -state active
      #$::bdi_gui_planetes::widget(step3b,exec,button) configure -state active
      #Button $::bdi_gui_planetes::widget(type_image,frame).ii -text "Img Init"  \
      #           -command "::bdi_gui_planetes::select_type_image init" 
      #grid $::bdi_gui_planetes::widget(type_image,frame).ii -in $::bdi_gui_planetes::widget(type_image,frame) -sticky news


      ::bdi_gui_planetes::voir 1
      
      gren_info "New buf list : [lsort -integer [::buf::list] ]\n"
      # initialisation des champs pour les rapports 
      #::bdi_gui_planetes::report_get_header

   }











   #------------------------------------------------------------
   ## 2eme etape de traitement par lot : 
   #  Construction d une image synthetique qui est l addition de 
   #  toutes les images
   #  @return void
   #
   proc ::bdi_gui_planetes::step2 { } {

      global bddconf

      gren_info "Actual buf list : [lsort -integer [::buf::list] ]\n"

      ::bdi_gui_planetes::button_disable_all 2

      set ::bdi_gui_planetes::widget(step2,label) "Recentrage des $::bdi_gui_planetes::widget(nbimages) images"
      update

      set outfile "$::bdi_gui_planetes::widget(step2,file)."

      register2 $::bdi_gui_planetes::widget(step1,file) $outfile $::bdi_gui_planetes::widget(nbimages) 1 

      set idframe 1
      set outfile "$::bdi_gui_planetes::widget(step2,file).$idframe$bddconf(extension_tmp)"
      while {[file exists $outfile]} {
         # next file
         incr idframe
         set outfile "$::bdi_gui_planetes::widget(step2,file).$idframe$bddconf(extension_tmp)"
      }
      set nbwrite [expr $idframe -1]


      set ::bdi_gui_planetes::widget(step2,label) "Fin : $nbwrite write files"

      $::bdi_gui_planetes::widget(step1,voir,button)   configure -state active
      $::bdi_gui_planetes::widget(step2,voir,button)   configure -state active
      $::bdi_gui_planetes::widget(film,ar)             configure -state active
      $::bdi_gui_planetes::widget(film,a)              configure -state active
      $::bdi_gui_planetes::widget(manage_img,rejected) configure -command "::bdi_gui_planetes::delete_image_center" -state active

      $::bdi_gui_planetes::widget(step1,exec,button) configure -state active
      $::bdi_gui_planetes::widget(step1,voir,button) configure -state active 
      $::bdi_gui_planetes::widget(step2,exec,button) configure -state active
      $::bdi_gui_planetes::widget(step2,voir,button) configure -state active 

      ::bdi_gui_planetes::voir 2

      # initialisation des champs pour les rapports 
      ::bdi_gui_planetes::report_get_header

      gren_info "New buf list : [lsort -integer [::buf::list] ]\n"

      return




      set outfile $::bdi_gui_planetes::widget(step2,file)
      sadd $::bdi_gui_planetes::widget(step1,file) $outfile $::bdi_gui_planetes::widget(nbimages) 1 bitpix=-32
      set ::bdi_gui_planetes::widget(step2,label) "FIN : [file exists [file join $bddconf(dirtmp) $outfile$bddconf(extension_tmp)] ] write file"

      if {[file exists [file join $bddconf(dirtmp) $outfile$bddconf(extension_tmp)] ]} {
         $::bdi_gui_planetes::widget(step2,voir,button) configure -state active 
         $::bdi_gui_planetes::widget(step3,exec,button) configure -state active
         ::bdi_gui_planetes::voir 2
         #tk_messageBox -message  "Avant de passer a l etape suivante :\nSelectionner un carre dans la visu entourant une etoile brillante mais pas trop\nla trace doit etre isolee" -type ok
      }

   }







