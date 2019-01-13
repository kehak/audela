   #------------------------------------------------------------
   ## 1ere etape de traitement par lot : copie des images venant du telescope
   #  telles qu elles ont ete observees.
   #  @return void
   #
   proc ::bdi_gui_planetes::step1_obsolete { } {

      global bddconf

      ::bdi_gui_planetes::clean_canvas

      visu$::audace(visuNo) buf $::audace(bufNo)
      ::audace::autovisu $::audace(visuNo)

      set ::bdi_gui_planetes::widget(step1,label) "Chargement des images initiales..."
      update

      set nb [llength $::bdi_gui_planetes::imglist]
      gren_info "NB IMG = $nb\n"
      gren_info "PWD = [pwd]\n"
      set ::audace(rep_images) $bddconf(dirtmp)
      gren_info "rep_images = $::audace(rep_images)\n"
      gren_info "rep_travail = $::audace(rep_travail)\n"
      set ext [buf$::audace(bufNo) extension]
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $nb
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $nb / 5]

      ::bdi_gui_planetes::button_disable_all 1

      set i 1
      set ::bdi_gui_planetes::scrollbar $i
      set nbwrite 0
      foreach img $::bdi_gui_planetes::imglist {
         set file [file join $bddconf(dirbase) [::bddimages_liste::lget $img dirfilename] [::bddimages_liste::lget $img filename] ] 
         set outfile "$::bdi_gui_planetes::widget(step1,file)$i$ext"
         gren_info " COPY IMG = $file -> $outfile\n"
         loadima $file
         uncosmic 0
         subsky 300 0.4
         saveima $outfile
         set cnt  [file exists [file join $bddconf(dirtmp) $outfile] ]
         gren_info "File exist $outfile ? $cnt\n"
         set nbwrite [expr $nbwrite + $cnt]
         set ::bdi_gui_planetes::widget(step1,label) "$nbwrite write files / $nb"
         
         # indexation des images / jd
         set dateiso [lindex [buf$::audace(bufNo) getkwd "DATE-OBS"] 1]
         set ::bdi_gui_planetes::widget(dateiso2idimg,$dateiso) $i
         
         # avancement de la scrollbar
         set ::bdi_gui_planetes::scrollbar $i
         incr i
      }

      set ::bdi_gui_planetes::scrollbar 0

      set ::bdi_gui_planetes::widget(step1,label) "Fin : $nbwrite write files"
      set ::bdi_gui_planetes::widget(nbimages)    $nbwrite

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $nbwrite
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $nbwrite / 5]
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -state active

      $::bdi_gui_planetes::widget(step1,voir,button) configure -state active 
      $::bdi_gui_planetes::widget(step2,exec,button) configure -state active
      #$::bdi_gui_planetes::widget(step3b,exec,button) configure -state active
      #Button $::bdi_gui_planetes::widget(type_image,frame).ii -text "Img Init"  \
      #           -command "::bdi_gui_planetes::select_type_image init" 
      #grid $::bdi_gui_planetes::widget(type_image,frame).ii -in $::bdi_gui_planetes::widget(type_image,frame) -sticky news
      ::bdi_gui_planetes::voir 1
      
      # initialisation des champs pour les rapports 
      ::bdi_gui_planetes::report_get_header

   }











   #------------------------------------------------------------
   ## 2eme etape de traitement par lot : 
   #  Construction d une image synthetique qui est l addition de 
   #  toutes les images
   #  @return void
   #
   proc ::bdi_gui_planetes::step2_obsolete { } {

      global bddconf

      ::bdi_gui_planetes::button_disable_all 2

      set ::bdi_gui_planetes::widget(step2,label) "Ajout des $::bdi_gui_planetes::widget(nbimages) images"
      update
      set ext [buf$::audace(bufNo) extension]
      set outfile $::bdi_gui_planetes::widget(step2,file)
      sadd $::bdi_gui_planetes::widget(step1,file) $outfile $::bdi_gui_planetes::widget(nbimages) 1 bitpix=-32
      set ::bdi_gui_planetes::widget(step2,label) "FIN : [file exists [file join $bddconf(dirtmp) $outfile$ext] ] write file"

      if {[file exists [file join $bddconf(dirtmp) $outfile$ext] ]} {
         $::bdi_gui_planetes::widget(step2,voir,button) configure -state active 
         $::bdi_gui_planetes::widget(step3,exec,button) configure -state active
         ::bdi_gui_planetes::voir 2
         #tk_messageBox -message  "Avant de passer a l etape suivante :\nSelectionner un carre dans la visu entourant une etoile brillante mais pas trop\nla trace doit etre isolee" -type ok
      }
   }

   #------------------------------------------------------------
   ## 3eme etape de traitement par lot : 
   #  Construction d une image synthetique qui est l addition de 
   #  toutes les images
   #  @return void
   #
   proc ::bdi_gui_planetes::step3 { } {

      global bddconf

      set ::bdi_gui_planetes::widget(step3,label) "Creation"
      update

      ::bdi_gui_planetes::button_disable_all 3

      set ext [buf$::audace(bufNo) extension]

      set ::bdi_gui_planetes::widget(step3,label) "Centrage"
      update

      registerbox $::bdi_gui_planetes::widget(step1,file) "$::bdi_gui_planetes::widget(step2,file)." $::bdi_gui_planetes::widget(nbimages) 1 1 

      set outfile $::bdi_gui_planetes::widget(step3,file)

      set ::bdi_gui_planetes::widget(step3,label) "Triage"
      update
      ssort "$::bdi_gui_planetes::widget(step2,file)." $outfile $::bdi_gui_planetes::widget(nbimages) 20 1

      set ::bdi_gui_planetes::widget(step3,label) "FIN : [file exists [file join $bddconf(dirtmp) $outfile$ext] ] write file"

      if {[file exists [file join $bddconf(dirtmp) $outfile$ext] ]} {
         $::bdi_gui_planetes::widget(step3,voir,button) configure -state active 
         #$::bdi_gui_planetes::widget(step4,exec,button) configure -state active
         ::bdi_gui_planetes::voir 3
      }
   }


