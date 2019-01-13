#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_cdl_tools.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_cdl_tools.tcl
# Description    : Utilitaires pour le calcul des courbes de lumiere
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_cdl_tools.tcl 14424 2018-05-03 15:41:51Z fredvachier $
#


namespace eval ::atos_cdl_tools {

   variable obj
   variable ref
   variable radius
   variable mesure
   variable file_mesure
   variable sortie

   variable x_obj_threshold
   variable y_obj_threshold
   variable x_ref_threshold
   variable y_ref_threshold

   variable log

   set ::atos_cdl_tools::log 0

   #
   # Existance et chargement d un fichier time
   #
   proc ::atos_cdl_tools::init {  } {

      set ::atos_cdl_tools::radius 5

      set ::atos_cdl_tools::x_obj_threshold 6
      set ::atos_cdl_tools::y_obj_threshold 6
      set ::atos_cdl_tools::x_ref_threshold 6
      set ::atos_cdl_tools::y_ref_threshold 6

   }


   #
   # Existance et chargement d un fichier time
   #
   proc ::atos_cdl_tools::file_time_exist { visuNo } {

      if {![info exists ::atos_tools::nb_open_frames] || $::atos_tools::nb_open_frames == 0} {
         # Rien a faire car pas de video chargee
         return
      }

      for  {set x 1} {$x<=$::atos_tools::nb_open_frames} {incr x} {
         set ::atos_ocr_tools::timing($x,jd)  ""
         set ::atos_ocr_tools::timing($x,dateiso) ""
      }

      set filename [::atos_ocr_tools::get_filename_time]
      if { [file exists $filename] } {
         set reponse [tk_messageBox -message "Un fichier 'time' a ete trouve\nVoulez vous l'associer ?" -type yesno]
         if { $reponse == "yes"} {
            set f [open $filename "r"]
            set cpt 0
            set posmin 999999999999999
            set posmax 0
            while {1} {
                set line [gets $f]
                if {[eof $f]} {
                    close $f
                    break
                }
                if {$cpt > 2} {
                   set tab [ split $line "," ]
                   set id [string trim [lindex $tab 0] " "]
                   set jd [string trim [lindex $tab 1] " "]
                   set dateiso [string trim [lindex $tab 2] " "]
                   set ::atos_ocr_tools::timing($id,dateiso) $dateiso
                   set ::atos_ocr_tools::timing($id,jd) $jd
                   if {$id<$posmin} { set posmin $id }
                   if {$id>$posmax} { set posmax $id }
                   
                   #gren_info "$id -> $jd\n"
                }
                incr cpt
            }
            tk_messageBox -message "Fichier 'time' chargé." -type ok

            set reponse [tk_messageBox -message "Voulez vous ajuster la video sur les donnees datées ?" -type yesno]
            if { $reponse == "yes"} {

               $::atos_gui::frame(posmin) delete 0 end
               $::atos_gui::frame(posmax) delete 0 end
               
               $::atos_gui::frame(posmin) insert 0 $posmin
               $::atos_gui::frame(posmax) insert 0 $posmax
               
               ::atos_tools::crop $visuNo
            }


         }

      }

   }


   #
   # Nettoie la memoire de l outil
   #
   proc ::atos_cdl_tools::clear {  } {

      global color
      
      
      array unset ::atos_ocr_tools::timing
      array unset ::atos_cdl_tools::mesure
      array unset ::atos_cdl_tools::obj
      array unset ::atos_cdl_tools::ref
      array unset ::atos_cdl_tools::interpol

      set image ::atos_gui::frame(image,values)
      catch {$image.fenetre   configure -text "?" -fg $color(black)}
      catch {$image.intmin    configure -text "?" -fg $color(black)}
      catch {$image.intmax    configure -text "?" -fg $color(black)}
      catch {$image.intmoy    configure -text "?" -fg $color(black)}
      catch {$image.sigma     configure -text "?" -fg $color(black)}
      catch {$image.intensite configure -text "?" -fg $color(black)}
      catch {$image.mag       configure -text "?" -fg $color(black)}

      set objet $::atos_gui::frame(object,values)
      catch {$objet.position  configure -text "?" -fg $color(black)}
      catch {$objet.radius    configure -text "?" -fg $color(black)}
      catch {$objet.fint      configure -text "?" -fg $color(black)}
      catch {$objet.fwhm      configure -text "?" -fg $color(black)}
      catch {$objet.pixmax    configure -text "?" -fg $color(black)}
      catch {$objet.intensite configure -text "?" -fg $color(black)}
      catch {$objet.sigmafond configure -text "?" -fg $color(black)}
      catch {$objet.snint     configure -text "?" -fg $color(black)}
      catch {$objet.snpx      configure -text "?" -fg $color(black)}

      set reference $::atos_gui::frame(reference,values)
      catch {$reference.position  configure -text "?" -fg $color(black)}
      catch {$reference.radius    configure -text "?" -fg $color(black)}
      catch {$reference.fint      configure -text "?" -fg $color(black)}
      catch {$reference.fwhm      configure -text "?" -fg $color(black)}
      catch {$reference.pixmax    configure -text "?" -fg $color(black)}
      catch {$reference.intensite configure -text "?" -fg $color(black)}
      catch {$reference.sigmafond configure -text "?" -fg $color(black)}
      catch {$reference.snint     configure -text "?" -fg $color(black)}
      catch {$reference.snpx      configure -text "?" -fg $color(black)}
      
      $::atos_gui::frame(object,buttons).select    configure -relief raised
      $::atos_gui::frame(reference,buttons).select configure -relief raised
      $::atos_gui::frame(image,buttons).select     configure -relief raised


      $::atos_gui::frame(object,buttons).verifier configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      $::atos_gui::frame(reference,buttons).verifier configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      
      cleanmark
   }

   #
   # Ouverture d un flux
   #
   proc ::atos_cdl_tools::open_flux { visuNo } {
      
      # Nettoie la memoire
      ::atos_cdl_tools::clear 
      
      # Ouvre le flux
      ::atos_tools::open_flux $visuNo

      # Charge le fichier Time
      ::atos_cdl_tools::file_time_exist $visuNo

      # Affiche cut correct
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]

