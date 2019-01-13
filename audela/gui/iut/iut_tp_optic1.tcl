# This is the graphical user interface for
# students who want to use a webcam camera.
#
# 1st method to launch the GUI :
# Use the batch file audela_ups.bat in this folder
#
# 2nd method to launch the GUI :
# Create a shortcut to audela.exe and add arguments: --file ../gui/iut/iut_tp_optic1.tcl
#
# 3rd method to launch the GUI :
# Create a batch file (eg audela.bat), edit it and write: C:/audela/bin/audela.exe --file ../gui/iut/iut_tp_optic1.tcl
# (adapt the forder of Audela to yours)
#
# =============================================================================

set debug_level 0

# =======================================
# === Initialisation of the variables.
# === Initialisation des variables.
# =======================================

#--- definition of global variables (arrays)
#--- definition des variables globales (arrays)
global objnum        # index for devices
global caption    # texts of captions
global zone       # window name of usefull screen parts
global info_image # some infos on the current image

# --- selection of langage
source ../gui/iut/langage.tcl

# --- charge des proc utilitaires pour Tk
source ../gui/iut/tkutil.tcl

# --- charge des proc utilitaires pour l'analyze
source ../gui/iut/analyze.tcl

# --- charge des proc utilitaires pour plotxy
source ../gui/iut/mini_plotxy.tcl
package require BLT

#--- definition of captions
#--- definition des legendes
set caption(main_title) "TP optique (c) A. Klotz"
set caption(acq_blanc) "Acquisition image blanche\n(placer une feuille Canson blanche)"
set caption(acq_brut) "Acquisition image brute"
set caption(acq_cor) "Acquisition image corrigee\n(placer une feuille avec une mire)"
set caption(analyze_auto) "Analyse FTM automatique"
set caption(config) "Configuration"
set caption(load) "Charger"
set caption(save) "Sauver"
set caption(go) "GO"
set caption(wait) "En cours..."
set caption(exit) "Quitter"
set caption(source) "Source"
set caption(textexposure) "pose "
set caption(textbinning) "binning "
if {[string compare $langage english] ==0 } {
   set caption(main_title) "TP optic (c) A. Klotz"
   set caption(analyze_auto) "Automatic analysis"
   set caption(load) "Load"
   set caption(save) "Save"
   set caption(go) "GO"
   set caption(wait) "Wait..."
   set caption(exit) "Exit"
   set caption(textexposure) "pose "
   set caption(textbinning) "binning "
}

# --- definition of colors
# --- definition des couleurs
set color(back) #123456
set color(text) #FFFFFF
set color(back_image) #000000

# --- initialisation de variables de zone
set zone(naxis1) 0
set zone(naxis2) 0

lappend zone(cmd,history) ""
lappend zone(cmd,llength) 0

# ========================================
# === Setting the astronomical devices ===
# ========================================

# --- declare a new buffer in memory to place images
set objnum(buf1) [buf::create]
set objnum(buf2) [buf::create]

# --- declare a new camera
catch {porttalk open all}
package require Thread
set err [catch {
   set objnum(cam1) [cam::create webcam usb]
} msg ]
if {$err==1} {
   set res [tk_messageBox -message "Attention, la webcam n'est pas branchée.\n\n Brancher la webcam et appuyer sur Recommencer" -icon warning -type retrycancel]
   if {$res=="retry"} {
      set err [catch {
         set objnum(cam1) [cam::create webcam usb]
      } msg ]
      if {$err==1} {
         set res [tk_messageBox -message "Attention, la webcam n'est pas branchée." -icon info -type ok]
         exit
      }
   } else {
      exit
   }
}

cam$objnum(cam1) buf $objnum(buf1)
lassign [cam$objnum(cam1) nbpix] zone(naxis1) zone(naxis2)
set topnaxis1 [expr 400+$zone(naxis1)]
set topnaxis2 [expr 300+$zone(naxis2)]

# =========================================
# === Setting the graphic interface.
# === Met en place l'interface graphique.
# =========================================

# --- hide the window root
# --- cahce la fenetre racine
wm withdraw .

# --- create the toplevel window .test
# --- cree la fenetre .test de niveau le plus haut
toplevel .test -class Toplevel -bg $color(back)
wm geometry .test ${topnaxis1}x${topnaxis2}+0+0
wm resizable .test 1 1
wm minsize .test ${topnaxis1} [expr [winfo screenheight .]-100]
wm maxsize .test ${topnaxis1} [expr [winfo screenheight .]-100]
wm title .test $caption(main_title)

# --- create the command line
# --- cree la ligne de commande
entry .test.command_line \
   -font {{Arial}  8 bold} -textvariable command_line \
   -borderwidth 1 -relief groove  -bg $color(back) -fg $color(text)
pack .test.command_line \
   -in .test -fill x -side bottom \
   -padx 3 -pady 3
set zone(command_line) .test.command_line

frame .test.frame0

   # --- create a vertical scrobar for the status listbox
   # --- cree un acsenseur vertical pour la console de retour d'etats
   scrollbar .test.frame0.scr1 -orient vertical \
      -command {.test.frame0.lst1 yview} -takefocus 0 -borderwidth 1
   pack .test.frame0.scr1 \
      -in .test.frame0 -fill y -side right -anchor ne
   set zone(status_scrl) .test.frame0.scr1
   
   # --- create a console for status returned
   # --- cree la console de retour d'etats
   text .test.frame0.lst1 \
      -height 5 -font arial -yscrollcommand ".test.frame0.scr1 set" \
      -borderwidth 2 -relief sunken -bg $color(back) -fg $color(text)
   pack .test.frame0.lst1 \
      -in .test.frame0 -fill x -side bottom \
      -padx 3 -pady 3
   set zone(status_list) .test.frame0.lst1