# $::bdi_gui_planetes::widget(step3b,exec,button) configure -state active
# $::bdi_gui_planetes::widget(step3b,voir,button) configure -state active

   #------------------------------------------------------------
   ## 3eme etape de traitement par lot (bis): 
   #  Construction d une image synthetique qui est l addition de 
   #  toutes les images en alignant avec la methode affine
   #  @return void
   #
   proc ::bdi_gui_planetes::step3bis { } {

      global bddconf

      set ::bdi_gui_planetes::widget(step3b,label) "Creation"
      update

      #::bdi_gui_planetes::button_disable_all 3

      set ext [buf$::audace(bufNo) extension]

      set ::bdi_gui_planetes::widget(step3b,label) "Centrage"
      update

      set outfile "$::bdi_gui_planetes::widget(step2,file)."

      register2 $::bdi_gui_planetes::widget(step1,file) $outfile $::bdi_gui_planetes::widget(nbimages) 1 

      set ::bdi_gui_planetes::widget(step3b,label) "FIN"

      $::bdi_gui_planetes::widget(step3b,voir,button) configure -state active
      return
      
      if {[file exists [file join $bddconf(dirtmp) $outfile$ext] ]} {
         $::bdi_gui_planetes::widget(step3,voir,button) configure -state active 
         #$::bdi_gui_planetes::widget(step4,exec,button) configure -state active
         ::bdi_gui_planetes::voir 3
      }
   }












   proc ::bdi_gui_planetes::step3_obsolete { } {

      global bddconf

      set ext [buf$::audace(bufNo) extension]

      registerbox $::bdi_gui_planetes::widget(step1,file) "$::bdi_gui_planetes::widget(step2,file)." $::bdi_gui_planetes::widget(nbimages) 1 0 

      ssort "$::bdi_gui_planetes::widget(step2,file)." $::bdi_gui_planetes::widget(step3,file) $::bdi_gui_planetes::widget(nbimages) 20 0 
      loadima $::bdi_gui_planetes::widget(step3,file)

      set ::bdi_gui_planetes::widget(step3,label) "FIN : [file exists [file join $bddconf(dirtmp) $::bdi_gui_planetes::widget(step3,file)$ext] ] write file"

   }





   proc ::bdi_gui_planetes::step4 { } {

      global bddconf

      set ::bdi_gui_planetes::widget(step4,label) "Creation"
      update

      ::bdi_gui_planetes::button_disable_all 4

      set ext [buf$::audace(bufNo) extension]

      set ::bdi_gui_planetes::widget(step4,label) "Soustraction d une image"
      update
      set cmd "sub2 $::bdi_gui_planetes::widget(step2,file). $::bdi_gui_planetes::widget(step3,file) $::bdi_gui_planetes::widget(step4,file) 0 $::bdi_gui_planetes::widget(nbimages) 0"
      gren_info "CMD= $cmd\n"

      set in           $::bdi_gui_planetes::widget(step2,file).
      set operand      $::bdi_gui_planetes::widget(step3,file)
      set out          $::bdi_gui_planetes::widget(step4,file)
      set const        0
      set number       $::bdi_gui_planetes::widget(nbimages)
      set first_index  1 

      gren_info "CMD= sub2 $in $operand $out $const $number $first_index\n"
      sub2 $in $operand $out $const $number $first_index
      #sub2 $::bdi_gui_planetes::widget(step2,file). $::bdi_gui_planetes::widget(step3,file) $::bdi_gui_planetes::widget(step4,file) 0 $::bdi_gui_planetes::widget(nbimages) 0

      set nbwrite 0
      for {set i 1} {$i <= $::bdi_gui_planetes::widget(nbimages)} {incr i} {
         set outfile [file join $bddconf(dirtmp) $::bdi_gui_planetes::widget(step4,file)$i$ext]
         set cnt     [file exists $outfile ]
         set nbwrite [expr $nbwrite + $cnt]
      }
      set ::bdi_gui_planetes::widget(step4,label) "FIN : $nbwrite write files"

      $::bdi_gui_planetes::widget(step4,voir,button) configure -state active 
      $::bdi_gui_planetes::widget(step5,exec,button) configure -state active
      ::bdi_gui_planetes::voir 4

   }








   proc ::bdi_gui_planetes::step4_obsolete { } {

      global bddconf

      set ext [buf$::audace(bufNo) extension]

      set cmd "sub2 $::bdi_gui_planetes::widget(step2,file). $::bdi_gui_planetes::widget(step3,file) $::bdi_gui_planetes::widget(step4,file) 0 $::bdi_gui_planetes::widget(nbimages) 0"
      gren_info "CMD= $cmd\n"
      sub2 $::bdi_gui_planetes::widget(step2,file). $::bdi_gui_planetes::widget(step3,file) $::bdi_gui_planetes::widget(step4,file) 0 $::bdi_gui_planetes::widget(nbimages) 0

      set nbwrite 0
      for {set i 1} {$i <= $::bdi_gui_planetes::widget(nbimages)} {incr i} {
         set outfile [file join $bddconf(dirtmp) $::bdi_gui_planetes::widget(step4,file)$i$ext]
         set cnt  [file exists $outfile ]
         set nbwrite [expr $nbwrite + $cnt]
      }
      set ::bdi_gui_planetes::widget(step4,label) "FIN : $nbwrite write files"

   }








   proc ::bdi_gui_planetes::step5 { } {

      global bddconf

      set ext [buf$::audace(bufNo) extension]

      loadima $::bdi_gui_planetes::widget(step3,file)

      set kappa 3
      set res       [stat]
      set fond      [lindex $res 6 ]
      set sigfond   [lindex $res 7 ]

      gren_info "kappa   = $kappa\n"
      gren_info "fond    = $fond\n"
      gren_info "sigfond = $sigfond\n"

      set seuil [expr $fond + $kappa * $sigfond]
      clipmin $seuil
      clipmax [expr $seuil+1]
      offset [expr -($seuil+1)]
      mult -1
      saveima $::bdi_gui_planetes::widget(step5,file)

      set ::bdi_gui_planetes::widget(step5,label) "FIN : [file exists [file join $bddconf(dirtmp) $::bdi_gui_planetes::widget(step5,file)$ext] ] write file"

   }


   proc ::bdi_gui_planetes::step6 { } {

      global bddconf

      set ext [buf$::audace(bufNo) extension]

      for {set i 0} {$i<$::bdi_gui_planetes::widget(nbimages)} {incr i}  {
         loadima $::bdi_gui_planetes::widget(step2,file).$i$ext
         noffset 0
         prod $::bdi_gui_planetes::widget(step5,file) 1
      set cmd "saveima $::bdi_gui_planetes::widget(step6,file).$i$ext"
      gren_info "CMD= $cmd\n"
         saveima "$::bdi_gui_planetes::widget(step6,file).$i$ext"
      }
      sadd "$::bdi_gui_planetes::widget(step6,file)." $::bdi_gui_planetes::widget(step6,file) $::bdi_gui_planetes::widget(nbimages) 0 bitpix=-32
      loadima $::bdi_gui_planetes::widget(step6,file)

      set ::bdi_gui_planetes::widget(step6,label) "FIN : [file exists [file join $bddconf(dirtmp) $::bdi_gui_planetes::widget(step6,file)$ext] ] write file"

   }





   proc ::bdi_gui_planetes::bricolette { } {

      return
      gren_info "Traitement \n"


   proc t1 {} {

      if {1} {
         set list_file [glob "*.fits.gz"]
         set list_file [lsort -ascii $list_file]

         set i 0
         foreach file $list_file {
            ::console::affiche_resultat "[expr $i+1] / [llength $list_file]\n"
            set newfile i$i.fits.gz
            file copy -force -- $file $newfile
            lassign [::bdi_tools::gunzip $newfile] errnum msgzip
            loadima i$i
            uncosmic 0
            subsky 300 0.4
            saveima i$i
            file delete $newfile
            incr i
         }
      }

   }
   proc t2 {} {
      sadd i o 27 0 bitpix=-32
      loadima o
   }
   proc t3 {} {
      registerbox i o 27 1 0 
   #   sadd o t 27 0 bitpix=-32
      ssort o t 27 20 0 
      loadima t
   }
   proc t4 {} {
      #loadima o0
      #sub t 0
      sub2 o t f 0 27 0
   }
   proc t5 {} {
      loadima t

      set res [stat]
      set fond [lindex $res 6 ]
      set sigfond  [lindex $res 7 ]

      set kappa 6
      set seuil [expr $fond + $kappa * $sigfond]
      clipmin $seuil
      clipmax [expr $seuil+1]
      offset [expr -($seuil+1)]
      mult -1
      saveima mask
   }


   #subsky 300 0.4
   proc t6 {} {
      for {set i 0} {$i<=26} {incr i}  {
         loadima o$i
         noffset 0
         prod mask 1
         saveima p$i
      }
      sadd p m 27 0 bitpix=-32
      loadima m
   }



   # t1
   # t2
   ## entourer l etoile isolee
   # t3
   # t4
   # t5
   # t6


      gren_info "FIN ! Traitement \n"

   }