      return
   }

   #
   # Selection d un flux
   #
   proc ::atos_cdl_tools::select { visuNo } {

      # Nettoie la memoire
      ::atos_cdl_tools::clear 
      
      # Ouvre le flux
      ::atos_tools::select $visuNo 

      # Charge le fichier Time
      ::atos_cdl_tools::file_time_exist $visuNo

      # Affiche cut correct
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set autocuts [buf$bufNo autocuts]
      visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]

   }


   #
   # Sauvegarde la courbe lumiere  en memoire
   #
   proc ::atos_cdl_tools::save { visuNo } {

      if {![info exists ::atos_tools::nb_open_frames] || $::atos_tools::nb_open_frames == 0} {
         # Rien a faire car pas de video chargee
         return
      }

      if { $::atos_tools::traitement == "fits" } {
         set filename [file join ${::atos_tools::destdir} "${::atos_tools::prefix}"]
      }

      if { $::atos_tools::traitement == "avi" }  {
         set filename $::atos_tools::avi_filename
         if {![file exists $filename]} {
            ::console::affiche_erreur "Veuillez charger une video ...\n"
         }
      }

      set racinefilename "${filename}."

      set sortie 0
      set idfile 0
      while {$sortie == 0} {
         set idd [format "%05d" $idfile]
         set filename "${racinefilename}${idd}.csv"
         if { [file exists $filename] } {
         #::console::affiche_resultat "existe ${filename} ...\n"
         } else {
         set sortie 1
         }
         incr idfile
      }
      set filefreemat "${racinefilename}${idd}.freemat.dat"

      ::console::affiche_resultat "Sauvegarde dans ${filename} ...\n"
      set f1 [open $filename "w"]
      set f2 [open $filefreemat "w"]
      puts $f1 "# ** atos - Audela - Linux  * "
      puts $f1 "# FPS 25"
      set line "idframe,"
      append line "jd,"
      append line "dateiso,"
      append line "obj_fint,"
      append line "obj_pixmax,"
      append line "obj_intensite,"
      append line "obj_sigmafond,"
      append line "obj_snint,"
      append line "obj_snpx,"
      append line "obj_radius,"
      append line "obj_xpos,"
      append line "obj_ypos,"
      append line "obj_xfwhm,"
      append line "obj_yfwhm,"
      append line "ref_fint,"
      append line "ref_pixmax,"
      append line "ref_intensite,"
      append line "ref_sigmafond,"
      append line "ref_snint,"
      append line "ref_snpx,"
      append line "ref_radius,"
      append line "ref_xpos,"
      append line "ref_ypos,"
      append line "ref_xfwhm,"
      append line "ref_yfwhm,"
      append line "img_intmin,"
      append line "img_intmax,"
      append line "img_intmoy,"
      append line "img_sigma,"
      append line "img_mag,"
      append line "img_xsize,"
      append line "img_ysize"
      puts $f1 $line


      set relief [$::atos_gui::frame(geometrie).buttons.launch cget -relief]
      set sum [$::atos_gui::frame(geometrie).sum.val get]

      set sortie 0
      set idframe 0
      set cpt 0
      while {$sortie == 0} {

         incr idframe

         if {$idframe == $::atos_tools::nb_open_frames} {
            set sortie 1
         }

         if { [info exists ::atos_cdl_tools::mesure($idframe,mesure_obj)] && $::atos_cdl_tools::mesure($idframe,mesure_obj) == 1 } {
            set reste [expr $::atos_tools::nb_frames-$idframe]

            if {![info exists ::atos_ocr_tools::timing($idframe,jd)           ] } { gren_info "no jd)           \n" ; continue }
            if {![info exists ::atos_ocr_tools::timing($idframe,dateiso)      ] } { gren_info "no dateiso)      \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_fint)     ] } { gren_info "no obj_fint)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_pixmax)   ] } { gren_info "no obj_pixmax)   \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_intensite)] } { gren_info "no obj_intensite)\n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_sigmafond)] } { gren_info "no obj_sigmafond)\n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_snint)    ] } { gren_info "no obj_snint)    \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_snpx)     ] } { gren_info "no obj_snpx)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_radius)   ] } { gren_info "no obj_radius)   \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_xpos)     ] } { gren_info "no obj_xpos)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_ypos)     ] } { gren_info "no obj_ypos)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_xfwhm)    ] } { gren_info "no obj_xfwhm)    \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,obj_yfwhm)    ] } { gren_info "no obj_yfwhm)    \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_fint)     ] } { gren_info "no ref_fint)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_pixmax)   ] } { gren_info "no ref_pixmax)   \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_intensite)] } { gren_info "no ref_intensite)\n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_sigmafond)] } { gren_info "no ref_sigmafond)\n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_snint)    ] } { gren_info "no ref_snint)    \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_snpx)     ] } { gren_info "no ref_snpx)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_radius)   ] } { gren_info "no ref_radius)   \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_xpos)     ] } { gren_info "no ref_xpos)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_ypos)     ] } { gren_info "no ref_ypos)     \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_xfwhm)    ] } { gren_info "no ref_xfwhm)    \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,ref_yfwhm)    ] } { gren_info "no ref_yfwhm)    \n" ; continue }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_intmin)   ] } { set ::atos_cdl_tools::mesure($idframe,img_intmin) 0 }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_intmax)   ] } { set ::atos_cdl_tools::mesure($idframe,img_intmax) 0 }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_intmoy)   ] } { set ::atos_cdl_tools::mesure($idframe,img_intmoy) 0 }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_sigma)    ] } { set ::atos_cdl_tools::mesure($idframe,img_sigma)  0 }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_mag)      ] } { set ::atos_cdl_tools::mesure($idframe,img_mag)    0 }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_xsize)    ] } { set ::atos_cdl_tools::mesure($idframe,img_xsize)  0 }
            if {![info exists ::atos_cdl_tools::mesure($idframe,img_ysize)    ] } { set ::atos_cdl_tools::mesure($idframe,img_ysize)  0 }


            # Alors correction temporelle immediate liée a l addition de frame
            if {$relief=="sunken" && $sum>1} {
               #puts $f1 "\n  sum = $sum"
               set tabdate ""
               for {set i 1} {$i <= $sum} {incr i} {
                  set idf [expr $idframe-1+$i]
                  if {![info exists ::atos_ocr_tools::timing($idf,jd)] } { continue } 
                  lappend tabdate $::atos_ocr_tools::timing($idf,jd)
                  #puts $f1  "$idf :: $::atos_ocr_tools::timing($idf,jd) : $::atos_ocr_tools::timing($idf,dateiso)"
               }
               set jd [::math::statistics::mean $tabdate]
               
               # dmedf : duree moyenne entre 2 dates
               #set jd [expr $jd + $::atos_ocr_tools::dmedf / 86400.0]
               set dateiso [mc_date2iso8601 $jd]

               #puts $f1  "sol : $jd : $dateiso"
            } else {
               set jd $::atos_ocr_tools::timing($idframe,jd)
               set dateiso $::atos_ocr_tools::timing($idframe,dateiso)
            }

            set line "$idframe,"
            append line "$jd,"
            append line "$dateiso,"
            append line "$::atos_cdl_tools::mesure($idframe,obj_fint),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_pixmax),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_intensite),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_sigmafond),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_snint),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_snpx),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_radius),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_xpos),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_ypos),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_xfwhm),"
            append line "$::atos_cdl_tools::mesure($idframe,obj_yfwhm),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_fint),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_pixmax),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_intensite),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_sigmafond),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_snint),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_snpx),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_radius),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_xpos),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_ypos),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_xfwhm),"
            append line "$::atos_cdl_tools::mesure($idframe,ref_yfwhm),"
            append line "$::atos_cdl_tools::mesure($idframe,img_intmin),"
            append line "$::atos_cdl_tools::mesure($idframe,img_intmax)," 
            append line "$::atos_cdl_tools::mesure($idframe,img_intmoy)," 
            append line "$::atos_cdl_tools::mesure($idframe,img_sigma)," 
            append line "$::atos_cdl_tools::mesure($idframe,img_mag)," 
            append line "$::atos_cdl_tools::mesure($idframe,img_xsize),"
            append line "$::atos_cdl_tools::mesure($idframe,img_ysize)"

            puts $f1 $line
            
            # Pour freemat
            if {$::atos_cdl_tools::mesure($idframe,obj_fint)>0 && $::atos_cdl_tools::mesure($idframe,ref_fint) > 0} {
               puts $f2 "$idframe $::atos_cdl_tools::mesure($idframe,obj_fint) $::atos_cdl_tools::mesure($idframe,ref_fint)"
            }
            
            incr cpt
         }

      }

      close $f1
      close $f2
      ::console::affiche_resultat "Nb of saved frames = $cpt\n.. Fin ..\n"

   }







   #
   # affiche un rond
   #
   proc ::atos_cdl_tools::affich_un_rond { x y color radius { width 2 } } {
   
      global audace
   
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
   
      $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags cadres -width $width
   
   }






   #
   # Effectue la photometrie de l objet et l affiche
   #
   proc ::atos_cdl_tools::mesure_obj { xsm ysm visuNo radius } {

      global color

      set objet $::atos_gui::frame(object,values)
      set err 0
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      set xsm_save $xsm
      set ysm_save $ysm

      # Mesure le photocentre
      set err [ catch { set valeurs  [::atos_photom::mesure_obj $xsm $ysm $radius $bufNo] } msg ]

      if {$::atos_cdl_tools::log} { gren_info "mesure_obj: $::atos_tools::cur_idframe [lindex $valeurs 5] \n" }

      if {$err > 0} {
         ::console::affiche_erreur $msg
         $objet.position  configure -text "?" -fg $color(red)
         $objet.radius    configure -text "?" -fg $color(red)
         $objet.fint      configure -text "?" -fg $color(red)
         $objet.fwhm      configure -text "?" -fg $color(red)
         $objet.pixmax    configure -text "?" -fg $color(red)
         $objet.intensite configure -text "?" -fg $color(red)
         $objet.sigmafond configure -text "?" -fg $color(red)
         $objet.snint     configure -text "?" -fg $color(red)
         $objet.snpx      configure -text "?" -fg $color(red)
         return -1
      }

      set xsm         [lindex $valeurs 0]
      set ysm         [lindex $valeurs 1]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 3]
      set fwhm        [lindex $valeurs 4]
      set fluxintegre [lindex $valeurs 5]
      set errflux     [lindex $valeurs 6]
      set pixmax      [lindex $valeurs 7]
      set intensite   [lindex $valeurs 8]
      set sigmafond   [lindex $valeurs 9]
      set snint       [lindex $valeurs 10]
      set snpx        [lindex $valeurs 11]
      set radius      [lindex $valeurs 12]


      set lost_obj 0
      if {[expr abs($xsm_save - $xsm)] <= $::atos_cdl_tools::x_obj_threshold} {
         set ::atos_cdl_tools::obj(x) [format "%4.2f" $xsm]
      } else {
         set lost_obj 1
         set ::atos_cdl_tools::obj(x) [format "%4.2f" $xsm_save]
      }
      if {[expr abs($ysm_save - $ysm)] <= $::atos_cdl_tools::y_obj_threshold} {
         set ::atos_cdl_tools::obj(y) [format "%4.2f" $ysm]
      } else {
         set lost_obj 1
         set ::atos_cdl_tools::obj(y) [format "%4.2f" $ysm_save]
      }

      set visupos       "[format "%4.2f" $::atos_cdl_tools::obj(x)] / [format "%4.2f" $::atos_cdl_tools::obj(y)]"
      set visuradius    [format "%5.2f" $radius]
      set visufint      [format "%5.2f" $fluxintegre]
      set visufwhm      "[format "%4.2f" $fwhmx] / [format "%4.2f" $fwhmy]"
      set visupixmax    [format "%5.2f" $pixmax]
      set visuintensite [format "%5.2f" $intensite]
      set visusigmafond [format "%5.2f" $sigmafond]
      set visusnint     [format "%5.2f" $snint]
      set visusnpx      [format "%5.2f" $snpx]

      $objet.position     configure -text "$visupos"       -fg $color(blue)
      $objet.radius       configure -text "$visuradius"    -fg $color(blue)
      $objet.fint         configure -text "$visufint"      -fg $color(blue)
      $objet.fwhm         configure -text "$visufwhm"      -fg $color(blue)
      $objet.pixmax       configure -text "$visupixmax"    -fg $color(blue)
      $objet.intensite    configure -text "$visuintensite" -fg $color(blue)
      $objet.sigmafond    configure -text "$visusigmafond" -fg $color(blue)
      $objet.snint        configure -text "$visusnint"     -fg $color(blue)
      $objet.snpx         configure -text "$visusnpx"      -fg $color(blue)

      ::atos_cdl_tools::affich_un_rond [expr $::atos_cdl_tools::obj(x) + 1] [expr $::atos_cdl_tools::obj(y) - 1] "#0FF342" $radius

      # op ternaire :: set a [expr { $::atos_cdl_tools::methode_suivi =="Auto" ? 1 : 0 } ]

      switch $::atos_cdl_tools::methode_suivi {
         "Auto" - default { if {$lost_obj == 1} { return -1 } else { return 0 } }
         "Interpolation" { return 0 }
      }

   }



   #
   # Effectue la photometrie de la reference et l affiche
   #
   proc ::atos_cdl_tools::mesure_ref {xsm ysm visuNo radius} {

      global color

      set reference $::atos_gui::frame(reference,values)
      set err 0
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      set xsm_save $xsm
      set ysm_save $ysm

      # Mesure du photocentre
      set err [ catch { set valeurs  [::atos_photom::mesure_obj $xsm $ysm $radius $bufNo] } msg ]

      if {$err>0} {
         ::console::affiche_erreur $msg
         $reference.position  configure -text "?" -fg $color(red)
         $reference.radius    configure -text "?" -fg $color(red)
         $reference.fint      configure -text "?" -fg $color(red)
         $reference.fwhm      configure -text "?" -fg $color(red)
         $reference.pixmax    configure -text "?" -fg $color(red)
         $reference.intensite configure -text "?" -fg $color(red)
         $reference.sigmafond configure -text "?" -fg $color(red)
         $reference.snint     configure -text "?" -fg $color(red)
         $reference.snpx      configure -text "?" -fg $color(red)
         return -1
      }

      set xsm         [lindex $valeurs 0]
      set ysm         [lindex $valeurs 1]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 3]
      set fwhm        [lindex $valeurs 4]
      set fluxintegre [lindex $valeurs 5]
      set errflux     [lindex $valeurs 6]
      set pixmax      [lindex $valeurs 7]
      set intensite   [lindex $valeurs 8]
      set sigmafond   [lindex $valeurs 9]
      set snint       [lindex $valeurs 10]
      set snpx        [lindex $valeurs 11]
      set radius      [lindex $valeurs 12]

      set lost_ref 0
      if {[expr abs($xsm_save - $xsm)] <= $::atos_cdl_tools::x_ref_threshold} {
         set ::atos_cdl_tools::ref(x) [format "%4.2f" $xsm]
      } else {
         set lost_ref 1
         set ::atos_cdl_tools::ref(x) [format "%4.2f" $xsm_save]
      }
      if {[expr abs($ysm_save - $ysm)] <= $::atos_cdl_tools::y_ref_threshold} {
         set ::atos_cdl_tools::ref(y) [format "%4.2f" $ysm]
      } else {
         set lost_ref 1
         set ::atos_cdl_tools::ref(y) [format "%4.2f" $ysm_save]
      }

      set visupos       "[format "%4.2f" $xsm] / [format "%4.2f" $ysm]"
      set visuradius    [format "%5.2f" $radius]
      set visufint      [format "%5.2f" $fluxintegre]
      set visufwhm      "[format "%4.2f" $fwhmx] / [format "%4.2f" $fwhmy]"
      set visupixmax    [format "%5.2f" $pixmax]
      set visuintensite [format "%5.2f" $intensite]
      set visusigmafond [format "%5.2f" $sigmafond]
      set visusnint     [format "%5.2f" $snint]
      set visusnpx      [format "%5.2f" $snpx]

      $reference.position     configure -text "$visupos"       -fg $color(blue)
      $reference.radius       configure -text "$visuradius"    -fg $color(blue)
      $reference.fint         configure -text "$visufint"      -fg $color(blue)
      $reference.fwhm         configure -text "$visufwhm"      -fg $color(blue)
      $reference.pixmax       configure -text "$visupixmax"    -fg $color(blue)
      $reference.intensite    configure -text "$visuintensite" -fg $color(blue)
      $reference.sigmafond    configure -text "$visusigmafond" -fg $color(blue)
      $reference.snint        configure -text "$visusnint"     -fg $color(blue)
      $reference.snpx         configure -text "$visusnpx"      -fg $color(blue)

      ::atos_cdl_tools::affich_un_rond [expr $::atos_cdl_tools::ref(x) + 1] [expr $::atos_cdl_tools::ref(y) - 1] red $radius

      switch $::atos_cdl_tools::methode_suivi {
         "Auto" - default { if {$lost_ref == 1} { return -1 } else { return 0 } }
         "Interpolation" { return 0 }
      }

   }



   #
   # Analyse de l image complete
   #
   proc ::atos_cdl_tools::select_fullimg { visuNo } {

      global color

      set frm_image $::atos_gui::frame(image,values) 
      set select_image $::atos_gui::frame(image,buttons).select

      set statebutton [ $select_image cget -relief]

      # desactivation
      if {$statebutton=="sunken"} {
         $frm_image.fenetre configure -text   "?"
         $frm_image.intmin  configure -text   "?"
         $frm_image.intmax  configure -text   "?"
         $frm_image.intmoy  configure -text   "?"
         $frm_image.sigma   configure -text   "?"
         $frm_image.mag     configure -text   "?"
         $select_image configure -relief raised
         return
      }

      # activation
      if {$statebutton=="raised"} {

         # Recuperation du Rectangle de l image
         set rect [ ::confVisu::getBox $visuNo ]

         # Affichage de la taille de la fenetre
         if {$rect==""} {
            $frm_image.fenetre configure -text "Error" -fg $color(red)
            set ::atos_photom::rect_img ""
         } else {
            set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
            set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
            $frm_image.fenetre configure -text "${taillex}x${tailley}" -fg $color(blue)
            set ::atos_photom::rect_img $rect
         }
         ::atos_cdl_tools::get_fullimg $visuNo
         $select_image  configure -relief sunken
         return

      }

   }







   #
   # Selection de la zone dans l image correspond a l image effective.
   # Sans l inscrustation de la date par exemple
   #
   proc ::atos_cdl_tools::get_fullimg { visuNo } {

      #::console::affiche_resultat "Arect_img = $::atos_photom::rect_img \n"
      set image $::atos_gui::frame(image,values)
      
      if { ! [info exists ::atos_photom::rect_img] } {
         return
      }

      if {$::atos_photom::rect_img==""} {

         $image.fenetre configure -text "?"
         $image.intmin  configure -text "?"
         $image.intmax  configure -text "?"
         $image.intmoy  configure -text "?"
         $image.sigma   configure -text "?"
         $image.mag     configure -text "?"

      } else {

         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set stat [buf$bufNo stat $::atos_photom::rect_img]
         $image.intmin configure -text [format "%9.3f" [lindex $stat 3]]
         $image.intmax configure -text [format "%9.3f" [lindex $stat 2]]
         $image.intmoy configure -text [format "%9.3f" [lindex $stat 4]]
         $image.sigma  configure -text [format "%7.3f" [lindex $stat 5]]
         set flux [buf$bufNo flux $::atos_photom::rect_img]
         $image.mag configure -text [format "%9.5f" [expr -2.5*log10([lindex $flux 0])]]

      }

   }




   #
   # Selection d un objet a partir d une getBox sur l image
   #
   proc ::atos_cdl_tools::select_source { visuNo type } {

      global color

      switch $type {
         "object" {
            set frm_source $::atos_gui::frame(object,values) 
            set select $::atos_gui::frame(object,buttons).select
         }
         "reference" {
            set frm_source $::atos_gui::frame(reference,values) 
            set select $::atos_gui::frame(reference,buttons).select
         }
      }

      set statebutton [ $select cget -relief]

      # activation
      if {$statebutton=="raised"} {

         set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]

         if {$err>0 || $rect ==""} {
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm_source.position configure -text "Selectionnez un cadre" -fg $color(red)
            return
         }

         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set err [ catch {set valeurs  [::atos_photom::select_obj $rect $bufNo]} msg ]

         if {$err>0} {
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Mesure Photometrique impossible\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm_source.position configure -text "Error" -fg $color(red)
            return
         }
         set xsm [lindex $valeurs 0]
         set ysm [lindex $valeurs 1]

         $frm_source.radius configure -text $::atos_cdl_tools::radius 

         switch $type {
            "object" {
               ::atos_cdl_tools::mesure_obj $xsm $ysm $visuNo $::atos_cdl_tools::radius
            }
            "reference" {
               ::atos_cdl_tools::mesure_ref $xsm $ysm $visuNo $::atos_cdl_tools::radius
            }
         }

         $select  configure -relief sunken
         return
      }

      # desactivation
      if {$statebutton=="sunken"} {

         $frm_source.position  configure -text "?"
         $frm_source.radius    configure -text "?"
         $frm_source.fint      configure -text "?"
         $frm_source.fwhm      configure -text "?"
         $frm_source.pixmax    configure -text "?"
         $frm_source.intensite configure -text "?"
         $frm_source.sigmafond configure -text "?"
         $frm_source.snint     configure -text "?"
         $frm_source.snpx      configure -text "?"

         $select  configure -relief raised
         return
      }

      $select  configure -relief raised
      return

   }




   proc ::atos_cdl_tools::set_gui_source { visuNo type } {
      
      global color

      set objet      $::atos_gui::frame(object,values) 
      set reference  $::atos_gui::frame(reference,values) 
      set radius     [$::atos_gui::frame($type,values).radius cget -text]
      set verif      $::atos_gui::frame($type,buttons).verifier
      
      
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "radius = $radius \n"
      ::console::affiche_resultat "type = $type \n"

      if {[info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif)]} {

         if {$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) == 1} {
            
            # traitement des source verifiee
            $verif configure -bg "#00891b" -fg $color(white)

            switch $type {
               "object" {

                  #gren_info "verif = 1 : xy av : $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)\n"
                  #gren_info "verif = 1 : xy av : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)\n"

                  set ::atos_cdl_tools::obj(x) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos)
                  set ::atos_cdl_tools::obj(y) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)

                  $objet.position    configure -text  "$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) / $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)"    -fg $color(blue)
                  $objet.radius      configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_radius) -fg $color(blue)
                  $objet.fint        configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_fint)    -fg $color(blue)
                  $objet.fwhm        configure -text  "$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xfwhm) / $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_yfwhm)"    -fg $color(blue)
                  $objet.pixmax      configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_pixmax)    -fg $color(blue)
                  $objet.intensite   configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_intensite)    -fg $color(blue)
                  $objet.sigmafond   configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_sigmafond)    -fg $color(blue)
                  $objet.snint       configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_snint)     -fg $color(blue)
                  $objet.snpx        configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_snpx)    -fg $color(blue)
                  
  gren_info "cmd: ::atos_cdl_tools::affich_un_rond [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) + 1] [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos) - 1] \"#0FF342\" $radius\n"
                  ::atos_cdl_tools::affich_un_rond [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) + 1] [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos) - 1] "#0FF342"   $radius
               }
               "reference" {
               
                  #gren_info "verif = 1 : xy av : $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y)\n"
                  #gren_info "verif = 1 : xy av : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)\n"

                  set ::atos_cdl_tools::ref(x) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos)
                  set ::atos_cdl_tools::ref(y) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)

                  $reference.position    configure -text  "$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) / $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)" -fg $color(blue)
                  $reference.radius      configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_radius) -fg $color(blue)
                  $reference.fint        configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_fint)    -fg $color(blue)
                  $reference.fwhm        configure -text  "$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xfwhm) / $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_yfwhm)" -fg $color(blue)
                  $reference.pixmax      configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_pixmax)    -fg $color(blue)
                  $reference.intensite   configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_intensite)    -fg $color(blue)
                  $reference.sigmafond   configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_sigmafond)    -fg $color(blue)
                  $reference.snint       configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_snint)     -fg $color(blue)
                  $reference.snpx        configure -text  $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_snpx)    -fg $color(blue)
               
  gren_info "cmd: ::atos_cdl_tools::affich_un_rond [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) + 1] [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos) - 1] red $radius\n"
                  ::atos_cdl_tools::affich_un_rond [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) + 1] [expr $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos) - 1] red $radius
               }
            }

            return

         } else {

            $verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         }
         
      } else {

         $verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)

      }
      
      switch $type {
         "object" {
            if { [info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos)] && 
                 [info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)]  } {
                set xsm $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos)
                set ysm $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)
                gren_info "obj: xsm ysm av : $xsm $ysm\n"
                ::atos_cdl_tools::mesure_obj $xsm $ysm $visuNo $radius
                gren_info "obj: xsm ysm ap : $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)\n"
            }
            gren_info "xy av : $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)\n"
            #::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $radius
            #gren_info "xy ap : $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)\n"
         }
         "reference" {
            if { [info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos)] && 
                 [info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)]  } {
                set xsm $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos)
                set ysm $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)
                gren_info "xsm ysm av : $xsm $ysm\n"
                ::atos_cdl_tools::mesure_ref $xsm $ysm $visuNo $radius
                gren_info "ref: xsm ysm ap : $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)\n"
            }
           gren_info "obj: xsm ysm ap : $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)\n"
            #::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $radius
         }
      }

   }





   #
   # Retour Rapide
   #
   proc ::atos_cdl_tools::quick_prev_image { visuNo } {

      cleanmark
      
      ::atos_tools::quick_prev_image $visuNo

      set select_objet     $::atos_gui::frame(object,buttons).select
      set select_reference $::atos_gui::frame(reference,buttons).select
      set select_image     $::atos_gui::frame(image,buttons).select

      set statebutton [ $select_objet cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "object" 
      }
      set statebutton [ $select_reference cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "reference" 
      }
      set statebutton [ $select_image cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo
      }

   }


   #
   # avance rapide
   #
   proc ::atos_cdl_tools::quick_next_image { visuNo } {

      cleanmark
 
      ::atos_tools::quick_next_image $visuNo

      set select_objet     $::atos_gui::frame(object,buttons).select
      set select_reference $::atos_gui::frame(reference,buttons).select
      set select_image     $::atos_gui::frame(image,buttons).select

      set statebutton [ $select_objet cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "object" 
      }
      set statebutton [ $select_reference cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "reference" 
      }
      set statebutton [ $select_image cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo
      }

   }


   #
   # Passe a l image suivante
   #
   proc ::atos_cdl_tools::next_image { visuNo } {

      cleanmark
      global color

      set select_objet     $::atos_gui::frame(object,buttons).select
      set select_reference $::atos_gui::frame(reference,buttons).select
      set select_image     $::atos_gui::frame(image,buttons).select

      set geometrie $::atos_gui::frame(geometrie)
      set relief [$geometrie.buttons.launch cget -relief]
      set bin [$geometrie.binning.val get]
      set sum [$geometrie.sum.val get]

      if {$relief == "sunken"} {
         incr ::atos_tools::cur_idframe [expr $sum-1]
         ::atos_cdl_tools::start_next_image $visuNo $sum $bin 0
      } else {
         ::atos_tools::next_image $visuNo 
      
      }

      # Object
      set statebutton [ $select_objet cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "object" 
      }
      # Reference
      set statebutton [ $select_reference cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "reference" 
      }
      set statebutton [ $select_image cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo
      }

   }


   #
   # Passe a l image precedente
   #
   proc ::atos_cdl_tools::prev_image { visuNo } {

      cleanmark

      set select_objet     $::atos_gui::frame(object,buttons).select
      set select_reference $::atos_gui::frame(reference,buttons).select
      set select_image     $::atos_gui::frame(image,buttons).select

      ::atos_tools::prev_image $visuNo

      set statebutton [ $select_objet cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "object" 
      }
      set statebutton [ $select_reference cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::set_gui_source $visuNo "reference" 
      }
      set statebutton [ $select_image cget -relief]
      if { $statebutton=="sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo
      }

   }


   proc ::atos_cdl_tools::set_mesure_source_from_gui { idframe type } {


      switch $type {
         "object" {

            set frm_objet        $::atos_gui::frame(object,values) 

            # mesure objet
            set ::atos_cdl_tools::mesure($idframe,mesure_obj) 1
            set ::atos_cdl_tools::mesure($idframe,obj_radius)    [$frm_objet.radius    cget -text]
            set ::atos_cdl_tools::mesure($idframe,obj_fint)      [$frm_objet.fint      cget -text]
            set ::atos_cdl_tools::mesure($idframe,obj_pixmax)    [$frm_objet.pixmax    cget -text]
            set ::atos_cdl_tools::mesure($idframe,obj_intensite) [$frm_objet.intensite cget -text]
            set ::atos_cdl_tools::mesure($idframe,obj_sigmafond) [$frm_objet.sigmafond cget -text]
            set ::atos_cdl_tools::mesure($idframe,obj_snint)     [$frm_objet.snint     cget -text]
            set ::atos_cdl_tools::mesure($idframe,obj_snpx)      [$frm_objet.snpx      cget -text]

            set position  [$frm_objet.position  cget -text]
            set poslist [split $position "/"]
            set ::atos_cdl_tools::mesure($idframe,obj_xpos) [lindex $poslist 0]
            set ::atos_cdl_tools::mesure($idframe,obj_ypos) [lindex $poslist 1]
            if {$::atos_cdl_tools::mesure($idframe,obj_ypos)==""} { set ::atos_cdl_tools::mesure($idframe,obj_ypos) "?" }

            set fwhm      [$frm_objet.fwhm cget -text]
            set fwhmlist [split $fwhm "/"]
            set ::atos_cdl_tools::mesure($idframe,obj_xfwhm) [lindex $fwhmlist 0]
            set ::atos_cdl_tools::mesure($idframe,obj_yfwhm) [lindex $fwhmlist 1]
            if {$::atos_cdl_tools::mesure($idframe,obj_yfwhm)==""} {set ::atos_cdl_tools::mesure($idframe,obj_yfwhm) "?" }

         }

         "reference" {

            set frm_reference    $::atos_gui::frame(reference,values) 

            # mesure reference
            set ::atos_cdl_tools::mesure($idframe,ref_radius)    [$frm_reference.radius    cget -text]
            set ::atos_cdl_tools::mesure($idframe,ref_fint)      [$frm_reference.fint      cget -text]
            set ::atos_cdl_tools::mesure($idframe,ref_pixmax)    [$frm_reference.pixmax    cget -text]
            set ::atos_cdl_tools::mesure($idframe,ref_intensite) [$frm_reference.intensite cget -text]
            set ::atos_cdl_tools::mesure($idframe,ref_sigmafond) [$frm_reference.sigmafond cget -text]
            set ::atos_cdl_tools::mesure($idframe,ref_snint)     [$frm_reference.snint     cget -text]
            set ::atos_cdl_tools::mesure($idframe,ref_snpx)      [$frm_reference.snpx      cget -text]

            set position  [$frm_reference.position  cget -text]
            set poslist [split $position "/"]
            set ::atos_cdl_tools::mesure($idframe,ref_xpos) [lindex $poslist 0]
            set ::atos_cdl_tools::mesure($idframe,ref_ypos) [lindex $poslist 1]
            if {$::atos_cdl_tools::mesure($idframe,ref_ypos)==""} { set ::atos_cdl_tools::mesure($idframe,ref_ypos) "?" }

            set fwhm      [$frm_reference.fwhm cget -text]
            set fwhmlist [split $fwhm "/"]
            set ::atos_cdl_tools::mesure($idframe,ref_xfwhm) [lindex $fwhmlist 0]
            set ::atos_cdl_tools::mesure($idframe,ref_yfwhm) [lindex $fwhmlist 1]
            if {$::atos_cdl_tools::mesure($idframe,ref_yfwhm)==""} {set ::atos_cdl_tools::mesure($idframe,ref_yfwhm) "?" }

         }
      }

   }

   proc ::atos_cdl_tools::set_mesure_from_gui { idframe } {

      set frm_image        $::atos_gui::frame(image,values) 
      set frm_objet        $::atos_gui::frame(object,values) 
      set frm_reference    $::atos_gui::frame(reference,values) 

      # mesure objet
      set ::atos_cdl_tools::mesure($idframe,mesure_obj) 1
      set ::atos_cdl_tools::mesure($idframe,obj_radius)    [$frm_objet.radius    cget -text]
      set ::atos_cdl_tools::mesure($idframe,obj_fint)      [$frm_objet.fint      cget -text]
      set ::atos_cdl_tools::mesure($idframe,obj_pixmax)    [$frm_objet.pixmax    cget -text]
      set ::atos_cdl_tools::mesure($idframe,obj_intensite) [$frm_objet.intensite cget -text]
      set ::atos_cdl_tools::mesure($idframe,obj_sigmafond) [$frm_objet.sigmafond cget -text]
      set ::atos_cdl_tools::mesure($idframe,obj_snint)     [$frm_objet.snint     cget -text]
      set ::atos_cdl_tools::mesure($idframe,obj_snpx)      [$frm_objet.snpx      cget -text]

      if {$::atos_cdl_tools::log} { gren_info "set_mesure_from_gui: $idframe ::  $::atos_ocr_tools::timing($idframe,dateiso) ::  $::atos_cdl_tools::mesure($idframe,obj_fint)\n" }

      set position  [$frm_objet.position  cget -text]
      set poslist [split $position "/"]
      set ::atos_cdl_tools::mesure($idframe,obj_xpos) [lindex $poslist 0]
      set ::atos_cdl_tools::mesure($idframe,obj_ypos) [lindex $poslist 1]
      if {$::atos_cdl_tools::mesure($idframe,obj_ypos)==""} { set ::atos_cdl_tools::mesure($idframe,obj_ypos) "?" }

      set fwhm [$frm_objet.fwhm cget -text]
      set fwhmlist [split $fwhm "/"]
      set ::atos_cdl_tools::mesure($idframe,obj_xfwhm) [lindex $fwhmlist 0]
      set ::atos_cdl_tools::mesure($idframe,obj_yfwhm) [lindex $fwhmlist 1]
      if {$::atos_cdl_tools::mesure($idframe,obj_yfwhm)==""} {set ::atos_cdl_tools::mesure($idframe,obj_yfwhm) "?" }

      # mesure reference
      set ::atos_cdl_tools::mesure($idframe,ref_radius)    [$frm_reference.radius    cget -text]
      set ::atos_cdl_tools::mesure($idframe,ref_fint)      [$frm_reference.fint      cget -text]
      set ::atos_cdl_tools::mesure($idframe,ref_pixmax)    [$frm_reference.pixmax    cget -text]
      set ::atos_cdl_tools::mesure($idframe,ref_intensite) [$frm_reference.intensite cget -text]
      set ::atos_cdl_tools::mesure($idframe,ref_sigmafond) [$frm_reference.sigmafond cget -text]
      set ::atos_cdl_tools::mesure($idframe,ref_snint)     [$frm_reference.snint     cget -text]
      set ::atos_cdl_tools::mesure($idframe,ref_snpx)      [$frm_reference.snpx      cget -text]

      set position  [$frm_reference.position  cget -text]
      set poslist [split $position "/"]
      set ::atos_cdl_tools::mesure($idframe,ref_xpos) [lindex $poslist 0]
      set ::atos_cdl_tools::mesure($idframe,ref_ypos) [lindex $poslist 1]
      if {$::atos_cdl_tools::mesure($idframe,ref_ypos)==""} { set ::atos_cdl_tools::mesure($idframe,ref_ypos) "?" }

      set fwhm      [$frm_reference.fwhm cget -text]
      set fwhmlist [split $fwhm "/"]
      set ::atos_cdl_tools::mesure($idframe,ref_xfwhm) [lindex $fwhmlist 0]
      set ::atos_cdl_tools::mesure($idframe,ref_yfwhm) [lindex $fwhmlist 1]
      if {$::atos_cdl_tools::mesure($idframe,ref_yfwhm)==""} {set ::atos_cdl_tools::mesure($idframe,ref_yfwhm) "?" }

      # mesure image
      set ::atos_cdl_tools::mesure($idframe,img_intmin)  [$frm_image.intmin  cget -text]
      set ::atos_cdl_tools::mesure($idframe,img_intmax)  [$frm_image.intmax  cget -text]
      set ::atos_cdl_tools::mesure($idframe,img_intmoy)  [$frm_image.intmoy  cget -text]
      set ::atos_cdl_tools::mesure($idframe,img_sigma)   [$frm_image.sigma   cget -text]
      set ::atos_cdl_tools::mesure($idframe,img_mag)     [$frm_image.mag     cget -text]

      set fenetre  [$frm_image.fenetre cget -text]
      set fenetrelist [split $fenetre "x"]
      set ::atos_cdl_tools::mesure($idframe,img_xsize) [lindex $fenetrelist 0]
      set ::atos_cdl_tools::mesure($idframe,img_ysize) [lindex $fenetrelist 1]
      if {$::atos_cdl_tools::mesure($idframe,img_ysize)==""} { set ::atos_cdl_tools::mesure($idframe,img_ysize) "?" }

   }


   proc ::atos_cdl_tools::set_gui_from_mesure { idframe } {

      set frm_image        $::atos_gui::frame(image,values) 
      set frm_objet        $::atos_gui::frame(object,values) 
      set frm_reference    $::atos_gui::frame(reference,values) 

   }

   #
   # Lance les mesures photometriques
   #
   proc ::atos_cdl_tools::start { visuNo } {

      set bufNo [::confVisu::getBufNo $visuNo]

      set frm_info_load    $::atos_gui::frame(info_load)
      set frm_start        $::atos_gui::frame(buttons,start)
      set photometrie      $::atos_gui::frame(photometrie)
      set geometrie        $::atos_gui::frame(geometrie)
      set correction       $::atos_gui::frame(correction)

      set frm_image        $::atos_gui::frame(image,values) 
      set frm_objet        $::atos_gui::frame(object,values) 
      set frm_reference    $::atos_gui::frame(reference,values) 

      set select_image     $::atos_gui::frame(image,buttons).select
      set select_objet     $::atos_gui::frame(object,buttons).select
      set select_reference $::atos_gui::frame(reference,buttons).select

      set bin [$geometrie.binning.val get]
      set sum [$geometrie.sum.val get]

      if { [$frm_info_load.status cget -text ] != "Loaded"} { 
         gren_erreur "Aucune Video\n"
         return 
      }

      if {$::atos_cdl_tools::log} {
         ::console::affiche_resultat "nb_frames      = $::atos_tools::nb_frames      \n"
         ::console::affiche_resultat "nb_open_frames = $::atos_tools::nb_open_frames \n"
         ::console::affiche_resultat "cur_idframe    = $::atos_tools::cur_idframe    \n"
         ::console::affiche_resultat "frame_begin    = $::atos_tools::frame_begin    \n"
         ::console::affiche_resultat "frame_end      = $::atos_tools::frame_end      \n"
         ::console::affiche_resultat "methode_suivi  = $::atos_cdl_tools::methode_suivi \n"
         ::console::affiche_resultat "Binning= $bin \n"
         ::console::affiche_resultat "Bloc de $sum images \n"
      }

      set ::atos_cdl_tools::sortie 0
      set cpt 0
      $frm_start configure -image .stop
      $frm_start configure -relief sunken
      $frm_start configure -command " ::atos_cdl_tools::stop $visuNo"


      set tt0 [clock clicks -milliseconds]

      # Traitement des darks
      set novisu 0
      set okdark 0
      if {$::atos_cdl_tools::usedark } {
         set masterdark [$correction.dark_path get]
         if {[file exists $masterdark]} {
            set okdark 1
            set novisu 1
            loadima $masterdark
            set stat [buf$bufNo stat]
            set meandark [format "%.0f" [lindex $stat 4]]
            gren_info "Correction par le Darks actif\n"
            gren_info "file = $masterdark\n"
            gren_info "meandark = $meandark\n"
         }
      }

      # Traitement des flats
      set okflat 0
      if {$::atos_cdl_tools::useflat } {
         set masterflat [$correction.flat_path get]
         if {[file exists $masterflat]} {
            set okflat 1
            set novisu 1
            loadima $masterflat
            set stat [buf$bufNo stat]
            set meanflat [format "%.0f" [lindex $stat 4]]
            gren_info "Correction par le Flat actif\n"
            gren_info "file = $masterflat\n"
            gren_info "meanflat = $meanflat\n"
         }
      }

      set err [catch {::atos_cdl_tools::suivi_init} msg]
      if {$err} {
         gren_erreur "Erreur : $msg\n"
         set ::atos_cdl_tools::sortie 1
      }
      
      #set ::atos_tools::cur_idframe [expr $::atos_tools::frame_begin - 1]
      #set ::atos_tools::cur_idframe [expr $::atos_tools::cur_idframe - 1]
      #::console::affiche_resultat "deb cur_idframe == $::atos_tools::cur_idframe\n"
      set tt0 [clock clicks -milliseconds]

      while {$::atos_cdl_tools::sortie == 0} {
         
         if {$::atos_cdl_tools::log} { ::console::affiche_resultat "---\n" }
         update
         #set ::atos_cdl_tools::sortie 1
         
         set idframe [expr $::atos_tools::cur_idframe +1]

         #::console::affiche_resultat "av cur_idframe == $::atos_tools::cur_idframe\n"

         if {$idframe > $::atos_tools::frame_end} {break}
         
         #::console::affiche_resultat "cur_idframe == $::atos_tools::cur_idframe\n"

         ::atos_cdl_tools::start_next_image $visuNo $sum $bin $novisu
         
         if {$okdark} {
            buf$bufNo sub $masterdark $meandark
         }
         if {$okflat} {
            buf$bufNo div $masterflat $meanflat
         }
         if {$okflat||$okdark} {
            # set stat [buf$bufNo stat]
            # set seuilh [format "%.0f" [lindex $stat 0]]
            # set seuilb [format "%.0f" [lindex $stat 1]]
            visu$visuNo disp
         }

         if {$::atos_cdl_tools::log} { ::console::affiche_resultat "start1 cur_idframe = $::atos_tools::cur_idframe - $idframe\n" }
         
         #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \]\n"
         if {$idframe == $::atos_tools::frame_end} {
            set ::atos_cdl_tools::sortie 1
         }

         cleanmark

         # Mesure de l objet
         if { [ $select_objet cget -relief] == "sunken" } {
            set radius [ $frm_objet.radius cget -text]

            set r [::atos_cdl_tools::suivi_get_pos object]
            set x [lindex $r 0]
            set y [lindex $r 1]

            set status [::atos_cdl_tools::mesure_obj $x $y $visuNo $radius]
            if {$status == -1} {
                gren_erreur "Arret calcul de l objet\n"
                ::atos_cdl_tools::stop $visuNo
            }
         }

         # Mesure de la reference
         if { [ $select_reference cget -relief] == "sunken" } {
            set radius [ $frm_reference.radius cget -text]

            set r [::atos_cdl_tools::suivi_get_pos reference]
            set x [lindex $r 0]
            set y [lindex $r 1]

            set status [::atos_cdl_tools::mesure_ref $x $y $visuNo $radius]
            if {$status == -1} {
                gren_erreur "Arret calcul de la reference\n"
               ::atos_cdl_tools::stop $visuNo 
            }
         }
         
         # Mesure de l'image
         if { [ $select_image cget -relief] == "sunken" } {
            ::atos_cdl_tools::get_fullimg $visuNo
         }
         
         # Mise a jour des mesures
         if {$::atos_cdl_tools::log} { ::console::affiche_resultat "idframe passe a set_mesure_from_gui = $::atos_tools::cur_idframe - $idframe\n" }
         ::atos_cdl_tools::set_mesure_from_gui $idframe

         if {$sum>1} {incr ::atos_tools::cur_idframe [expr $sum-1]}

         if {$::atos_cdl_tools::sortie == 1} {
            ::atos_cdl_tools::start_next_image $visuNo $sum $bin $novisu
         }
      }

      #if {$relief=="sunken" && $sum>1} {
         # dmedf : duree moyenne entre 2 dates
         # tabdur : table des duree entre 2 dates
      #   set ::atos_ocr_tools::dmedf [::math::statistics::mean $::atos_cdl_tools::tabdur ]
      #}

      $frm_start configure -image .start
      $frm_start configure -relief raised
      $frm_start configure -command "::atos_cdl_tools::start $visuNo"

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      ::console::affiche_resultat "Traitement total en $tt secondes\n"

      if {$idframe >= $::atos_tools::frame_end} {
         tk_messageBox -message "Photometrie terminée en $tt secondes" -type ok
      }

   }


   proc ::atos_cdl_tools::start_next_image { visuNo sum bin novisu } {

      #::console::affiche_resultat "sn start cur_idframe = $::atos_tools::cur_idframe\n"
      set geometrie $::atos_gui::frame(geometrie)
      set relief [$geometrie.buttons.launch cget -relief]

      if {$relief=="raised"} {

         set optvisu [expr {$novisu == 1 ? "novisu" : ""}]
         ::atos_tools::next_image $visuNo $optvisu
         
      } else {

         if {$sum > 1} {
            ::atos_tools::next_image $visuNo novisu
            #::console::affiche_resultat "sn cur_idframe $sum = $::atos_tools::cur_idframe\n"
            set idsav $::atos_tools::cur_idframe
            #::console::affiche_resultat "sn cur_idframe after next_image = $::atos_tools::cur_idframe\n"
            ::atos_cdl_tools::read_sum $visuNo $sum
            #::console::affiche_resultat "sn m cur_idframe $sum = $::atos_tools::cur_idframe\n"
            set ::atos_tools::cur_idframe $idsav
            set ::atos_tools::scrollbar $idsav 
         }

      }     

      if {$::atos_cdl_tools::log} { ::console::affiche_resultat "sn end cur_idframe = $::atos_tools::cur_idframe\n" }

   }


   #
   # Stop les mesures photometriques
   #
   proc ::atos_cdl_tools::stop { visuNo } {

      ::console::affiche_resultat "-- stop \n"
      set frm_start $::atos_gui::frame(buttons,start)

      if {$::atos_cdl_tools::sortie == 1} {
         $frm_start configure -image .start
         $frm_start configure -relief raised
         $frm_start configure -command "::atos_cdl_tools::start $visuNo"
      }

      set ::atos_cdl_tools::sortie 1
      
   }

   proc ::atos_cdl_tools::read_sum { visuNo sum } {

      global audace


      #set ::atos_tools::traitement "fits"
      #set ::atos_tools::frame_end $sum


      #::console::affiche_resultat "read_sum beg cur_idframe = $::atos_tools::cur_idframe\n"
      set bufNo [::confVisu::getBufNo $visuNo]
      buf$bufNo save atos_preview_tmp_1.fit
      
      for {set i 2} {$i <= $sum} {incr i} {
         #::console::affiche_resultat "Next : "
         ::atos_tools::next_image $visuNo novisu
         #::console::affiche_resultat "cur_idframe = $::atos_tools::cur_idframe\n"
         buf$bufNo save atos_preview_tmp_$i.fit
      }
      #::console::affiche_resultat "read_sum cur_idframe = $::atos_tools::cur_idframe    \n"
      
      buf$bufNo load atos_preview_tmp_1.fit
      for {set i 2} {$i <= $sum} {incr i} {
         buf$bufNo add atos_preview_tmp_$i.fit 0
      }

      buf$bufNo save atos_preview_tmp_0.fit

      loadima [file join $audace(rep_travail) atos_preview_tmp_0.fit]

      incr ::atos_tools::cur_idframe [expr -$sum+1]
      incr ::atos_tools::scrollbar [expr -$sum+1]
      #::console::affiche_resultat "read_sum end cur_idframe = $::atos_tools::cur_idframe\n"

   }
   #
   #
   proc ::atos_cdl_tools::preview { visuNo } {

      set geometrie $::atos_gui::frame(geometrie)

      #::console::affiche_resultat "-- preview \n"
      #::console::affiche_resultat "geometrie = $geometrie\n"

      set bin [$geometrie.binning.val get]
      set sum [$geometrie.sum.val get]

      #::console::affiche_resultat "Binning= $bin \n"
      #::console::affiche_resultat "Bloc de $sum images \n"
      #::console::affiche_resultat "uncosmic_check = $::atos_cdl_tools::uncosmic_check \n"
      #::console::affiche_resultat "nb_frames      = $::atos_tools::nb_frames      \n"
      #::console::affiche_resultat "nb_open_frames = $::atos_tools::nb_open_frames \n"
      #::console::affiche_resultat "cur_idframe    = $::atos_tools::cur_idframe    \n"
      #::console::affiche_resultat "frame_begin    = $::atos_tools::frame_begin    \n"
      #::console::affiche_resultat "frame_end      = $::atos_tools::frame_end      \n"
      
      ::atos_cdl_tools::read_sum $visuNo $sum
      
      #incr ::atos_tools::cur_idframe [expr -$sum]
      #incr ::atos_tools::scrollbar  [expr -$sum]
      
   }

   #
   #
   proc ::atos_cdl_tools::compute_image { visuNo } {

      global caption atosconf
      
      set geometrie $::atos_gui::frame(geometrie)
      set relief [$geometrie.buttons.launch cget -relief]

      #::console::affiche_resultat "-- compute_image \n"
      #::console::affiche_resultat "geometrie = $geometrie\n"
      #::console::affiche_resultat "relief = $relief\n"
      #::console::affiche_resultat "nb_frames      = $::atos_tools::nb_frames      \n"
      #::console::affiche_resultat "nb_open_frames = $::atos_tools::nb_open_frames \n"
      #::console::affiche_resultat "cur_idframe    = $::atos_tools::cur_idframe    \n"
      #::console::affiche_resultat "frame_begin    = $::atos_tools::frame_begin    \n"
      #::console::affiche_resultat "frame_end      = $::atos_tools::frame_end      \n"
      
      if {$relief == "raised"} {
         # on applique
         $geometrie.buttons.launch configure -relief sunken
         set ::atos_cdl_tools::compute_image_first $::atos_tools::cur_idframe
         $geometrie.info.lab configure -text "Activation du changement de geometrie\nIndice de debut : $::atos_cdl_tools::compute_image_first"
         pack  $geometrie.info.lab -in $geometrie.info
         
      } else {
         $geometrie.buttons.launch configure -relief raised
         set ::atos_cdl_tools::compute_image_first ""
         $geometrie.info.lab configure -text ""
         pack forget $geometrie.info.lab
      }
      
   }



   proc ::atos_cdl_tools::suivi_init {  } {

      switch $::atos_cdl_tools::methode_suivi {
         "Auto" - default {
         }
         "Interpolation" {

            gren_info "Init de la Methode d'Interpolation\n"

            ::console::affiche_resultat "Vidage memoire\n"
            array unset ::atos_cdl_tools::interpol

            ::console::affiche_resultat "Analyse des positions verifiees "

            set cpt_obj 0
            set cpt_ref 0

            for {set idframe $::atos_tools::frame_begin} {$idframe <= $::atos_tools::frame_end} {incr idframe } {

               set ::atos_tools::scrollbar $idframe 

               set pass "no"
               if {[info exists ::atos_cdl_tools::mesure($idframe,object,verif)]} {
                  if {$::atos_cdl_tools::mesure($idframe,object,verif) == 1} {
                     set pass "yes"
                  }
               }
               if {$pass == "yes"} {
                  set ::atos_cdl_tools::interpol($idframe,object,x) $::atos_cdl_tools::mesure($idframe,obj_xpos)
                  set ::atos_cdl_tools::interpol($idframe,object,y) $::atos_cdl_tools::mesure($idframe,obj_ypos)
                  incr cpt_obj
               } else {
                  set ::atos_cdl_tools::mesure($idframe,object,verif) 0
               }

               set pass "no"
               if {[info exists ::atos_cdl_tools::mesure($idframe,reference,verif)]} {
                  if {$::atos_cdl_tools::mesure($idframe,reference,verif) == 1} {
                     set pass "yes"
                  }
               }
               if {$pass == "yes"} {
                  set ::atos_cdl_tools::interpol($idframe,reference,x) $::atos_cdl_tools::mesure($idframe,ref_xpos)
                  set ::atos_cdl_tools::interpol($idframe,reference,y) $::atos_cdl_tools::mesure($idframe,ref_ypos)
                  incr cpt_ref
               } else {
                  set ::atos_cdl_tools::mesure($idframe,reference,verif) 0
               }


            }
            ::console::affiche_resultat "termine \n"
            
            set statebutton [ $::atos_gui::frame(object,buttons).select cget -relief]
            if {$cpt_obj<2 && $statebutton=="sunken"} {
               gren_erreur "il faut avoir verifie la position de l objet sur 2 images minimum\n"
               return -code -1
            }
            set statebutton [ $::atos_gui::frame(reference,buttons).select cget -relief]
            if {$cpt_ref<2 && $statebutton=="sunken"} {
               gren_erreur "il faut avoir verifie la position de l objet sur 2 images minimum\n"
               return -code -1
            }

         }
      }
      return 0
   }



   proc ::atos_cdl_tools::suivi_get_pos { type } {
      
      set log 0


      switch $::atos_cdl_tools::methode_suivi {

         "Auto" - default {
            if {$log} { gren_info "Methode Auto pour $type\n"}
            switch $type {
               "object" {
                  return [list $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y)]
               }
               "reference" {
                  return [list $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y)]
               }
               default {
                  return -code -1 "Mauvais type"
               }
            }
         }
         "Interpolation" {

            if {$log} { gren_info "Methode Interpolation pour $type\n"}

            switch $type {

               "object" {

                  if {$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,object,verif) == 1} {
                     #gren_info "Verifie\n"
                     return [list $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)]
                  }
                  set idfrmav [ ::atos_cdl_tools::get_idfrmav $::atos_tools::cur_idframe object]
                  set idfrmap [ ::atos_cdl_tools::get_idfrmap $::atos_tools::cur_idframe object]
                  if {$log} {::console::affiche_resultat "$idfrmav < $idfrmap"}
                  if { $idfrmav == -1 } {
                     # il faut interpoler par 2 a droite
                     if {$log} { ::console::affiche_resultat "il faut interpoler par 2 a droite : "}
                     set idfrmav $idfrmap
                     set idfrmap [ ::atos_cdl_tools::get_idfrmap $idfrmap object]
                  }
                  if { $idfrmap == -1 } {
                     # il faut interpoler par 2 a gauche
                     if {$log} { ::console::affiche_resultat "il faut interpoler par 2 a gauche : "}
                     set idfrmap $idfrmav
                     set idfrmav [ ::atos_cdl_tools::get_idfrmap $idfrmav object]
                  }
                  if { $idfrmav == -1 || $idfrmap == -1 } {
                     if {$log} { ::console::affiche_erreur "mmm !"}
                     set idfrmav [ ::atos_cdl_tools::get_idfrmap $::atos_tools::frame_begin object]
                     set idfrmap [ ::atos_cdl_tools::get_idfrmav $::atos_tools::frame_end   object]
                  }
                  if { $idfrmav == $idfrmap } {
                     set idfrmav [::atos_cdl_tools::get_idfrmav  $idfrmav object]
                     if { $idfrmav == $idfrmap || $idfrmav == -1 } {
                        set idfrmav $idfrmap
                        set idfrmap [::atos_cdl_tools::get_idfrmap  $idfrmap object]
                        if { $idfrmap == $idfrmav || $idfrmap == -1 } {
                           set idfrmav [ ::atos_cdl_tools::get_idfrmap $::atos_tools::frame_begin object]
                           set idfrmap [ ::atos_cdl_tools::get_idfrmav $::atos_tools::frame_end   object]
                        }
                     }
                  }
                  if {$log} { ::console::affiche_resultat "interpol par $idfrmav << $idfrmap : "}

                  set xav $::atos_cdl_tools::mesure($idfrmav,obj_xpos)
                  set xap $::atos_cdl_tools::mesure($idfrmap,obj_xpos)
                  set yav $::atos_cdl_tools::mesure($idfrmav,obj_ypos)
                  set yap $::atos_cdl_tools::mesure($idfrmap,obj_ypos)

               }
               "reference" {

                  if {$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,reference,verif) == 1} {
                     #gren_info "Verifie\n"
                     return [list $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)]
                  }
                  set idfrmav [ ::atos_cdl_tools::get_idfrmav  $::atos_tools::cur_idframe reference]
                  set idfrmap [ ::atos_cdl_tools::get_idfrmap  $::atos_tools::cur_idframe reference]
                  if {$log} {::console::affiche_resultat "$idfrmav < $idfrmap"}
                  if { $idfrmav == -1 } {
                     # il faut interpoler par 2 a droite
                     if {$log} { ::console::affiche_resultat "il faut interpoler par 2 a droite : "}
                     set idfrmav $idfrmap
                     set idfrmap [ ::atos_cdl_tools::get_idfrmap $idfrmap reference]
                  }
                  if { $idfrmap == -1 } {
                     # il faut interpoler par 2 a gauche
                     if {$log} { ::console::affiche_resultat "il faut interpoler par 2 a gauche : "}
                     set idfrmap $idfrmav
                     set idfrmav [ ::atos_cdl_tools::get_idfrmap $idfrmav reference]
                  }
                  if { $idfrmav == -1 || $idfrmap == -1 } {
                     if {$log} { ::console::affiche_erreur "mmm !"}
                     set idfrmav [ ::atos_cdl_tools::get_idfrmap $::atos_tools::frame_begin reference]
                     set idfrmap [ ::atos_cdl_tools::get_idfrmav $::atos_tools::frame_end   reference]
                  }
                  if { $idfrmav == $idfrmap } {
                     set idfrmav [::atos_cdl_tools::get_idfrmav  $idfrmav reference]
                     if { $idfrmav == $idfrmap || $idfrmav == -1 } {
                        set idfrmav $idfrmap
                        set idfrmap [::atos_cdl_tools::get_idfrmap  $idfrmap reference]
                        if { $idfrmap == $idfrmav || $idfrmap == -1 } {
                           set idfrmav [ ::atos_cdl_tools::get_idfrmap $::atos_tools::frame_begin reference]
                           set idfrmap [ ::atos_cdl_tools::get_idfrmav $::atos_tools::frame_end   reference]
                        }
                     }
                  }
                  
                  if {$log} { ::console::affiche_resultat "interpol par $idfrmav << $idfrmap : "}

                  set xav $::atos_cdl_tools::mesure($idfrmav,ref_xpos)
                  set xap $::atos_cdl_tools::mesure($idfrmap,ref_xpos)
                  set yav $::atos_cdl_tools::mesure($idfrmav,ref_ypos)
                  set yap $::atos_cdl_tools::mesure($idfrmap,ref_ypos)


               }
               default {
                  gren_info "Default\n"
                  return -code -1 "Mauvais type"
               }
            } ; # Fin Switch


            #gren_info "x= $xav+($xap-$xav)/($idfrmap-$idfrmav)*($::atos_tools::cur_idframe-$idfrmav) \n"
            #gren_info "y= $yav+($yap-$yav)/($idfrmap-$idfrmav)*($::atos_tools::cur_idframe-$idfrmav) \n"

            set x [format "%.3f" [expr $xav+($xap-$xav)/($idfrmap-$idfrmav)*($::atos_tools::cur_idframe-$idfrmav)]]
            set y [format "%.3f" [expr $yav+($yap-$yav)/($idfrmap-$idfrmav)*($::atos_tools::cur_idframe-$idfrmav)]]
            if {$log} { ::console::affiche_resultat "(id=$::atos_tools::cur_idframe) interpol pos : $x / $y \n"}

            return [list $x $y]

         }
      }

   }





   proc ::atos_cdl_tools::verif_source { visuNo type } {

      global color
      set verif $::atos_gui::frame($type,buttons).verifier
      
      #::console::affiche_resultat "cur_idframe = $::atos_tools::cur_idframe    \n"
      #::console::affiche_resultat "obj(x)      = $::atos_cdl_tools::obj(x)    \n"
      #::console::affiche_resultat "obj(y)      = $::atos_cdl_tools::obj(y)    \n"

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         return
      }

      set pass "no"
      if {[info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif)]} {
         if {$::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) == 1 } {
            set pass "yes"
         }
      }

      if { $pass == "yes" } {
         set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) 0
         $verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      } else {
         ::atos_cdl_tools::set_mesure_source_from_gui $::atos_tools::cur_idframe $type
         set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) 1
         $verif configure -bg "#00891b" -fg $color(white)
      }
      
      return

      switch $type {
         "object" {

             # pos X Y
             if {[info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos)] && \
                 [info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)] } {

                #::console::affiche_resultat "obj_xpos = $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos)    \n"
                #::console::affiche_resultat "obj_ypos = $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)    \n"

             } else {
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) $::atos_cdl_tools::obj(x)
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos) $::atos_cdl_tools::obj(y)
             }

             if { $pass == "yes" } {
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) 0
                gren_info "Verif point ($::atos_tools::cur_idframe) : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif)\n"
                $verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
             } else {
                ::atos_cdl_tools::set_mesure_from_gui $::atos_tools::cur_idframe
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,object,verif) 1
                gren_info "Verif Object ($::atos_tools::cur_idframe) : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_xpos) / $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,obj_ypos)\n"
                $verif configure -bg "#00891b" -fg $color(white)
             }
         }
         "reference" {

             # pos X Y
             if {[info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos)] && \
                 [info exists ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)] } {

                #::console::affiche_resultat "ref_xpos = $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos)    \n"
                #::console::affiche_resultat "ref_ypos = $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)    \n"

             } else {
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) $::atos_cdl_tools::ref(x)
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos) $::atos_cdl_tools::ref(y)
             }

             # status verif
             #gren_info "Verif point ($::atos_tools::cur_idframe) : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,reference,verif)\n"
             if { $pass == "yes" } {
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) 0
                gren_info "Verif point ($::atos_tools::cur_idframe) : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,reference,verif)\n"
                $verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
             } else {
                set ::atos_cdl_tools::mesure($::atos_tools::cur_idframe,$type,verif) 1
                gren_info "Verif Reference ($::atos_tools::cur_idframe) : $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_xpos) / $::atos_cdl_tools::mesure($::atos_tools::cur_idframe,ref_ypos)\n"
                $verif configure -bg "#00891b" -fg $color(white)
             }
             
         }

      }

   }




   proc ::atos_cdl_tools::modif_source { visuNo type } {

      global color
      cleanmark
      switch $type {
         "object" {
            set frm_source $::atos_gui::frame(object,values) 
            set select $::atos_gui::frame(object,buttons).select
            set valid $::atos_gui::frame(object,buttons).verifier
         }
         "reference" {
            set frm_source $::atos_gui::frame(reference,values) 
            set select $::atos_gui::frame(reference,buttons).select
            set valid $::atos_gui::frame(reference,buttons).verifier
         }
      }

      set selectbutton [ $select cget -relief]
      set validbutton  [ $valid cget -bg]

      # le bouton select doit etre actif "coché"
      if {$selectbutton=="raised"} { return }

      # le bouton valider doit etre actif "vert"

      #if {$validbutton=="raised"} { return }
      
      
      set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]

      if {$err>0 || $rect ==""} {
         
         if {$type == "object"} {set mtype obj}
         if {$type == "reference"} {set mtype ref}
         
         for {set idframe $::atos_tools::cur_idframe} {$idframe > 0} {incr idframe -1} {
            
            if {[info exists ::atos_cdl_tools::mesure($idframe,${mtype}_xpos)] && 
                [info exists ::atos_cdl_tools::mesure($idframe,${mtype}_ypos)]} {
               set xsm $::atos_cdl_tools::mesure($idframe,${mtype}_xpos)
               set ysm $::atos_cdl_tools::mesure($idframe,${mtype}_ypos)
               break
            }
         }
         if {![info exists xsm] || ![info exists ysm]} {
            ::console::affiche_erreur "Last measure not found...\n"
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
            $frm_source.position configure -text "Selectionnez un cadre" -fg $color(red)
            return
         }
         
         ::console::affiche_erreur "::atos_cdl_tools::radius = $::atos_cdl_tools::radius\n"

         set rect [ list [expr $xsm - $::atos_cdl_tools::radius] [expr $ysm - $::atos_cdl_tools::radius] [expr $xsm + $::atos_cdl_tools::radius] [expr $ysm + $::atos_cdl_tools::radius] ]

      }

      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set err [ catch {set valeurs  [::atos_photom::select_obj $rect $bufNo]} msg ]

      if {$err>0} {
         ::console::affiche_erreur "$msg\n"
         ::console::affiche_erreur "      * * * *\n"
         ::console::affiche_erreur "Mesure Photometrique impossible\n"
         ::console::affiche_erreur "      * * * *\n"
         $frm_source.position configure -text "Error" -fg $color(red)
         return
      }

      set xsm [lindex $valeurs 0]
      set ysm [lindex $valeurs 1]

      switch $type {
         "object" {
            ::atos_cdl_tools::mesure_obj $xsm $ysm $visuNo $::atos_cdl_tools::radius
         }
         "reference" {
            ::atos_cdl_tools::mesure_ref $xsm $ysm $visuNo $::atos_cdl_tools::radius
         }
      }
   }  ; # Fin proc




   proc ::atos_cdl_tools::get_idfrmav { idframe type } {

       set stop 0
       set id $idframe
       while {$stop == 0} {
          incr id -1
          if {$id == 0} { return -1 }
          if {[info exists ::atos_cdl_tools::mesure($id,$type,verif)]} {
             if {$::atos_cdl_tools::mesure($id,$type,verif) == 1} {
                return $id
             }
          }
       }
       return -1
   }




   proc ::atos_cdl_tools::get_idfrmap { idframe type } {

       set stop 0
       set id $idframe
       while {$stop == 0} {
          incr id
          if {$id > $::atos_tools::frame_end} { break }
          if {[info exists ::atos_cdl_tools::mesure($id,$type,verif)]} {
             if {$::atos_cdl_tools::mesure($id,$type,verif) == 1} {
                return $id
             }
          }
       }
       return -1
   }