pack .test.frame0 -side bottom -fill x -expand 1

set zone(scale1,val) [expr $zone(naxis2)/2]
set zone(scale1,val0) $zone(scale1,val)
set zone(coords,values) ""
set zone(contraste,ligne) ""

# --- create a frame to put images in it
frame .test.frame2 -borderwidth 0 -cursor arrow -bg $color(back)

   # --- create a frame to put images in it
   frame .test.frame2.frame1 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .test.frame2.frame1 \
      -in .test.frame2 -side top -expand 0 -fill none

   # --- create the canvas for the image
   # --- cree le canevas pour l'image
   canvas .test.frame2.frame1.image1 \
      -bg $color(back_image) -height $zone(naxis2) -width $zone(naxis1) 
   pack .test.frame2.frame1.image1 \
      -in .test.frame2.frame1 -expand 0 -side right -fill none
   set zone(image1) .test.frame2.frame1.image1

   # --- create the slider for the horizontal line
   scale .test.frame2.frame1.scale1 -orient vertical -from 1 -to $zone(naxis2) \
       -length $zone(naxis2)  -variable zone(scale1,val) -showvalue 0
   pack .test.frame2.frame1.scale1 \
      -in .test.frame2.frame1 -expand 0 -side right -fill none
   set zone(scale1) .test.frame2.frame1.scale1
       
   # --- create the canvas for the graph
   # --- cree le canevas pour le graphe
   canvas .test.frame2.graph1 \
      -bg $color(back_image)
   pack .test.frame2.graph1 \
      -in .test.frame2 -expand 0 -side top -fill both
   set zone(graph1) .test.frame2.graph1
   
pack .test.frame2 -in .test -anchor e -side right -expand 0 -fill y

# --- create a frame to put buttons in it
# --- cree un frame pour y mettre des boutons
frame .test.frame1 -borderwidth 0 -cursor arrow -bg $color(back)

   # --- cree une image pour le logo
   catch {image delete iutlogo}
   image create photo iutlogo
   iutlogo configure -file ../gui/iut/logo-iut.gif -format gif
   label .test.frame1.iutlogo1 -image iutlogo
   pack .test.frame1.iutlogo1 -side top -anchor center -padx 10 -pady 10

   # --- create the frame for acquisition
   frame .test.frame1.fra1 \
       -bg $color(back)

      # --- create the button 'acquition'
      # --- cree le bouton 'acquisition'
      button .test.frame1.fra1.but_acq_blanc \
         -text $caption(acq_blanc) -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -command { acq_image_blanc }
      pack .test.frame1.fra1.but_acq_blanc \
         -in .test.frame1.fra1 -side top -anchor center \
         -padx 3 -pady 3 -ipadx 10 -ipady 10
      set zone(but_acq_blanc) .test.frame1.fra1.but_acq_blanc

      # --- create the button 'acquition'
      # --- cree le bouton 'acquisition'
      button .test.frame1.fra1.but_acq_cor \
         -text $caption(acq_cor) -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -command { acq_image_cor }
      pack .test.frame1.fra1.but_acq_cor \
         -in .test.frame1.fra1 -side top -anchor center \
         -padx 3 -pady 3 -ipadx 10 -ipady 10
      set zone(but_acq_cor) .test.frame1.fra1.but_acq_cor

      # --- create the button 'analyze'
      # --- cree le bouton 'analyse'
      button .test.frame1.fra1.but_analyze_auto \
         -text $caption(analyze_auto) -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -command { analyze_auto2 }
      pack .test.frame1.fra1.but_analyze_auto \
         -in .test.frame1.fra1 -side top -anchor center \
         -padx 3 -pady 3 -ipadx 10 -ipady 10
      set zone(but_analyze_auto) .test.frame1.fra1.but_analyze_auto
      
      # --- create the button 'configuration'
      # --- cree le bouton 'configuration'
      button .test.frame1.fra1.but_acqs \
         -text $caption(config) -borderwidth 2 \
         -command { cam1 videosource }
      if {$debug_level>0} {
         pack .test.frame1.fra1.but_acqs \
            -in .test.frame1.fra1 -side top -anchor center \
            -padx 3 -pady 3
      }
      set zone(but_acqs) .test.frame1.fra1.but_acqs
         
      # --- create the button 'acquition'
      # --- cree le bouton 'acquisition'
      button .test.frame1.fra1.but_acq_brut \
         -text $caption(acq_brut) -borderwidth 2 \
         -command { acq_image_brut }
      if {$debug_level>0} {
         pack .test.frame1.fra1.but_acq_brut \
            -in .test.frame1.fra1 -side top -anchor center \
            -padx 3 -pady 3
      }
      set zone(but_acq_brut) .test.frame1.fra1.but_acq_brut
      
      # --- create the button 'save'
      # --- cree le bouton 'sauver'
      button .test.frame1.but_save \
         -text $caption(save) -borderwidth 2 \
         -command { save_image }
      if {$debug_level>0} {
         pack .test.frame1.but_save \
            -in .test.frame1.fra1 -side top -anchor center \
            -padx 15 -pady 3            
      }

      # --- create the button 'load'
      # --- cree le bouton 'charger'
      button .test.frame1.but_load \
         -text $caption(load) -borderwidth 2 \
         -command { load_image }
      if {$debug_level>0} {
         pack .test.frame1.but_load \
            -in .test.frame1.fra1 -side top -anchor center \
            -padx 15 -pady 3
      }

      # --- create the button 'source'
      # --- cree le bouton 'source'
      button .test.frame1.but_source \
         -text $caption(source)  -borderwidth 4 \
         -command { source ../gui/iut/analyze.tcl }
      if {$debug_level>0} {
         pack .test.frame1.but_source \
            -in .test.frame1.fra1 -side top -anchor center \
            -padx 3 -pady 3
      }

      # --- create the button 'exit'
      # --- cree le bouton 'quitter'
      button .test.frame1.but_exit \
         -text $caption(exit)  -borderwidth 4 \
         -command { destroy .test ; exit }
      if {$debug_level>0} {
         pack .test.frame1.but_exit \
            -in .test.frame1.fra1 -side top -anchor center \
            -padx 3 -pady 3
      }
         
   pack .test.frame1.fra1 \
      -in .test.frame1 -side top -anchor center

   label .test.frame1.coords -textvariable zone(coords,values) -bg $color(back) -fg $color(text) -font [ list {Arial} 16 bold ]
   pack .test.frame1.coords -side bottom -anchor center -padx 10 -pady 10
      
   label .test.frame1.contraste -textvariable zone(contraste,ligne) -bg $color(back) -fg $color(text) -font [ list {Arial} 16 bold ]
   #pack .test.frame1.contraste -side bottom -anchor center -padx 10 -pady 10
   