# ::bddimages::ressource ; ::bdi_gui_planetes::test_rotation


   #------------------------------------------------------------
   ## Nettoyage des ecritures sur canvas
   #  @return void
   #
   proc ::bdi_gui_planetes::test_selection { } {
      
      global bddconf

      # etoile de ref
      set ra  243.960643 
      set dec  22.270622
      set radius 10

      set fwh_min 2
      set fwh_max 7      
      set int_min 5000
      set int_max 20000     
      set fon_min 1000
      set fon_max 10000     
      
      #::bdi_gui_planetes::widget(step1,file)
      
      set idframe 1
      set ext [buf$::audace(bufNo) extension]
      set outfile "$::bdi_gui_planetes::widget(step1,file)$idframe$ext"
      set cpt 0

      # ouverture du fichier de mesure CSV
      set filename_csv [file join $bddconf(dirtmp) "test_rotation.csv"]
      set handler [open $filename_csv "w"]
      puts $handler "idframe, bufno, int, fwhm, fond"

      while {[file exists $outfile]} {
         
         
         # on traite ces fichiers
         set bufno $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
         set ::bdi_gui_planetes::scrollbar $idframe
         gren_info "$idframe -> $bufno ->  $outfile : "
         
         set xy [ buf$bufno radec2xy [ list $ra $dec ] ]
         lassign $xy x y 
         set x0 [expr int($x - $radius)]
         set y0 [expr int($y - $radius)]
         set x1 [expr int($x + $radius)]
         set y1 [expr int($y + $radius)]
         set mes [buf$bufno fitgauss [list $x0 $y0 $x1 $y1] ]
         # gren_info "buf$bufno fitgauss $x0 $y0 $x1 $y1"
         lassign $mes xint xcen xfwh xfon yint ycen yfwh yfon
         set int [expr int(sqrt((pow($xint,2)+pow($yint,2))/2.0))]
         set fwh [format "%0.1f" [expr (sqrt((pow($xfwh,2)+pow($yfwh,2))/2.0))] ]
         set fon [expr int(sqrt((pow($xfon,2)+pow($yfon,2))/2.0))]

         puts $handler [format "%s, %s, %s, %s, %s" $idframe $bufno $int $fwh $fon ]
         
         gren_info "fwhm = $fwh"
         if { $fwh>$fwh_min && $fwh<$fwh_max && \
              $int>$int_min && $int<$int_max && \
              $fon>$fon_min && $fon<$fon_max     } { 
            incr cpt
            set newfile selection.$cpt$ext
            file copy -force -- $outfile $newfile
            gren_info "copie : $newfile\n"
         } 
         
         gren_info "\n"
         
         # next file
         incr idframe
         set outfile "$::bdi_gui_planetes::widget(step1,file)$idframe$ext"
      }

      close $handler
      gren_info "cpt = $cpt / $idframe"

   }



