#
## @file telshift.tcl
#  @brief Script de prise d'images avec déplacement du télescope entre les poses
#  @author Christian JASINSKI (e-mail : chris.jasinski@wanadoo.fr)
#  @details Avec l'aide d'Alain KLOTZ pour la partie la plus difficile (grande boucle interne aux procédures)
#  Avec l'aide de Robert DELMAS qui a apporté de nombreuses modifications, notamment en matière de traitement des erreurs
#  $Id: telshift.tcl 13609 2016-04-04 14:20:08Z rzachantke $
#

#!/logiciels/public/Tcl/bin/wish

## @namespace telsift
#  @brief Script de prise d'images avec déplacement du télescope entre les poses
namespace eval ::telshift {

   #--- loading captions
   source [ file join $audace(rep_plugin) tool telshift telshift.cap ]

   proc createPanel { this } {
      #--- create a window
      variable This
      global audace
      global caption
      global panneau
      global conf
      global color

      if { ! [ info exists conf(telshift,position) ] } { set conf(telshift,position) "+150+100" }

      set This $this

      set panneau(telshift,stop) "0"

      toplevel $This

      #--- set window title
      wm minsize $This 350 480
      wm title $This "$caption(telshift,titre)"
      wm geometry $This $conf(telshift,position)
      wm protocol $This WM_DELETE_WINDOW ::telshift::cmdClose

      #--- create frames
      frame $This.filename -borderwidth 2 -relief raised
      frame $This.focale -borderwidth 2 -relief raised
      frame $This.binning -borderwidth 2 -relief raised
      frame $This.para -borderwidth 2 -relief raised
      frame $This.image -borderwidth 2 -relief raised
      frame $This.btn -borderwidth 2 -relief raised
      pack $This.btn -side bottom -fill x
      pack $This.filename $This.focale $This.binning $This.image -side top -padx 10 -pady 10
      pack $This.para -ipady 5 -padx 10 -pady 10

      #--- create buttons
      button $This.btn.ok -text "$caption(telshift,ok)" -command ::telshift::Run
      button $This.btn.annuler -text "$caption(telshift,annuler)" -command ::telshift::cmdClose
      button $This.btn.help1 -text "$caption(telshift,aide)" -command ::telshift::Open
      pack $This.btn.ok -side left -ipadx 30 -ipady 5
      pack $This.btn.annuler -side left -ipadx 20 -ipady 5
      pack $This.btn.help1 -side right -ipadx 20 -ipady 5

      #--- create text field in filename frame
      global filename

      label $This.filename.labname -text "$caption(telshift,nomfichier)"
      entry $This.filename.name -width 15 -relief sunken -textvariable filename
      pack $This.filename.labname -side top -anchor center
      pack $This.filename.name -side bottom -pady 5
      bind $This.filename.name <Leave> {
        $::telshift::This.btn.ok configure -relief raised -state normal
        after 400
        destroy $::telshift::This.erreurfocale
      }

      #--- create entries and nested frames in parameter frame
      global nbr
      global pose

      frame $This.para.nest1
      label $This.para.labparapose -text "$caption(telshift,parametres)"
      label $This.para.labURL_status_cam -text "$caption(telshift,status)" -fg $color(blue)
      label $This.para.nest1.labnbr -text "$caption(telshift,nbposes)"
      entry $This.para.nest1.nbr -width 3 -relief sunken -textvariable nbr -justify center
      frame $This.para.nest2
      label $This.para.nest2.labduree -text "$caption(telshift,dureepose)"
      entry $This.para.nest2.pose -width 3 -relief sunken -textvariable pose -justify center
      label $This.para.nest2.labsec -text "$caption(telshift,secondes)"

      pack $This.para.labparapose -side top -anchor w
      pack $This.para.labURL_status_cam -side top -anchor center
      pack $This.para.nest1 -side top -ipady 5 -anchor w
      pack $This.para.nest1.labnbr -side left -padx 5
      pack $This.para.nest1.nbr -side left -anchor w -padx 5
      pack $This.para.nest2 -side top -ipady 5 -anchor w
      pack $This.para.nest2.labduree -side left -padx 5
      pack $This.para.nest2.pose -side left
      pack $This.para.nest2.labsec -side left -padx 5

      #--- create radiobuttons in binning frame
      global choice_binning

      label $This.binning.labbin -text "$caption(telshift,binning)"
      pack $This.binning.labbin -side top -anchor w
      foreach {x y z} [ list "$caption(telshift,binning1)" b1 1 "$caption(telshift,binning2)" b2 2 "$caption(telshift,binning4)" b3 4 ] {
         radiobutton $This.binning.$y -text $x -variable choice_binning -value $z
         pack $This.binning.$y -side left -padx 5
      }
      $This.binning.b2 select

      #--- create text field in focal length frame
      global foc

      label $This.focale.labfoc -text "$caption(telshift,focale)"
      entry $This.focale.length -width 15 -relief sunken -textvariable foc
      label $This.focale.mm -text "$caption(telshift,mm)"
      pack $This.focale.labfoc -side top -anchor w
      pack $This.focale.length -side left -anchor w -pady 5
      pack $This.focale.mm -side left -padx 5
      bind $This.focale.length <Leave> {
         $::telshift::This.btn.ok configure -relief raised -state normal
         after 400
         destroy $::telshift::This.erreurfocale
      }

      #--- create radiobuttons and label in image frame
      global choice_proc

      label $This.image.labima -text "$caption(telshift,imagerie)"
      pack $This.image.labima -side top -anchor w
      foreach {x y z} [ list "$caption(telshift,imagenormale)" r1 ima "$caption(telshift,superflat)" r2 super "$caption(telshift,mosaique4)" r3 4mosa "$caption(telshift,mosaique9)" r4 9mosa ] {
         radiobutton $This.image.$y -text $x -variable choice_proc -value $z
         pack $This.image.$y -side top -anchor w -padx 5
      }
      $This.image.r1 select
      bind $This.image.r3 <Button-1> {$::telshift::This.para.nest1.labnbr config -text "$caption(telshift,nbposesmosa)"}
      bind $This.image.r4 <Button-1> {$::telshift::This.para.nest1.labnbr config -text "$caption(telshift,nbposesmosa)"}
      bind $This.image.r1 <Button-1> {$::telshift::This.para.nest1.labnbr config -text "$caption(telshift,nbposes)"}
      bind $This.image.r2 <Button-1> {$::telshift::This.para.nest1.labnbr config -text "$caption(telshift,nbposes)"}

      #--- set up key binding
      bind $This.btn.ok <Return> ::telshift::Run
      bind $This.btn.annuler <Escape> ::telshift::cmdClose
      focus $This.para.nest1.nbr

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #--- launch Open procedure for help
   proc Open { } {
      variable This
      global audace
      global caption
      global langage

      #--- create a window
      set aide $This.help1
      if { [winfo exists $aide] } {
         wm withdraw $aide
         wm deiconify $aide
         focus $aide
         return
      }
      toplevel $aide
      #--- set window title
      wm resizable $aide 1 1
      wm maxsize $aide 350 350
      wm title $aide "$caption(telshift,aideutil)"
      set posx_help1 [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
      set posy_help1 [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
      wm geometry $aide +[ expr $posx_help1 + 370 ]+[ expr $posy_help1 + 0 ]
      #--- create text area and scrollbar
      scrollbar $aide.scroll -command "$aide.text yview" -orient vertical
      text $aide.text -width 295 -height 295 -padx 10 -wrap word -yscrollcommand "$aide.scroll set"
      pack $aide.scroll -side right -fill y
      pack $aide.text -fill both
      #--- insert the help text (telshift.txt) in the text area
      if {[string compare $langage "french"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_fr.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "italian"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_it.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "spanish"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_sp.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "german"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_ge.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "danish"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_da.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } else {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_en.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      }
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $aide <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $aide
   }

   #--- launch recupPosition procedure to close the main window
   proc recupPosition { } {
      variable This
      global conf

      #--- Je mets la position actuelle de la fenetre dans conf()
      set geom [ winfo geometry [winfo toplevel $This ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(telshift,position) "+[ string range $geom $deb $fin ]"
   }

   ## @brief procedure to close the main window
   #
   proc cmdClose { } {
      variable This
      global audace
      global panneau

      set panneau(telshift,stop) "1"
      catch {after cancel bell}
      catch {cam$audace(camNo) stop}
      after 200
      set aide $This.help1
      ::telshift::recupPosition
      if { [winfo exists $aide] } {
         destroy $aide
      }
      destroy $This
   }

   ## @brief lauch Run procedure
   #
   proc Run { } {
   global choice_proc

      switch -exact -- $choice_proc {
         ima   { Procima }
         super { Procsuper }
         4mosa { Proc4mosa }
         9mosa { Proc9mosa }
      }
   }

   ## @brief procedure to deal with normal images
   #
   proc Procima { } {
      variable This
      global audace
      global conf
      global caption
      global color
      global panneau
      global nbr
      global pose
      global choice_binning
      global foc
      global filename

      $This.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
            # set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- make the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list RANDOM $nbr]
               set compix 30
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $nbr frames
               for {set k 0} {$k<$nbr} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]
                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $k]
                  #--- get ra coordinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  #--- convert degrees into a list {d m s.s}
                  set decdms [mc_angle2dms $dec 90]
                  #--- get degree, minute and second
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  #--- convert seconds in integer for goto format
                  set decs [expr int($decs)]
                  #--- formatting goto format
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  if {$k>0} {
                     #--- only if we are not on the first field
                     set catchError [ catch {
                        ::telescope::goto [list $ra $dec] 1
                     } ]
                     if { $catchError != 0 } {
                        ::tkutil::displayErrorInfoTelescope "GOTO Error"
                        return
                     }
                  }
                  #--- shoot an image
                  ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"

                  #--- exposure time
                  set exptime $pose

                  #--- binning factor
                  set bin $choice_binning

                  #--- call to acquisition function
                  acq $exptime $bin $k $nbr

                  #--- design of invoking panel
                  $This.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                  update

                  #--- save image
                  saveima "$filename$kk"
               }

               if { [winfo exists $This] } {
                  $This.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $This.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $This.btn.ok configure -relief raised -state normal
      }

   }

   #--- lauch Procsuper procedure to deal with flat field images
   proc Procsuper { } {
      variable This
      global audace
      global conf
      global caption
      global color
      global panneau
      global nbr
      global pose
      global choice_binning
      global foc
      global filename

      $This.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
            # set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- make the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list RANDOM $nbr]
               set compix 3000
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $nbr frames
               for {set k 0} {$k<$nbr} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]
                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $k]
                  #--- get ra coordinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  set decdms [mc_angle2dms $dec 90]
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  set decs [expr int($decs)]
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  if {$k>0} {
                     #--- only if we are not on the first field
                     set catchError [ catch {
                        ::telescope::goto [list $ra $dec] 1
                     } ]
                     if { $catchError != 0 } {
                        ::tkutil::displayErrorInfoTelescope "GOTO Error"
                        return
                     }
                  }
                  #--- shoot an image
                  ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"
                 # acq $pose $choice_binning

                  #--- exposure time
                  set exptime $pose

                  #--- binning factor
                  set bin $choice_binning

                  #--- call to acquisition function
                  acq $exptime $bin $k $nbr

                  #--- design of invoking panel
                  $This.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                  update

                  #--- save image
                  saveima "$filename$kk"
               }

               if { [winfo exists $This] } {
                  $This.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $This.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $This.btn.ok configure -relief raised -state normal
      }

   }