pack .test.frame1 -in .test -side right -anchor e -expand 1 -fill both
      
      
# ####################################################################################
# ####################################################################################
# ####################################################################################
      
proc cutline { {y 1} } {
   global zone
   set x2 $zone(naxis1)
   # -----
   if {[$zone(image1) gettags myLine]!=""} {
      $zone(image1) delete myLine 
   }
   $zone(image1) create line 1 $y $x2 $y -tag myLine -width 1 -fill red
   update
}

proc plot { {x {1 2 3}} {y {1 4 7}} { colorsymbol b+- } {sizesymbol 4} {options ""} } {
   global zone
   set err [catch {
      ::blt::graph $zone(graph1).xy
   } msg]
   #--- decode the selected color
   set colorstring rgbk
   set colorlist {red green blue black}
   set len [string length $colorsymbol]
   set mycolor [lindex $colorlist 0]
   for {set k 0} {$k<$len} {incr k} {
      set kk [string first [string index $colorsymbol $k] $colorstring]
      if {$kk!=-1} {
         set mycolor [lindex $colorlist $kk]
      }
   }
   #--- decode the selected symbol
   set symbolstring +xo*
   set symbollist {splus scross circle diamond}
   set mysymbol [lindex $symbollist 0]
   for {set k 0} {$k<$len} {incr k} {
      set kk [string first [string index $colorsymbol $k] $symbolstring]
      if {$kk!=-1} {
         set mysymbol [lindex $symbollist $kk]
      }
   }
   #--- decode the selected line style
   set linestring -.:
   set mylinewidth 1
   set linelist [list [list -linewidth $mylinewidth] [list -linewidth 0] \
            [list -dashes dot -linewidth $mylinewidth] ]
   set myline [lindex $linelist 0]
   for {set k 0} {$k<$len} {incr k} {
      set kk [string first [string index $colorsymbol $k] $linestring]
      if {$kk!=-1} {
         set myline [lindex $linelist $kk]
      }
   }
   # -----
   set handler myLine0   
   #tk_messageBox -message "Etape 4 [llength $x]"
   set err [catch {
      $zone(graph1).xy element create $handler -xdata $x -ydata $y -symbol $mysymbol -color $mycolor -pixel $sizesymbol
      $zone(graph1).xy marker create line -coords {} -name myLine1 -dashes dash -linewidth 2 -outline blue -xor yes
   } msg]
   if {$err==1} {
      $zone(graph1).xy element configure $handler -xdata $x -ydata $y -symbol $mysymbol -color $mycolor -pixel $sizesymbol
   }
   $zone(graph1).xy legend configure -hide yes
   pack $zone(graph1).xy -expand 1 -fill both
   $zone(graph1).xy element show $handler   
   #--   gestion des crosshairs
   $zone(graph1).xy crosshairs on
   $zone(graph1).xy crosshairs configure -color red -dashes 2
   bind $zone(graph1).xy <Motion> {
      set res [::mini_plotxy::viewCrosshairs %W %x %y]
      lassign $res x y
      set zone(coords,values) "x=$x y=$y"
      update
   }
   ::mini_plotxy::createBindingsZoom $zone(graph1).xy
   ::mini_plotxy::unset_selected_region
   update
}