# psfimcce r15
# Flux object : moyenne : 251.7  Ecart type : 25.4 S/B : 9.9  Mean Radius : 15.0 Ampl : 204.8
# Flux reference : moyenne : 297.9  Ecart type : 27.6 S/B : 10.8  Mean Radius : 15.0 Ampl : 147.7
# Flux normal : moyenne : 253.7  Ecart type : 33.1 S/B : 7.7 Ampl : 272.1
# Traitement total en 79.390 secondes

# psfimcce r20
# Flux object : moyenne : 252.1  Ecart type : 25.2 S/B : 10.0  Mean Radius : 20.0 Ampl : 203.8
# Flux refere : moyenne : 298.5  Ecart type : 27.6 S/B : 10.8  Mean Radius : 20.0 Ampl : 146.2
# Flux normal : moyenne : 254.1  Ecart type : 33.1 S/B : 7.7 Ampl : 262.7
# Traitement total en 123.409 secondes

# psfimcce r25
# Flux object : moyenne : 252.4  Ecart type : 25.2 S/B : 10.0  Mean Radius : 25.0 Ampl : 207.2
# Flux reference : moyenne : 299.0  Ecart type : 27.4 S/B : 10.9  Mean Radius : 25.0 Ampl : 147.2
# Flux normal : moyenne : 254.3  Ecart type : 32.9 S/B : 7.7 Ampl : 263.8
# Traitement total en 175.990 secondes