# ::bddimages::ressource ; ::bdi_gui_planetes::selection2buf


   proc ::bdi_gui_planetes::selection2buf { } {

      global bddconf

      set idframe 1
      set ext [buf$::audace(bufNo) extension]
      set outfile selection.$idframe$ext
      while {[file exists $outfile]} {

         # on traite ce fichier
         set newfile $::bdi_gui_planetes::widget(step1,file)$idframe$ext
         file copy -force -- $outfile $newfile
         gren_info "copie : $newfile\n"
         
         # next file
         incr idframe
         set outfile selection.$idframe$ext
      }
      incr idframe -1

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -state active

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $idframe
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $idframe / 5]
      set ::bdi_gui_planetes::widget(nbimages)    $idframe

      ::bdi_gui_planetes::buffer_clear
      array unset ::bdi_gui_planetes::buffer_list
      ::bdi_gui_planetes::voir 1

      return
   }


# ::bddimages::ressource ; ::bdi_gui_planetes::charge2buf



   proc ::bdi_gui_planetes::charge2buf { } {

      set idframe 1
      set ext [buf$::audace(bufNo) extension]
      set outfile $::bdi_gui_planetes::widget(step1,file)$idframe$ext
      while {[file exists $outfile]} {
         # on traite ce fichier
         
         # next file
         incr idframe
         set outfile $::bdi_gui_planetes::widget(step1,file)$idframe$ext
      }
      incr idframe -1

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -state active

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $idframe
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $idframe / 5]
      set ::bdi_gui_planetes::widget(nbimages) $idframe

      ::bdi_gui_planetes::buffer_clear
      array unset ::bdi_gui_planetes::buffer_list
      ::bdi_gui_planetes::voir 1
      return
   }