proc cutbuf { yscreen } {
   global zone objnum
   cutline $yscreen
   set naxis1 $zone(naxis1)
   set naxis2 $zone(naxis2)
   set y [expr $naxis2-$yscreen+1]
   set xs ""
   set ys ""
   set x 1
   set err [catch {
      lassign [buf$objnum(buf1) getpix [list $x $y]] nplan r g b
   } msg ]
   if {($err==1)} {
      set r 0 ; set g 0 ;set b 0
   }   
   if {($r=="")} {
      set r 0 ; set g 0 ;set b 0
   }   
   if {($g=="")} {
      set r $r ; set g $r ;set b $r
   }   
   set gray0 [expr ($r+$g+$b)/3.]
   lappend xs $x
   lappend ys $gray0
   for {set x 2} {$x<=$naxis1} {incr x} {
      lappend xs $x
      lappend ys $gray0
      set err [catch {
         lassign [buf$objnum(buf1) getpix [list $x $y]] nplan r g b
      } msg ]
      if {($err==1)} {
         set r 0 ; set g 0 ;set b 0
      }   
      if {($r=="")} {
         set r 0 ; set g 0 ;set b 0
      }   
      if {($g=="")} {
         set r $r ; set g $r ;set b $r
      }   
      set gray [expr ($r+$g+$b)/3.]
      lappend xs $x
      lappend ys $gray
      set gray0 $gray
   }   
   lappend xs $x
   lappend ys $gray
   plot $xs $ys r+- 1
   # --- contraste de la ligne = variance/moyenne
   package require math::statistics
   set mean [::math::statistics::mean $ys]
   set std [::math::statistics::stdev $ys]
   set err [catch {
      set contraste [expr $std*$std/$mean]
   } msg]
   if {$err==0} {
      set zone(contraste,ligne) "Contraste de la ligne = [format %.1f $contraste]"  
   } else {
      set zone(contraste,ligne) ""  
   }
   update   
}

proc console_info { msg } {
   global zone objnum
   $zone(status_list) insert end "$msg\n"
   $zone(status_list) see end
}

# ####################################################################################
# ####################################################################################
# ####################################################################################

cutbuf 1

# =========================================
# === Setting the binding.
# === Met en place les liaisons.
# =========================================

# --- destroy the toplevel window with the upper right cross
# --- detruit la fenetre principale avec la croix en haut a droite
bind .test <Destroy> { destroy .test; exit }