   ## @brief procedure to deal with mosaic of 4 images
   #
   proc Proc4mosa { } {
      variable This
      global audace
      global conf
      global caption
      global color
      global panneau
      global pose
      global choice_binning
      global foc
      global filename
      global nbr

      $This.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
            #set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- parameters for the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list ROLL 4]
               set compix 30

               #--- shift the origine because the center of the first image is not the center coordinates of the mosaic.
               set shiftx [expr $compix*0.5]
               set shifty [expr $compix*0.5]
               set radec0 [mc_xy2radec $shiftx $shifty $optic]
               set ra0 [lindex $radec0 0]
               set dec0 [lindex $radec0 1]
               set ra0 [mc_angle2deg $ra0]
               set dec0 [mc_angle2deg $dec0]
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]

               #--- make the target list
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $mo4_nbr frames
               set mosa 4
               set mo4_nbr [expr {$nbr * 4}]
               set kkk 0
               for {set k 0} {$k<$mosa} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]
                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $kkk]
                  incr kkk 1
                  set kkkk $kkk

                  #--- get ra coordinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  set decdms [mc_angle2dms $dec 90]
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  set decs [expr int($decs)]
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  set catchError [ catch {
                     ::telescope::goto [list $ra $dec] 1
                  } ]
                  if { $catchError != 0 } {
                     ::tkutil::displayErrorInfoTelescope "GOTO Error"
                     return
                  }
                  ::console::affiche_resultat "$caption(telshift,pointesur) $ra $dec\n"

                  for {set s 0} {$s<$nbr} {incr s 1} {

                     #--- shoot an image
                     ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"
                    # acq $pose $choice_binning

                     #--- exposure time
                     set exptime $pose

                     #--- binning factor
                     set bin $choice_binning

                     #--- call to acquisition function
                     acqmosa $exptime $bin $kkkk $s $mosa

                     #--- design of invoking panel
                     $This.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                     update

                     #--- save image
                     set loop [expr {$k + 1}]
                     set image [expr {$s + 1}]
                     saveima "$filename-$loop-$image"
                  }
               }

               if { [winfo exists $This] } {
                  $This.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $This.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $This.btn.ok configure -relief raised -state normal
      }

   }

   ## @brief procedure to deal with mosaic of 9 images
   #
   proc Proc9mosa { } {
      variable This
      global audace
      global conf
      global caption
      global color
      global panneau
      global pose
      global choice_binning
      global foc
      global filename
      global nbr

      $This.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
            #set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- make the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list ROLL 9]
               set compix 30
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $mo9_nbr frames
               set mosa 9
               set mo9_nbr [expr {$nbr * 9}]
               set kkk 0
               for {set k 0} {$k<$mosa} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]

                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $kkk]
                  incr kkk 1
                  set kkkk $kkk

                  #--- get ra coordinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  set decdms [mc_angle2dms $dec 90]
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  set decs [expr int($decs)]
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  if {$k>0} {
                     #--- only if we are not on the first field
                     set catchError [ catch {
                        ::telescope::goto [list $ra $dec] 1
                     } ]
                     if { $catchError != 0 } {
                        ::tkutil::displayErrorInfoTelescope "GOTO Error"
                        return
                     }
                     ::console::affiche_resultat "$caption(telshift,pointesur) $ra $dec\n"
                  }

                  for {set s 0} {$s<$nbr} {incr s 1} {

                     #--- shoot an image
                     ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"
                    # acq $pose $choice_binning

                     #--- exposure time
                     set exptime $pose

                     #--- binning factor
                     set bin $choice_binning

                     #--- call to acquisition function
                     acqmosa $exptime $bin $kkkk $s $mosa

                     #--- design of invoking panel
                     $This.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                     update

                     #--- save image
                     set loop [expr {$k + 1}]
                     set image [expr {$s + 1}]
                     saveima "$filename-$loop-$image"
                  }
               }

               if { [winfo exists $This] } {
                  $This.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $This.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $This.btn.ok configure -relief raised -state normal
      }

   }

   ## @brief avoids getting the Tcl/Tk error message if there is no focal value in mm
   #
   proc ErreurFocale { } {
      variable This
      global audace
      global caption

      if [winfo exists $This.erreurfocale] {
         destroy $This.erreurfocale
      }
      toplevel $This.erreurfocale
      wm transient $This.erreurfocale $This
      wm resizable $This.erreurfocale 0 0
      wm title $This.erreurfocale "$caption(telshift,attention)"
      set posx_erreurfocale [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
      set posy_erreurfocale [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
      wm geometry $This.erreurfocale +[ expr $posx_erreurfocale + 270 ]+[ expr $posy_erreurfocale + 50 ]
      wm protocol $This.erreurfocale WM_DELETE_WINDOW {
         $::telshift::This.btn.ok configure -relief raised -state normal
         after 400
         destroy $::telshift::This.erreurfocale
      }

      #--- create the message display
      label $This.erreurfocale.lab1 -text "$caption(telshift,erreurfocale1)"
      pack $This.erreurfocale.lab1 -padx 10 -pady 2
      label $This.erreurfocale.lab2 -text "$caption(telshift,erreurfocale2)"
      pack $This.erreurfocale.lab2 -padx 10 -pady 2
      label $This.erreurfocale.lab3 -text "$caption(telshift,erreurfocale3)"
      pack $This.erreurfocale.lab3 -padx 10 -pady 2

      #--- the new window is on
      focus $This.erreurfocale

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This.erreurfocale
   }

   ## @brief acquisition
   #
   proc acq { exptime binning { k "" } { nbr "" } } {
      variable This
      global audace
      global conf
      global caption
      global color

      #--- shortcuts
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- the exptime control is used to determine the exposure time for the image
      $camera exptime $exptime

      #--- the bin control is used to determine the binning data
      $camera bin [list $binning $binning]

      #---
      if {$exptime>1} {
      } else {
         $This.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }

      #--- beginning of acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $exptime

      #--- call to timer
      if {$exptime>1} {
         dispTime $k $nbr
      }

      #--- waiting for exposure end
      ::camera::waitStateStand $audace(camNo)

      #--- image viewing
      ::audace::autovisu $audace(visuNo)
   }

   proc dispTime { { k "" } { nbr "" } } {
      variable This
      global audace
      global caption
      global color

      set t "[cam$audace(camNo) timer -1]"
      if {$t>1} {
         $This.para.labURL_status_cam configure -text "[expr $t-1]/[format "%d" [expr int([cam$audace(camNo) exptime])]] ([expr $k+1]:$nbr)" -fg $color(red)
         update
         after 1000 dispTime $k $nbr
      } else {
         $This.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }
   }

   ## brief mosaic acquisition
   #
   proc acqmosa { exptime binning { kkkk "" } { s "" } { mosa "" } } {
      variable This
      global audace
      global conf
      global caption
      global color

      #--- shortcuts
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- the exptime control is used to determine the exposure time for the image
      $camera exptime $exptime

      #--- the bin control is used to determine the binning data
      $camera bin [list $binning $binning]

      #---
      if {$exptime>1} {
      } else {
         $This.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }

      #--- beginning of acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $exptime

      #--- call to timer
      if {$exptime>1} {
         dispTimemosa $kkkk $s $mosa
      }

      #--- waiting for exposure end
      ::camera::waitStateStand $audace(camNo)

      #--- image viewing
      ::audace::autovisu $audace(visuNo)
   }

   proc dispTimemosa { { kkkk "" } { s "" } { mosa "" } } {
      variable This
      global audace
      global caption
      global color

      set t "[cam$audace(camNo) timer -1]"
      if {$t>1} {
         $This.para.labURL_status_cam configure -text "[expr $t-1]/[format "%d" [expr int([cam$audace(camNo) exptime])]] ([expr $s+1]-[expr $kkkk]:$mosa)" -fg $color(red)
         update
         after 1000 dispTimemosa $kkkk $s $mosa
      } else {
         $This.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }
   }

}