# psfimcce r30
# Flux object : moyenne : 252.9  Ecart type : 25.4 S/B : 10.0  Mean Radius : 30.0 Ampl : 203.5
# Flux reference : moyenne : 299.1  Ecart type : 27.2 S/B : 11.0  Mean Radius : 30.0 Ampl : 144.2
# Flux normal : moyenne : 254.8  Ecart type : 33.0 S/B : 7.7 Ampl : 260.3
# Traitement total en 239.949 secondes

# psfimcce glob 10 30
# Flux object : moyenne : 252.9  Ecart type : 25.2 S/B : 10.0  Mean Radius : 16.2 Ampl : 204.6
# Flux reference : moyenne : 299.2  Ecart type : 27.4 S/B : 10.9  Mean Radius : 16.9 Ampl : 146.7
# Flux normal : moyenne : 254.8  Ecart type : 33.0 S/B : 7.7 Ampl : 263.8




# gauss2D glob 10 30
# Flux object : moyenne : 256.1  Ecart type : 27.2 S/B : 9.4  Mean Radius : 22.3 Ampl : 191.3
# Flux refere : moyenne : 305.8  Ecart type : 30.0 S/B : 10.2  Mean Radius : 22.7 Ampl : 174.2
# Flux normal : moyenne : 258.3  Ecart type : 35.0 S/B : 7.4 Ampl : 248.2
# Traitement total en 178.054 secondes