# --- execute a command from the command line
# --- execute une commande a partir de la ligne de commande
bind $zone(command_line) <Key-Return> {
   global zone
   set cmd $command_line
   $zone(status_list) insert end $cmd
   $zone(status_list) insert end "\n"
   if { [catch {uplevel #0 $cmd} res] != 0} {
      $zone(status_list) insert end "# $res\n"
      regsub -all {;} $res "," res2
      regsub -all \n $res2 " " res
      set Res [list 1 $res]
   } else {
      if { [string compare $res ""] != 0} {
         $zone(status_list) insert end "# $res\n"
         regsub -all {;} $res "," res2
         regsub -all \n $res2 " " res
         set Res [list 0 $res]
      } else {
         set Res [list 0 ""]
      }
   }
   $zone(status_list) insert end "\n"
   historik add "$cmd"
   $zone(status_list) see end
   set command_line ""
}

# --- recall the command line
# --- rappel la ligne de commande
bind $zone(command_line) <Key-Up> {
   set command_line [historik before]
   $zone(command_line) icursor end
}
bind $zone(command_line) <Key-Down> {
   set command_line [historik after]
   $zone(command_line) icursor end
}
bind $zone(command_line) <Key-Escape> {
   set $command_line [historik synchro]
   $zone(command_line) icursor end
}

bind .test.frame2.frame1.scale1 <ButtonRelease-1> {
   global zone
   set yscreen $zone(scale1,val)
   cutbuf $yscreen
   set zone(scale1,val0) $zone(scale1,val) 
}

# --- affiche la valeur du pixel pointe dans l'image
bind $zone(image1) <Motion> {
   global zone
   # --- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
   set xy [screen2Canvas [list %x %y]]
   # --- Transforme les coordonnees canvas (x,y) en coordonnees image (xi,yi)
   set xyi [canvas2Picture $xy]
   set xi [lindex $xyi 0]
   set yi [lindex $xyi 1]
   # --- Intens contiendra l'intensite du pixel pointe
   set intens -
   catch {set intens [buf1 getpix [list $xi $yi]]}
   # --- Affichage des coordonnees
   wm title .test "($xi,$yi)=$intens   "
}

# ========================================
# === Setting the image visu ===
# ========================================

# --- declare a new visu space to display the buffer
set objnum(visu1) [visu::create $objnum(buf1) 1 ]

# --- create a widget image in a canvas to display that of the visu space
$zone(image1) create image 1 1 -image imagevisu1 -anchor nw -tag img1

cd ../images

# ===================================
# === It is the end of the script ===
# ===================================
proc acq_image_brut { } {
   #--- variables shared
   global objnum
   global caption
   global zone
   global info_image

   set ee 1
   set bb 1

   camacq $ee $bb   
   
   set yscreen $zone(scale1,val)
   cutbuf $yscreen

}

proc acq_image_blanc { } {
   #--- variables shared
   global objnum
   global caption
   global zone
   global info_image

   set ee 1
   set bb 1

   set ext .fit
   set fname blanc
   set rep .
   if {1==1} {
      set first 1
      set ni 3
      for {set k 1} {$k<=$ni} {incr k} {
         camacq $ee $bb   
         buf1 save ${fname}$k
      }
      for {set plan 1} {$plan<=3} {incr plan} {
         for {set k 1} {$k<=$ni} {incr k} {
            buf1 load3d ${fname}${k}${ext} $plan
            buf1 setkwd [list {NAXIS} 2 {int} { number of data axes } { } ]
            buf1 save i${k}${ext}
         }         
         ttscript2 "IMA/STACK \"$rep\" \"i\" $first $ni \"$ext\" \"$rep\" \"j${plan}\" . \"$ext\" MEAN"
         buf1 load j${plan}
         buf1 imaseries "CONV kernel_type=gaussian sigma=2"
         buf1 save j${plan}
      }      
      fitsconvert3d j 3 ${ext} $fname
      buf1 load $fname
   } else {
      camacq $ee $bb   
      buf1 save ${fname}
   }
   visu
   
   set yscreen $zone(scale1,val)
   cutbuf $yscreen

}

proc acq_image_cor { } {
   #--- variables shared
   global objnum
   global caption
   global zone
   global info_image

   set ee 1
   set bb 1

   set err [catch {
      buf1 load blanc
   } msg]
   if {$err==1} {
      tk_messageBox -message "Effectuez d'abord un blanc\n\nAppuyer sur le bouton $caption(acq_blanc)" -icon error
   } else {
      set myStatistics [buf1 stat]
      set moy_blanc [lrange $myStatistics 4 4]
      camacq $ee $bb
      buf1 div blanc $moy_blanc 
      buf1 save cor 
      visu
   }
   
   set yscreen $zone(scale1,val)
   cutbuf $yscreen

}

proc camacq { {e "1"} {b "2"} } {
   #--- variables shared
   global objnum
   global caption
   global zone
   global info_image

   $zone(but_acq_cor) configure -relief sunken -state disable
   $zone(but_acq_blanc) configure -relief sunken -state disable
   $zone(but_acq_brut) configure -relief sunken -state disable

   cam1 exptime $e
   cam1 bin [list $b $b]
   console_info "Acquisition en cours..."
   for {set k 0} {$k<1} {incr k} {
      cam1 acq
      update
      set timer 0
      while {$timer>-1} {
         set timer [cam1 timer]
         update
         after 50
      }
   }
   console_info "Acquisition terminee [lindex [buf1 getkwd DATE-OBS] 1]"

   visu
   
   $zone(but_acq_cor) configure -relief raised -state active
   $zone(but_acq_blanc) configure -relief raised -state active
   $zone(but_acq_brut) configure -relief raised -state active
   
}

proc visu { } {
   #--- get statistics from the acquired image
   set myStatistics [buf1 stat]
   set maxi [lrange $myStatistics 2 2]
   set mini [lrange $myStatistics 3 3]

   #--- and display it with the right thresholds
   set lc [lrange $myStatistics 1 1]
   if {$lc < 0} { set lc 0 }
   if {$lc > 32767} { set lc 0 }
   set hc [lrange $myStatistics 0 0]
   if {$hc < 0} { set hc 32767 }
   if {$hc > 32767} { set hc 32767 }
   set hc [expr 1.1*$maxi]
   set lc [expr 0.9*$mini]

   visu1 cut [list $hc $lc]
   set zone(naxis1) [lindex [buf1 getkwd NAXIS1] 1]
   set zone(naxis2) [lindex [buf1 getkwd NAXIS2] 1]
   visu1 clear
   visu1 disp
}

proc load_image {} {
   #--- variables shared
   global objnum
   global caption
   global zone
   global info_image

   set filename [tk_getOpenFile -title "Charger une image" -filetypes {{{Images FITS} {.fit}}}]
   if {[string compare $filename ""] != 0 } {
      set result [buf1 load $filename]
      set zone(naxis1) [lindex [buf1 getkwd NAXIS1] 1]
      set zone(naxis2) [lindex [buf1 getkwd NAXIS2] 1]
      visu1 clear
      visu
   }
}

proc save_image {} {
   #--- variables shared
   global objnum
   global caption
   global zone
   global info_image

   set filename [tk_getSaveFile -title "Sauver une image" -filetypes {{{Images FITS} {.fit}}}]
   if {[string compare $filename ""] != 0 } {
      set result [buf1 save $filename]
   }
}

proc analyze_auto {} {
   global zone objnum
   set fname cor
   set ext .fit
   set rep .
   # --- fabrique l'image monochrome
   for {set plan 1} {$plan<=3} {incr plan} {
      buf$objnum(buf2) load3d ${fname}${ext} $plan
      buf$objnum(buf2) setkwd [list {NAXIS} 2 {int} { number of data axes } { } ]
      buf$objnum(buf2) save i${plan}${ext}
   }         
   ttscript2 "IMA/STACK \"$rep\" \"i\" 1 3 \"$ext\" \"$rep\" \"i\" . \"$ext\" MEAN"
   # ======= Recherche des parametres importants sur X
   buf$objnum(buf2) load i   
   set naxis1 [buf$objnum(buf2) getpixelswidth]
   set naxis2 [buf$objnum(buf2) getpixelsheight]
   # --- profil
   buf$objnum(buf2) imaseries "SORTY percent=3 y1=1 y2=$naxis2 height=1 bitpix=32"
   set xxs ""
   set yys ""
   set xs ""
   set ys ""
   set x 1
   set y 1
   set err [catch {
      lassign [buf$objnum(buf2) getpix [list $x $y]] nplan gray
   } msg ]
   if {($err==1)||($gray=="")} {
      set gray 0
   }
   set gray0 $gray
   set maxi 0
   for {set x 1} {$x<=$naxis1} {incr x} {
      lappend xs $x
      lappend ys $gray0
      set err [catch {
         lassign [buf$objnum(buf2) getpix [list $x $y]] nplan gray
      } msg ]
      if {($err==1)||($gray=="")} {
         set gray 0
      }
      if {$gray>$maxi} {
         set maxi $gray
      }
      lappend xs $x
      lappend ys $gray
      set gray0 $gray
      lappend xxs $x
      lappend yys $gray
   }   
   lappend xs $x
   lappend ys $gray
   #plot $xs $ys r+- 1
   # --- derivee
   set dxs ""
   set dys ""
   set ds ""
   for {set x 5} {$x<=[expr $naxis1-5]} {incr x} {
      set y1 [lindex $yys [expr $x-1]]
      set y  [lindex $yys [expr $x]]
      set y2 [lindex $yys [expr $x+1]]
      set d [expr $y*$y*($y2-$y1)/2.]
      lappend dxs $x
      lappend dys $d
      lappend ds [list $x $d]
   }  
   plot $dxs $dys r+- 1
   # --- affine les pics de derives
   set n [llength $dxs]
   set tmp_dys [lindex $dys 0]
   for {set k 1} {$k<=[expr $n-2]} {incr k} {
      set d1 [lindex $dys [expr $k-1]]
      set d  [lindex $dys $k]
      set d2 [lindex $dys [expr $k+1]]
      if {(($d>=$d1)&&($d>=$d2))||(($d<=$d1)&&($d<=$d2))} {
         lappend tmp_dys $d
      } else {
         lappend tmp_dys 0
      }
   }
   lappend tmp_dys [lindex $dys end]
   set dys $tmp_dys 
   set tmp_ds ""
   for {set k 0} {$k<$n} {incr k} {
      set d [lindex $dys $k]
      set x [lindex [lindex $ds $k] 0]
      lappend tmp_ds [list $x $d]
   }
   set ds $tmp_ds
   plot $dxs $dys r+- 1
   # --- recherche xdeb = le premier pic negatif de la derivee
   set dds [lsort -increasing -real -index 1 $ds]
   #console_info "dds=[lrange $dds 0 7]"
   set ls [lrange $dds 0 4]
   set ls [lsort -increasing -real -index 0 $ls]
   set xdeb [lindex [lindex $ls 0] 0]
   # --- recherche per = la periodicite des pics negatifs de la derivee   
   set ddxs ""
   for {set k 1} {$k<=4} {incr k} {
      set x1 [lindex [lindex $ls [expr $k-1]] 0]
      set x2 [lindex [lindex $ls $k] 0]
      lappend ddxs [expr $x2-$x1]
   }
   # --- recherche xfin = le premier pic positif de la derivee
   set dds [lsort -decreasing -real -index 1 $ds]
   #console_info "dds=[lrange $dds 0 7]"
   set ls [lrange $dds 0 4]
   set ls [lsort -increasing -real -index 0 $ls]
   set xfin [lindex [lindex $ls 0] 0]
   # --- recherche per = la periodicite des pics positifs de la derivee   
   for {set k 1} {$k<=4} {incr k} {
      set x1 [lindex [lindex $ls [expr $k-1]] 0]
      set x2 [lindex [lindex $ls $k] 0]
      lappend ddxs [expr $x2-$x1]
   }
   set n [llength $ddxs]
   set ddxs [lsort -real -increasing $ddxs]
   set xper [lindex $ddxs [expr int($n/2)]]
   # --- on affine la periode
   set moy 0
   set nn 0
   for {set k 0} {$k<$n} {incr k} {
      set per [lindex $ddxs $k]
      set dper [expr abs($per-$xper)]
      if {$dper<3} {
         set moy [expr $moy+$per]
         incr nn
      }
   }
   if {$nn>0} {
      set xper [format %.2f [expr 1.*$moy/$nn]]
   }
   console_info "Avant vote: xdeb=$xdeb xfin=$xfin xper=$xper ddxs=$ddxs"
   # --- on recherche les meilleurs pics negatifs compatibles avec la periodicite
   if {1==1} {
      set nech 15
      set nfinal 5
      set dds [lsort -increasing -real -index 1 $ds]
      set ls [lrange $dds 0 [expr $nech-1]]
      set ls [lsort -increasing -real -index 0 $ls]
      catch {unset votes}
      for {set k1 0} {$k1<[expr $nech-$nfinal-1]} {incr k1} {
         set z1 [lindex [lindex $ls $k1] 0]
         #console_info "======= k1=$k1"
         set votes($k1) 0
         for {set k2 [expr $k1+1]} {$k2<$nech} {incr k2} {
            set z2 [lindex [lindex $ls $k2] 0]
            set dist [expr abs($z1-$z2)]
            set phase [expr 1.*$dist/$xper-floor($dist/$xper)]
            if {$phase>0.5} { set phase [expr $phase-1.] }
            set dpix [expr abs($phase)*$xper] 
            set mult [expr round($dist/$xper)]
            if {$mult==0} {set mult 1.}
            if {$dpix<=[expr 1.5*$mult]} {
               incr votes($k1)
            }
            #console_info "k1=$k1 k2=$k2 z1=$z1 z2=$z2 dist=$dist dpix=$dpix votes($k1)=$votes($k1)"
         }
      }
      set vs ""
      for {set k 0} {$k<[expr $nech-$nfinal-1]} {incr k} {
         lappend vs [list $k $votes($k) [lindex $ls $k]]
         #console_info "Pic negatif: vote($k) $votes($k) [lindex $ls $k]"
      }
      set vs [lsort -decreasing -real -index 1 $vs]
      set vs [lrange $vs 0 4]
      set ls ""
      for {set k 0} {$k<10} {incr k} {
         set v [lindex $vs $k]
         lappend ls [lindex $v 2]
      }
      set xdeb [lindex [lindex $ls 0] 0]
   }
   # --- on recherche les meilleurs pics positifs compatibles avec la periodicite
   if {1==1} {
      set nech 15
      set nfinal 5
      set dds [lsort -decreasing -real -index 1 $ds]
      set ls [lrange $dds 0 [expr $nech-1]]
      set ls [lsort -increasing -real -index 0 $ls]
      catch {unset votes}
      for {set k1 0} {$k1<[expr $nech-$nfinal-1]} {incr k1} {
         set z1 [lindex [lindex $ls $k1] 0]
         #console_info "======= k1=$k1"
         set votes($k1) 0
         for {set k2 [expr $k1+1]} {$k2<$nech} {incr k2} {
            set z2 [lindex [lindex $ls $k2] 0]
            set dist [expr abs($z1-$z2)]
            set phase [expr 1.*$dist/$xper-floor($dist/$xper)]
            if {$phase>0.5} { set phase [expr $phase-1.] }
            set dpix [expr abs($phase)*$xper] 
            set mult [expr round($dist/$xper)]
            if {$mult==0} {set mult 1.}
            if {$dpix<=[expr 1.5*$mult]} {
               incr votes($k1)
            }
            #console_info "k1=$k1 k2=$k2 z1=$z1 z2=$z2 dist=$dist dpix=$dpix votes($k1)=$votes($k1)"
         }
      }
      set vs ""
      for {set k 0} {$k<[expr $nech-$nfinal-1]} {incr k} {
         lappend vs [list $k $votes($k) [lindex $ls $k]]
         #console_info "Pic positif: vote($k) $votes($k) [lindex $ls $k]"
      }
      set vs [lsort -decreasing -real -index 1 $vs]
      set vs [lrange $vs 0 4]
      set ls ""
      for {set k 0} {$k<10} {incr k} {
         set v [lindex $vs $k]
         lappend ls [lindex $v 2]
      }
      set xfin [lindex [lindex $ls 0] 0]
   }
   console_info "Apres vote: xdeb=$xdeb xfin=$xfin xper=$xper ddxs=$ddxs"
   if {$xfin<$xdeb} {
      set xfin [expr $xdeb+$xper*100./130.]
      console_info "Apres correction: xdeb=$xdeb xfin=$xfin xper=$xper ddxs=$ddxs"
   }
   #tk_messageBox -message "toto"
   # ======= Recherche des parametres importants sur Y
   buf$objnum(buf2) load i
   set naxis1 [buf$objnum(buf2) getpixelswidth]
   set naxis2 [buf$objnum(buf2) getpixelsheight]
   # --- profil
   buf$objnum(buf2) imaseries "SORTX percent=10 x1=1 x2=$naxis1 width=1 bitpix=32"
   set xxs ""
   set yys ""
   set xs ""
   set ys ""
   set x 1
   set y 1
   set err [catch {
      lassign [buf$objnum(buf2) getpix [list $y $x]] nplan gray
   } msg ]
   if {($err==1)||($gray=="")} {
      set gray 0
   }
   set gray0 $gray
   set maxi 0
   for {set x 1} {$x<=$naxis2} {incr x} {
      lappend xs $x
      lappend ys $gray0
      set err [catch {
         lassign [buf$objnum(buf2) getpix [list $y $x]] nplan gray
      } msg ]
      if {($err==1)||($gray=="")} {
         set gray 0
      }
      if {$gray>$maxi} {
         set maxi $gray
      }
      lappend xs $x
      lappend ys $gray
      set gray0 $gray
      lappend xxs $x
      lappend yys $gray
   }   
   lappend xs $x
   lappend ys $gray
   plot $xs $ys r+- 1
   # --- derivee
   set dxs ""
   set dys ""
   set ds ""
   for {set x 5} {$x<=[expr $naxis2-5]} {incr x} {
      set y1 [lindex $yys [expr $x-1]]
      set y  [lindex $yys [expr $x]]
      set y2 [lindex $yys [expr $x+1]]
      set d [expr $y*$y*($y2-$y1)/2.]
      lappend dxs $x
      lappend dys $d
      lappend ds [list $x $d]
   }   
   plot $dxs $dys r+- 1
   # --- affine les pics de derives
   set n [llength $dxs]
   set tmp_dys [lindex $dys 0]
   for {set k 1} {$k<=[expr $n-2]} {incr k} {
      set d1 [lindex $dys [expr $k-1]]
      set d  [lindex $dys $k]
      set d2 [lindex $dys [expr $k+1]]
      if {(($d>=$d1)&&($d>=$d2))||(($d<=$d1)&&($d<=$d2))} {
         lappend tmp_dys $d
      } else {
         lappend tmp_dys 0
      }
   }
   lappend tmp_dys [lindex $dys end]
   set dys $tmp_dys 
   set tmp_ds ""
   for {set k 0} {$k<$n} {incr k} {
      set d [lindex $dys $k]
      set x [lindex [lindex $ds $k] 0]
      lappend tmp_ds [list $x $d]
   }
   set ds $tmp_ds
   plot $dxs $dys r+- 1
   # --- recherche xdeb = le premier pic negatif de la derivee
   set dds [lsort -increasing -real -index 1 $ds]
   #console_info "dds=[lrange $dds 0 7]"
   set ls [lrange $dds 0 2]
   set ls [lsort -increasing -real -index 0 $ls]
   set ydeb [lindex [lindex $ls 0] 0]
   # --- recherche per = la periodicite des pics negatifs de la derivee   
   set ddxs ""
   for {set k 1} {$k<=2} {incr k} {
      set x1 [lindex [lindex $ls [expr $k-1]] 0]
      set x2 [lindex [lindex $ls $k] 0]
      lappend ddxs [expr $x2-$x1]
   }
   # --- recherche xfin = le premier pic positif de la derivee
   set dds [lsort -decreasing -real -index 1 $ds]
   #console_info "dds=[lrange $dds 0 7]"
   set ls [lrange $dds 0 2]
   set ls [lsort -increasing -real -index 0 $ls]
   set yfin [lindex [lindex $ls 0] 0]
   # --- recherche per = la periodicite des pics positifs de la derivee   
   # set ddxs ""
   for {set k 1} {$k<=2} {incr k} {
      set x1 [lindex [lindex $ls [expr $k-1]] 0]
      set x2 [lindex [lindex $ls $k] 0]
      lappend ddxs [expr $x2-$x1]
   }
   set n [llength $ddxs]
   set yper [lindex [lsort -real -increasing $ddxs] [expr int($n/2)]]
   console_info "ydeb=$ydeb yfin=$yfin yper=$yper ddxs=$ddxs"
   # =========== Cacul des contrastes
   buf$objnum(buf2) load i
   set naxis1 [buf$objnum(buf2) getpixelswidth]
   set naxis2 [buf$objnum(buf2) getpixelsheight]
   set cs ""
   set pass ""
   set pas 0
   for {set ky 0} {$ky<3} {incr ky} {
      set y1 [expr $ydeb+$ky*$yper]
      set y2 [expr $y1+$yfin-$ydeb]
      set dy [expr ($y2-$y1)]
      set y1 [expr $y1+0.1*$dy]
      set y2 [expr $y2-0.1*$dy]
      for {set kx 0} {$kx<5} {incr kx} {
         set x1 [expr int($xdeb+$kx*$xper)]
         set x2 [expr int($x1+$xfin-$xdeb)]
         incr pas
         set ctot 0
         set ntot 0
         set nny 5
         for {set kky 0} {$kky<$nny} {incr kky} {
            set y [expr int($y1+$kky/$nny*($y2-$y1))]
            #console_info "x1=$x1 x2=$x2 y1=$y1 y2=$y2 y=$y"
            # --- profil pour ce pas
            set dx [expr int($xper*0.15)]
            set as ""
            set vs ""
            for {set x [expr $x1+$dx]} {$x<=[expr $x2-$dx]} {incr x} {
               set err [catch {
                  lassign [buf$objnum(buf2) getpix [list $x $y]] nplan gray
               } msg ]
               if {($err==1)||($gray=="")} {
                  set gray 0
               }
               lappend as $x
               lappend vs $gray            
            }
            set n [llength $vs]
            set ls [lsort -increasing -real $vs]
            set kmini [expr int($n*0.1)]
            set kmaxi [expr int($n*0.9)]
            set vmini [lindex $ls $kmini]
            set vmaxi [lindex $ls $kmaxi]
            set err [catch {
               set c [expr ($vmaxi-$vmini)/($vmaxi+$vmini)]
               incr ntot
            } msg]
            if {$err==1} {
               set c 0
            }
            #console_info "pas=$pas vmini=$vmini vmaxi=$vmaxi c=$c"
            set ctot [expr $ctot+$c]
         }
         if {$ntot>0} {
            set c [expr 1.*$ctot/$ntot]
         } else {
            set c 0.
         }
         console_info "pas=$pas x1=[format %.0f $x1] x2=[format %.0f $x2] y1=[format %.0f $y1] y2=[format %.0f $y2] c=[format %.4f $c] ($ntot)"
         plot $as $vs r+- 1
         tk_messageBox -message "x1=[format %.0f $x1] x2=[format %.0f $x2]\ny1=[format %.0f $y1] y2=[format %.0f $y2]\n\npas=$pas c=[format %.4f $c] ($ntot)"
         lappend pass $pas
         lappend cs $c
      }
   }
   #plot $pass $cs ro- 4
   # --- normalisation des contrastes =1 pourla plus basse frequence
   set np [llength $pass]
   set logfreqs ""
   set logcnorms ""
   set cnorms ""
   set cmax   [lindex $cs end]
   # on enleve le premier point qui est affecté de l'aliasing
   for {set kp 1} {$kp<$np} {incr kp} {
      set pas [lindex $pass $kp]
      set c   [lindex $cs $kp]
      set err [catch {
         set cnorm [expr $c/$cmax]
      } msg]
      if {$err==1} {
         set cnorm 1e-3
      }
      if {$cnorm==0} {
         set cnorm 1e-3
      }
      set hauteur 50.0
      set periode [expr 1.15/$pas] ; # cm/alternance
      set separation [expr $periode/$hauteur] ; # radian/alternance
      set separation [expr $separation*60*180/3.1416] ; # arcmin/alternance
      set logfreq [expr log10($separation)] ; # 1/arcmin
      set logcnorm [expr 20*log10($cnorm)]
      lappend logfreqs $logfreq
      lappend logcnorms $logcnorm
      lappend cnorms $cnorm
   }
   #plot $logfreqs $logcnorms ro- 4
   plot $logfreqs $cnorms ro- 4

}

