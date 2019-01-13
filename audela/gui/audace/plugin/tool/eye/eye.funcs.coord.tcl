#
# Projet EYE
# Description : Pilotage d un chercheur electronique asservissant une monture
# Auteur : Frederic Vachier
# Mise a jour $Id: eye.funcs.coord.tcl 14055 2016-10-01 00:20:40Z fredvachier $
#

   #------------------------------------------------------------
   ## Calcule et affiche les coordonnees du reticule du foyer
   # du telescope
   # @return result = liste { ra dec }
   #
   proc ::eye::compute_coord_reticule {  }  {

      if {$::eye::widget(telescope,reticule,select)==0} {
         gren_info "Pas de reticule selectionne\n"

         set ::eye::widget(coord,reticule,raJ2000)   ""
         set ::eye::widget(coord,reticule,decJ2000)  ""
         set ::eye::widget(coord,reticule,draJ2000)  ""
         set ::eye::widget(coord,reticule,ddecJ2000) ""
         set ::eye::widget(coord,reticule,distJ2000) ""
         return
      }

      # calcul de la position du centre du FOV
      set x $::eye::widget(telescope,reticule,position,x)
      set y $::eye::widget(telescope,reticule,position,y)

      set radec [ buf$::eye::evt_bufNo xy2radec [list $x $y ] ]
      set f_ra [lindex $radec 0]
      set f_de [lindex $radec 1]
      set ::eye::widget(coord,reticule,raJ2000)  [mc_angle2hms $f_ra 360 zero 1 auto string]
      set ::eye::widget(coord,reticule,decJ2000) [mc_angle2dms $f_de  90 zero 1 + string]
      gren_info "RA DEC = $::eye::widget(coord,reticule,raJ2000) $::eye::widget(coord,reticule,decJ2000)\n"

      # Calcul de la distance a parcourir pour centrer l objet
      set pass "yes"
      if {[string trim $::eye::widget(coord,wanted,raJ2000)]==""} {
          gren_info "calcul differentiel impossible\n"
          set pass "no"
      }
      if {[string trim $::eye::widget(coord,wanted,decJ2000)]==""} {
          gren_info "calcul differentiel impossible\n"
          set pass "no"
      }
      if {$pass=="yes"} {

         set w_ra  [mc_angle2deg $::eye::widget(coord,wanted,raJ2000)]
         set w_de  [mc_angle2deg $::eye::widget(coord,wanted,decJ2000)]

         set pi [expr 2*asin(1.0)]
         set diffdeg_ra [expr ($w_ra - $f_ra) * cos( $w_de / 180.0 * $pi )]
         set diffdeg_de [expr  $w_de - $f_de]

         set ::eye::widget(coord,reticule,draJ2000)  [mc_angle2dms $diffdeg_ra  90 zero 1 + string]
         set ::eye::widget(coord,reticule,ddecJ2000) [mc_angle2dms $diffdeg_de  90 zero 1 + string]

         set rdiff [expr sqrt( ( pow($diffdeg_ra,2) + pow($diffdeg_de,2) ) / 2.0 ) ]
         set ::eye::widget(coord,reticule,distJ2000) [mc_angle2dms $rdiff  90 zero 1 + string]

         # $::eye::frmbase.onglets.nb.f_coord.frmtable.primaire.eraJ2000
         return 0
      } else {

         # pass no

         return 0
      }

   }





   #------------------------------------------------------------
   ## Definit la taille du reticule suivant le champ d observation 
   # de la camera au foyer primaire
   #  @return void
   #
   proc ::eye::reticule_set_size { frmtable } {

      gren_info "Set Size\n"
      $::eye::hCanvas delete reticule

      set x $::eye::widget(telescope,reticule,position,x)
      set y $::eye::widget(telescope,reticule,position,y)

      set naxis1 [lindex [buf$::eye::evt_bufNo getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::eye::evt_bufNo getkwd NAXIS2] 1]
      set scalex [lindex [buf$::eye::evt_bufNo getkwd CDELT1] 1]
      set scaley [lindex [buf$::eye::evt_bufNo getkwd CDELT2] 1]

      gren_info "scalex = $scalex\n"
      if {$scalex=="" || $scaley==""} {
         set radius 50
      } else {
         set radius [::eye::get_radius_xy $scalex $scaley]
      }
      set mx_min [expr int($x-$radius)]
      set my_min [expr int($y-$radius)]
      set mx_max [expr int($x+$radius)]
      set my_max [expr int($y+$radius)]

      affich_un_reticule_carre_xy $mx_min $my_min $mx_max $my_max $naxis1 $naxis2 red

   }
   
   #------------------------------------------------------------
   ## Definit la position du reticule suivant le champ d observation 
   # de la camera au foyer primaire. 
   #  @return void
   #
   proc ::eye::reticule_set_pos { frmtable } {
      gren_info "Set Pos\n"
      
      set r [split $::eye::widget(telescope,fov,pos) " "]
      lassign $r x y
      
      set ::eye::widget(telescope,reticule,position,x) $x 
      set ::eye::widget(telescope,reticule,position,y) $y 

      $::eye::hCanvas delete reticule

      set naxis1 [lindex [buf$::eye::evt_bufNo getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::eye::evt_bufNo getkwd NAXIS2] 1]
      set scalex [lindex [buf$::eye::evt_bufNo getkwd CDELT1] 1]
      set scaley [lindex [buf$::eye::evt_bufNo getkwd CDELT2] 1]

      gren_info "scalex = $scalex\n"
      if {$scalex=="" || $scaley==""} {
         set radius 50
      } else {
         set radius [::eye::get_radius_xy $scalex $scaley]
      }
      set mx_min [expr int($x-$radius)]
      set my_min [expr int($y-$radius)]
      set mx_max [expr int($x+$radius)]
      set my_max [expr int($y+$radius)]

      affich_un_reticule_carre_xy $mx_min $my_min $mx_max $my_max $naxis1 $naxis2 red
      
   }
   
   #------------------------------------------------------------
   ## Selectionne le reticule du foyer du primaire
   #  @param frmtable : Frame de selection du reticule
   #  @return void
   #
   proc ::eye::selection_reticule_foyer_telescope { frmtable } {

      if {$::eye::widget(telescope,reticule,select)==1} {
         set res [tk_messageBox -message "Etes vous sur de vouloir supprimer le reticule ?" -type yesno]
         if {$res == "yes"} {
            set ::eye::widget(telescope,reticule,select) 0
            $frmtable.telescope.select configure -relief "raised"
            $::eye::hCanvas delete reticule
            ::eye::compute_coord_reticule
         }
         gren_info "widget(telescope,reticule,select) = $::eye::widget(telescope,reticule,select) \n"
         return
      }

      set err [ catch {set rect  [ ::confVisu::getBox $::eye::visuNo ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez selectionner un carré dans l'image" -type ok
         return
      }

         set err [ catch {set fg [buf$::audace(bufNo) fitgauss $rect]} msg ]
         if {$err!=0} {
            tk_messageBox -message "Erreur de pointage d'un objet dans l'image, Veuillez renouveller la selection d'un carré dans l'image" -type ok
            return
         }

if { 1 == 0 } {
      set err [ catch {set fg [buf$::eye::evt_bufNo fitgauss $rect]} msg ]
      if {$err!=0} {
         # ok c est pas grave on teste sur le buffer du flux
         set err [ catch {set fg [buf$::audace(bufNo) fitgauss $rect]} msg ]
         if {$err!=0} {
            tk_messageBox -message "Erreur de pointage d'un objet dans l'image, Veuillez renouveller la selection d'un carré dans l'image" -type ok
            return
         }
      }
   }

      set x [lindex $fg 1]
      set y [lindex $fg 5]

      set ::eye::widget(telescope,reticule,position,x) $x
      set ::eye::widget(telescope,reticule,position,y) $y

      set naxis1 [lindex [buf$::eye::evt_bufNo getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::eye::evt_bufNo getkwd NAXIS2] 1]
      set scalex [lindex [buf$::eye::evt_bufNo getkwd CDELT1] 1]
      set scaley [lindex [buf$::eye::evt_bufNo getkwd CDELT2] 1]

      gren_info "scalex = $scalex\n"
      if {$scalex=="" || $scaley==""} {
         set radius 50
      } else {
         set radius [::eye::get_radius_xy $scalex $scaley]
      }
      set mx_min [expr int($x-$radius)]
      set my_min [expr int($y-$radius)]
      set mx_max [expr int($x+$radius)]
      set my_max [expr int($y+$radius)]

      affich_un_reticule_carre_xy $mx_min $my_min $mx_max $my_max $naxis1 $naxis2 red

      gren_info "Selection du reticule : radius ($::eye::widget(telescope,fov,diam) arcmin) = $radius pixel\n"

      set ::eye::widget(telescope,reticule,select) 1
      $frmtable.telescope.select configure -relief "sunken"

      if {$scalex!="" && $scaley!=""} {
         ::eye::compute_coord_reticule
      }
      gren_info "widget(telescope,reticule,select) = $::eye::widget(telescope,reticule,select) \n"

      # sauvegarde du reticule
      set ::eye::widget(telescope,fov,pos) "[format %0.2f $x] [format %0.2f $y]" 

      return 0
   }



   #------------------------------------------------------------
   ## Retourne le FOV en minute d'arc, choisi comme etant la plus
   # grand longueur sur l'image
   # @param scalex : echelle en X obtenue a partir de CD1_1
   # @param scaley : echelle en Y obtenue a partir de CD2_2
   #
   proc ::eye::get_radius_xy { scalex scaley } {

      set x [expr $::eye::widget(telescope,fov,diam) / $scalex / 60]
      set y [expr $::eye::widget(telescope,fov,diam) / $scaley / 60]
      if { $x<$y } { set x $y }
      return [expr int($x)]
   }


   #------------------------------------------------------------
   ## recupere et affiche les coordonnees dans une carte
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   # @return void
   #
   proc ::eye::getRadecFromChart { } {

      #--- je recupere les informations de l'etoile selectionne dans la carte
      #---  $ra $dec $equinox $objName $magnitude
      set ::eye::widget(coord,wanted,raJ2000)  ""
      set ::eye::widget(coord,wanted,decJ2000) ""


      set result [::carte::getSelectedObject]

      if { [llength $result] == 5 } {

         #set now [::audace::date_sys2ut now]
         #set listv [catalogmean2apparent [lindex $result 0] [lindex $result 1] J2000.0 $now]
         #set ra [lindex $listv 0]
         #set dec [lindex $listv 1]

         set ra  [lindex $result 0]
         set dec [lindex $result 1]

         set equinox [lindex $result 2]

         if { $equinox == 2000 } {
            set ::eye::widget(coord,wanted,raJ2000)  [mc_angle2hms $ra 360 zero 1 auto string]
            set ::eye::widget(coord,wanted,decJ2000) [mc_angle2dms $dec 90 zero 1 + string]
         } else {
            set radec [list $ra $dec ]
            # now en UT
            set now [mc_date2jd now]

            ####--- Position de l'observateur
            ###set gpsPosition $::audace(posobs,observateur,gps)
            ####--- Aberration de l'aberration diurne
            ####set radec [mc_aberrationradec diurnal [list $ra $dec] $date $gpsPosition -reverse]
            #--- Correction de nutation
            set radec [mc_nutationradec $radec $now -reverse]
            #--- Correction de precession
            set radec [mc_precessradec $radec $now "J2000" ]
            #--- Aberration annuelle
            set radec [mc_aberrationradec annual $radec $now -reverse]
            set ::eye::widget(coord,wanted,raJ2000)  [mc_angle2hms [lindex $radec 0] 360 zero 1 auto string]
            set ::eye::widget(coord,wanted,decJ2000) [mc_angle2dms [lindex $radec 1] 90 zero 1 + string]
         }
      }
   }

   #------------------------------------------------------------
   ## recupere et affiche les coordonnees dans une liste
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   #
   proc ::eye::getRadecFromStarList { } {

      global audace

      set filestars [file join $audace(rep_catalogues) catagoto etoiles_brillantes.txt]
      set star_list ""
      set chan [open $filestars "r"]
      while {[gets $chan line] >= 0} {
         set cpt 0
         foreach x [split $line " "] {

            if {$x != ""} {
               if {$cpt == 0} {set name  $x}
               if {$cpt == 1} {set name2 $x}
               if {$cpt == 2} {set name3 $x}
               if {$cpt == 3} {set ra_h  $x}
               if {$cpt == 4} {set ra_m  $x}
               if {$cpt == 5} {set ra_s  $x}
               if {$cpt == 6} {set dec_h $x}
               if {$cpt == 7} {set dec_m $x}
               if {$cpt == 8} {set dec_s $x}
               if {$cpt == 9} {set mag   $x}
               incr cpt
            }
         }
         set name2 "${name2}_${name3}"
         set ra "${ra_h}h${ra_m}m${ra_s}s"
         set dec "${dec_h}d${dec_m}m${dec_s}s"
         set x [mc_radec2altaz $ra $dec $::audace(posobs,observateur,gps) [get_date_sys2ut]]
         set hourangle [lindex $x 2]
         set hauteur   [lindex $x 1]

         if {$name == "Markab" && 0 } {
            gren_info "name = $name\n"
            gren_info "RA = $ra\n"
            gren_info "DEC = $dec\n"
            gren_info "H = [mc_angle2hms $hourangle 360 zero 0 auto string]\n"
            gren_info "GPS = $::audace(posobs,observateur,gps)\n"
            gren_info "DATE = [get_date_sys2ut]\n"
         }

         if {$hauteur > 20 } {
            set hourangle [mc_angle2hms $hourangle 360 zero 0 auto string]
            set hauteur   [mc_angle2dms $hauteur 90 nozero 0 + string]
            lappend star_list [list $name $name2 $ra $dec $hourangle $hauteur $mag]
         }

      }
      close $chan


      set fen .starlist
      if { [winfo exists $fen] } {
         wm withdraw $fen
         wm deiconify $fen
         focus $fen
         return
      }
      toplevel $fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]

      wm geometry $fen "680x240+[expr $posx_config + 265]+[expr $posy_config + 55]"
      wm resizable $fen 1 1
      wm title $fen "Liste des Etoiles Brillantes"
      wm protocol $fen WM_DELETE_WINDOW "destroy .starlist"

      set frm $fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set liste [frame $frm.frm  -borderwidth 1 -relief groove]
         pack $liste -in $frm -expand yes -fill both

         set cols [list 0  "Name"          right \
                        11 "Constellation" right \
                        0  "RaJ2000"       left \
                        0  "DecJ2000"      left \
                        0  "H"             left \
                        0  "Hauteur"       left \
                        0  "Mag"           left \
                  ]

         set zliste $liste.tab
         tablelist::tablelist $zliste \
            -columns $cols \
            -labelcommand tablelist::sortByColumn \
            -yscrollcommand [ list $liste.vsb set ] \
            -selectmode extended \
            -activestyle none \
            -stripebackground "#e0e8f0" \
            -showseparators 1

         scrollbar $liste.vsb -orient vertical -command [list $zliste yview]
         pack $liste.vsb -in $liste -side left -fill y
         bind [$zliste bodypath] <Double-1> [ list ::eye::select_starlist $zliste]
         pack $zliste -in $liste -expand yes -fill both

         $zliste columnconfigure 0 -sortmode dictionary
         $zliste columnconfigure 1 -sortmode dictionary

         $zliste delete 0 end
         foreach star $star_list {
            $zliste insert end $star
         }

   }

   proc ::eye::affiche_calibstars { {ra ""} {dec ""} {dra ""} {ddec ""} {dist ""} } {

      global audace

      array set color { 1 green 2 blue 3 red}
            gren_info "$::eye::widget(methode)\n"

      if {$::eye::widget(methode) == "CALIBWCS"} {

         gren_info "  Display $::eye::widget(methode,calib_tmpdir)/ascii.txt:\n"
         gren_info "    * green = Sextractor extracted sources (code 1)\n"
         gren_info "    * blue = Sources identified as USNOA2 stars (code 3)\n"
         gren_info "    * red = Rejected sources (code 2)\n"
         # Lecture des sources depuis le fichier obs.lst
         set chan [open "$::eye::widget(methode,calib_tmpdir)/ascii.txt" "r"]
         while {[gets $chan line] >= 0} {
            set cpt 0
            foreach x [split $line " "] {
               if {$x != ""} {
                  if {$cpt == 1} {set ci $color($x)}
                  if {$cpt == 2} {set xi $x}
                  if {$cpt == 3} {set yi $x}
                  incr cpt
               }
            }
            ::eye::affich_un_rond_xy $xi $yi $ci 3 2
         }
         close $chan

      }

      if {$::eye::widget(methode) == "CALIBWCS_NEW"} {

         set catatmp [file join $::eye::widget(methode,calib_tmpdir) catalog.cat]
         if {![file exists $catatmp]} {
            gren_erreur "Pas d'affichage des etoiles de calibration: catalog.cat n'existe pas\n"
            return -1
         }

         set chan [open $catatmp r]
         set lineCount 0
         set littab "no"
         while {[gets $chan line] >= 0} {
            incr lineCount
            set zlist [split $line " "]
            # catalog.cat format
            #   1 NUMBER          Running object number
            #   2 FLUX_BEST       Best of FLUX_AUTO and FLUX_ISOCOR               [count]
            #   3 FLUXERR_BEST    RMS error for BEST flux                         [count]
            #   4 MAG_BEST        Best of MAG_AUTO and MAG_ISOCOR                 [mag]
            #   5 MAGERR_BEST     RMS error for MAG_BEST                          [mag]
            #   6 BACKGROUND      Background at centroid position                 [count]
            #   7 X_IMAGE         Object position along x                         [pixel]
            #   8 Y_IMAGE         Object position along y                         [pixel]
            #   9 X2_IMAGE        Variance along x                                [pixel**2]
            #  10 Y2_IMAGE        Variance along y                                [pixel**2]
            #  11 XY_IMAGE        Covariance between x and y                      [pixel**2]
            #  12 A_IMAGE         Profile RMS along major axis                    [pixel]
            #  13 B_IMAGE         Profile RMS along minor axis                    [pixel]
            #  14 THETA_IMAGE     Position angle (CCW/x)                          [deg]
            #  15 FWHM_IMAGE      FWHM assuming a gaussian core                   [pixel]
            #  16 FLAGS           Extraction flags
            #  17 CLASS_STAR      S/G classifier output
            set xlistcata {}
            foreach value $zlist {
               if {$value != {}} {
                  set xlistcata [linsert $xlistcata end $value]
               }
            }
            set xs [lindex $xlistcata 6]
            set ys [lindex $xlistcata 7]
            # Couleur de l'etoile en fonction de la distance au reticule
            set dx [expr $xs - $::eye::widget(telescope,reticule,position,x)]
            set dy [expr $ys - $::eye::widget(telescope,reticule,position,y)]
            set dxy [expr sqrt(pow($dx,2)+pow($dy,2))]
            set ci $color(3)
            if {$dxy <= 300.0} { set ci $color(2) }
            if {$dxy <= 100.0} { set ci $color(1) }
            ::eye::affich_un_rond_xy $xs $ys $ci 3 2
         }

         if {[catch {close $chan} err]} {
            gren_erreur "Cannot close cata file ($catatmp): <$err>"
         }

      }

   }


   proc ::eye::select_starlist { zliste } {

      set selection [$zliste curselection]
      set line [$zliste get $selection]
      gren_info "selection = $line\n"
      set ::eye::widget(coord,wanted,raJ2000)  [lindex $line 2]
      set ::eye::widget(coord,wanted,decJ2000)  [lindex $line 3]
      destroy .starlist
   }


   proc ::eye::affich_un_rond_xy { x y color radius width } {

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


   proc get_date_sys2ut { { date now } } {
     if { $date == "now" } {
        set t [clock milliseconds]
        set time [format "%s.%03d" [clock format [expr {$t / 1000}] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC] [expr {$t % 1000}] ]
     } else {
        set jjnow [ mc_date2jd $date ]
        set time  [ mc_date2ymdhms $jjnow ]
     }
     return $time
   }