# ::bddimages::ressource ; ::bdi_gui_planetes::selection2


   proc ::bdi_gui_planetes::selection2 { } {

      global bddconf

      set idframe 1
      set ext [buf$::audace(bufNo) extension]
      set outfile "$::bdi_gui_planetes::widget(step1,file)$idframe$ext"
      set cpt 0

      # ouverture du fichier de mesure CSV
      set filename_csv [file join $bddconf(dirtmp) "selection2.csv"]
      set handler [open $filename_csv "w"]
      puts $handler "idframe, sh, sb, vmax, vmin, moyglob, stdevglob, moyfond, stdevfond, contr"

      while {[file exists $outfile]} {

         # on traite ces fichiers
         set bufno $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
         set ::bdi_gui_planetes::scrollbar $idframe
         gren_info "$idframe -> $bufno ->  $outfile : "
         
         set mes [buf$bufno stat ]
         lassign $mes sh sb vmax vmin moyglob stdevglob moyfond stdevfond contr
         puts $handler [format "%3s, %7.1f, %7.1f, %7.1f, %7.1f, %7.1f, %7.1f, %7.1f, %7.1f, %7.1f" $idframe $sh $sb $vmax $vmin $moyglob $stdevglob $moyfond $stdevfond $contr ]

         set moyglob_max 30000
         set moyfond_max 30000
         set stdevfond_max   40
         set stdevglob_min   600
         set stdevglob_max   1200
         
         if { $moyglob<$moyglob_max && \
              $moyfond<$moyfond_max && \
              $stdevfond<$stdevfond_max && \
              $stdevglob>$stdevglob_min && $stdevglob<$stdevglob_max  \
                 } { 
            incr cpt
            set newfile selection.$cpt$ext
            file copy -force -- $outfile $newfile
            gren_info "copie : $newfile\n"
         } 
         
         
         
         gren_info "\n"
         
         # next file
         incr idframe
         set outfile "$::bdi_gui_planetes::widget(step1,file)$idframe$ext"
      }

      close $handler
      gren_info "cpt = $cpt / $idframe"

      return
   }
   
   
   
   