# psfimcce r20 DARKED
# Flux object : moyenne : 241.7  Ecart type : 26.4 S/B : 9.2  Mean Radius : 20.0
# Flux normal : moyenne : 244.0  Ecart type : 35.9 S/B : 6.8
# Traitement total en 127.289 secondes

# gauss2D glob 10 30 DARKED
# Flux object : moyenne : 244.3  Ecart type : 28.2 S/B : 8.7  Mean Radius : 21.6
# Traitement total en 269.501 secondes


   proc ::atos_cdl_tools::graph_flux { visuNo type } {
       
      global plotxy
      set NumGraphFlux 1
      
      if {![info exists ::atos_tools::frame_end]} {
         # Rien a faire car pas de video chargee
         return
      }

      set geometry ""
      if {[::plotxy::exists $NumGraphFlux]} {
         ::plotxy::figure $NumGraphFlux
         set axis [::plotxy::getzoom]
         #gren_info "info exists plotxy : [info exists plotxy]\n"
         #gren_info "info exists plotxy(fig$NumGraphFlux,parent) : [info exists plotxy(fig$NumGraphFlux,parent)]\n"
         if {[info exists plotxy(fig$NumGraphFlux,parent)]} {
            set baseplotxy $plotxy(fig$NumGraphFlux,parent)
            #gren_info "baseplotxy E: $baseplotxy\n"
            set geometry [ wm geometry $baseplotxy ]
            #gren_info "geometry E: $geometry\n"
         } 
         #gren_info "axis E: $axis]\n"
         #catch {gren_info "cfg E: [::plotxy::getgcf $NumGraphFlux]\n"}
      } else {
         ::plotxy::clf $NumGraphFlux
         ::plotxy::figure $NumGraphFlux
         ::plotxy::hold off 
         ::plotxy::position {0 0 600 400}
         ::plotxy::xlabel "id frame" 
         ::plotxy::ylabel "Flux" 
         set axis ""
      }
      #gren_info "axis D: $axis\n"
      #catch {gren_info "cfg D: [::plotxy::getgcf $NumGraphFlux]\n"}
      
      
      set x ""
      set y ""
      set x_verif    ""
      set x_interpol ""
      set y_verif    ""
      set y_interpol ""
      set tabfluxr   ""
      set tabrad     ""
      
      set cptnull 0
      set cpt 0
      for {set idframe 1} {$idframe <= $::atos_tools::frame_end} {incr idframe } {

         set jd   $::atos_ocr_tools::timing($idframe,jd)

         if {$jd == ""} {set jd $idframe}

         switch $type {
            "object" {
               if {[info exists ::atos_ocr_tools::timing($idframe,jd)] \
                   && [info exists ::atos_cdl_tools::mesure($idframe,obj_fint)]} {

                  set flux $::atos_cdl_tools::mesure($idframe,obj_fint)

               } else { continue }
               if {[info exists ::atos_cdl_tools::mesure($idframe,obj_radius)]} {
                  lappend tabrad $::atos_cdl_tools::mesure($idframe,obj_radius)
               }
            }
            "reference" {
               if {[info exists ::atos_ocr_tools::timing($idframe,jd)] \
                   && [info exists ::atos_cdl_tools::mesure($idframe,ref_fint)]} {

                  set flux $::atos_cdl_tools::mesure($idframe,ref_fint)

               } else { continue }
               if {[info exists ::atos_cdl_tools::mesure($idframe,ref_radius)]} {
                  lappend tabrad $::atos_cdl_tools::mesure($idframe,ref_radius)
               }

            }
            "normal" {
               if {[info exists ::atos_ocr_tools::timing($idframe,jd)] \
                   && [info exists ::atos_cdl_tools::mesure($idframe,obj_fint)]} {
                  set fluxo $::atos_cdl_tools::mesure($idframe,obj_fint)
               } else { continue }
               if {[info exists ::atos_ocr_tools::timing($idframe,jd)] \
                   && [info exists ::atos_cdl_tools::mesure($idframe,ref_fint)]} {
                   if {$::atos_cdl_tools::mesure($idframe,ref_fint)=="?"} {continue}
                   set fluxr $::atos_cdl_tools::mesure($idframe,ref_fint)
               } else { continue }
               if {$fluxr!= 0} {
                  set flux [expr $fluxo/$fluxr]
                  lappend tabfluxr $fluxr
               } else {
                  continue
               }
            }
            default {
               gren_erreur "ici $idframe $type\n"
               continue
            }
         }
         if {$jd=="?"} {continue}
         if {$flux=="?"} {continue}
#         if {$flux<0} {continue}
         if {$flux<=0} {
            incr cptnull
            continue
         }

         if {[info exists ::atos_cdl_tools::mesure($idframe,$type,verif)]} {

            if {$::atos_cdl_tools::mesure($idframe,$type,verif) == 1} {

               lappend x_verif $idframe  
               lappend y_verif $flux
               lappend x $idframe  
               lappend y $flux
               continue

            } else {

               lappend x_interpol $idframe  
               lappend y_interpol $flux
               lappend x $idframe  
               lappend y $flux
               continue
            }

         } else {

            lappend x $idframe  
            lappend y $flux
            continue

         }

      }
      if { [llength $tabfluxr] > 0 } {
         set meanr [::math::statistics::mean $tabfluxr]
         set y [::math::statistics::map a $y {$a*$meanr}]
      }
      
      if {[llength $x_verif]>0} {
         set h2 [::plotxy::plot $x_verif $y_verif ro. 2 ]
         plotxy::sethandler $h2 [list -color green -linewidth 0]
      }
      if {[llength $x_interpol]>0} {
         set h3 [::plotxy::plot $x_interpol $y_interpol ro. 1 ]
         plotxy::sethandler $h3 [list -color blue -linewidth 0]
      }
      if {[llength $x]>0} {
         set h1 [::plotxy::plot $x $y ro. 2 ]
         plotxy::sethandler $h1 [list -color black -linewidth 1]
      }

      gren_info "nb mesure dont Flux NULL : $cptnull\n"
      if {[llength $x]>0} {
         set mean  [format "%.1f" [::math::statistics::mean $y] ]
         set min   [::math::statistics::min $y] 
         set max   [::math::statistics::max $y] 
         set ampl  [format "%.1f" [expr $max - $min] ]
         set stdev [format "%.1f" [::math::statistics::stdev $y] ]
         set sb    [format "%.1f" [ expr $mean / $stdev] ] 
         if {$tabrad==""} {
            gren_info "Flux $type : moyenne : $mean  Ecart type : $stdev S/B : $sb Ampl : $ampl\n"
            ::plotxy::title "Courbe du temps pour $type\n Flux moyen : $mean  Ecart type : $stdev S/B : $sb Ampl : $ampl" 
         } else {
            set meanrad [format "%.1f" [::math::statistics::mean $tabrad] ]
            gren_info "Flux $type : moyenne : $mean  Ecart type : $stdev S/B : $sb  Mean Radius : $meanrad Ampl : $ampl\n"
            ::plotxy::title "Courbe du temps pour $type\n Flux moyen : $mean  Ecart type : $stdev S/B : $sb Ampl : $ampl Mean Radius : $meanrad" 
         }
      }

      if {$axis == ""} {
         set axis [::plotxy::axis]
         #gren_info "axisM : $axis\n"
         set axis [lreplace $axis 2 2 0]
#         ::plotxy::axis $axis
      }
      ::plotxy::axis $axis

      if {$geometry != ""} {
        #gren_info "geometry : $geometry\n"
        if {[info exists plotxy(fig$NumGraphFlux,parent)]} {
           set baseplotxy $plotxy(fig$NumGraphFlux,parent)
           wm geometry $baseplotxy $geometry
        } 
      }
      
      #gren_info "axis : [::plotxy::axis]\n"
      #catch {gren_info "cfg : [::plotxy::getgcf $NumGraphFlux]\n"}
      
   }









   proc ::atos_cdl_tools::graph_xy { visuNo type } {
   
      if {![info exists ::atos_tools::frame_end]} {
         # Rien a faire car pas de video chargee
         return
      }

      ::plotxy::clf 1
      ::plotxy::figure 1
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Courbe des XY pour $type" 
      ::plotxy::xlabel "Position X (pixel)" 
      ::plotxy::ylabel "Position Y (pixel)" 

      set x ""
      set y ""
      set x_verif    ""
      set x_interpol ""
      set y_verif    ""
      set y_interpol ""

 
      set cpt 0
      for {set idframe 1} {$idframe <= $::atos_tools::frame_end} {incr idframe } {

         switch $type {
            "object" {
               if {[info exists ::atos_cdl_tools::mesure($idframe,obj_xpos)] \
                   && [info exists ::atos_cdl_tools::mesure($idframe,obj_ypos)]} {
                   set xpos $::atos_cdl_tools::mesure($idframe,obj_xpos)
                   set ypos $::atos_cdl_tools::mesure($idframe,obj_ypos)
               } else { continue }
            }
            "reference" {
               if {[info exists ::atos_cdl_tools::mesure($idframe,ref_xpos)] \
                   && [info exists ::atos_cdl_tools::mesure($idframe,ref_ypos)]} {
                  set xpos $::atos_cdl_tools::mesure($idframe,ref_xpos)
                  set ypos $::atos_cdl_tools::mesure($idframe,ref_ypos)
               } else { continue }
            }
            default {
               gren_erreur "ici $idframe $type\n"
               continue
            }
         }
         if {$xpos=="?"} {continue}
         if {$ypos=="?"} {continue}
               
         if {[info exists ::atos_cdl_tools::mesure($idframe,$type,verif)]} {

            if {$::atos_cdl_tools::mesure($idframe,$type,verif) == 1} { 

               lappend x_verif $xpos
               lappend y_verif $ypos
               lappend x $xpos
               lappend y $ypos
               continue

            } else {

               lappend x_interpol $xpos
               lappend y_interpol $ypos
               lappend x $xpos
               lappend y $ypos
               continue

            }

         } else {

            lappend x $xpos
            lappend y $ypos
            continue

         }
            
      }
      if {[llength $x_verif]>0} {
         set h2 [::plotxy::plot $x_verif $y_verif ro. 10 ]
         plotxy::sethandler $h2 [list -color green -linewidth 0]
      }
      if {[llength $x_interpol]>0} {
         set h3 [::plotxy::plot $x_interpol $y_interpol ro. 5 ]
         plotxy::sethandler $h3 [list -color blue -linewidth 0]
      }
      if {[llength $x]>0} {
         set h1 [::plotxy::plot $x $y ro. 1 ]
         plotxy::sethandler $h1 [list -color black -linewidth 1]
      }

   }


   proc ::atos_cdl_tools::move_scroll { visuNo } {

      cleanmark

      set scrollbar $::atos_gui::frame(scrollbar)
      catch { ::atos_cdl_tools::set_gui_source $visuNo "object" }
      catch { ::atos_cdl_tools::set_gui_source $visuNo "reference" }
      
      
      #::atos_ocr_tools::workimage $visuNo $frm
      #::atos_ocr_tools::getinfofrm $visuNo $frm
   }


}