# ::bddimages::ressource ; ::bdi_gui_planetes::selection2_to_buf

   proc ::bdi_gui_planetes::selection2_to_buf { } {

      global bddconf

      set ext [buf$::audace(bufNo) extension]
      
      set cpt 0
      for {set i 1} {$i<100} {incr i} {
         
         set outfile i$i$ext
         
         if {![file exists $outfile]} {
            continue
         }
         
         incr cpt
         set newfile $::bdi_gui_planetes::widget(step1,file)$cpt$ext
         file copy -force -- $outfile $newfile
         gren_info "copie : $newfile\n"

         
      }
      gren_info "cpt = $cpt"

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -state active

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $cpt
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $cpt / 5]
      set ::bdi_gui_planetes::widget(nbimages)    $cpt

      ::bdi_gui_planetes::buffer_clear
      array unset ::bdi_gui_planetes::buffer_list
      ::bdi_gui_planetes::voir 1
      
      
      return
      
      set idframe 1
      set ext [buf$::audace(bufNo) extension]
      set outfile selection.$idframe$ext
      while {[file exists $outfile]} {

         # on traite ce fichier
         set newfile $::bdi_gui_planetes::widget(step1,file)$idframe$ext
         file copy -force -- $outfile $newfile
         gren_info "copie : $newfile\n"
         
         # next file
         incr idframe
         set outfile selection.$idframe$ext
      }
      incr idframe -1

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -state active

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $idframe
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $idframe / 5]
      set ::bdi_gui_planetes::widget(nbimages)    $idframe

      ::bdi_gui_planetes::buffer_clear
      array unset ::bdi_gui_planetes::buffer_list
      ::bdi_gui_planetes::voir 1

      return
   }




# ::bddimages::ressource ; ::bdi_gui_planetes::tri_chrono

   proc ::bdi_gui_planetes::tri_chrono { } {

      global bddconf

      array unset tab
      set index ""

      set ext [buf$::audace(bufNo) extension]
      set idframe 1
      set outfile $::bdi_gui_planetes::widget(step1,file)$idframe$ext
      while {[file exists $outfile]} {
         # on traite ce fichier
         buf$::audace(bufNo) load $outfile
         set dateiso [lindex [buf$::audace(bufNo) getkwd "DATE-OBS"] 1]
         lappend index $dateiso
         set tab($dateiso) $outfile
         
         # next file
         incr idframe
         set outfile $::bdi_gui_planetes::widget(step1,file)$idframe$ext
      }

      set index [lsort -increasing $index]
      
      set cpt 1
      foreach dateiso $index {
         set newfile i$cpt$ext
         file copy -force -- $tab($dateiso) $newfile
         gren_info "dateiso : $dateiso : $newfile\n"
         incr cpt
      }

      # on renomme les images comme a l origine 
      set i 1
      set outfile i$i$ext
      while {[file exists $outfile]} {
         # on traite ce fichier
         set newfile $::bdi_gui_planetes::widget(step1,file)$i$ext
         gren_info "$outfile -> : $newfile\n"
         file copy -force -- $outfile $newfile
         
         # next file
         incr i
         set outfile i$i$ext
      }
      set idframe [expr $i-1]
      
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -command "::bdi_gui_planetes::slide"
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -state active

      $::bdi_gui_planetes::widget(scrollbar,frame) configure -from 1
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -to $idframe
      $::bdi_gui_planetes::widget(scrollbar,frame) configure -tickinterval [expr $idframe / 5]
      set ::bdi_gui_planetes::widget(nbimages)    $idframe

      ::bdi_gui_planetes::buffer_clear
      array unset ::bdi_gui_planetes::buffer_list
      ::bdi_gui_planetes::voir 1





      return
   }
