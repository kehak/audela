# This is the graphical user interface for
# students who want to modify the file tp.c
# of the Audine camera.
#
# 1st method to launch the GUI :
# Use the batch file audela_ups.bat in this folder
#
# 2nd method to launch the GUI :
# Create a shortcut to audela.exe and add arguments: --file ../gui/ups/ups.tcl
#
# 3rd method to launch the GUI :
# Create a batch file (eg audela.bat), edit it and write: C:/audela/bin/audela.exe --file ../gui/ups/ups.tcl
# (adapt the forder of Audela to yours)
#
# =============================================================================

# =======================================
# === Initialisation of the variables.
# === Initialisation des variables.
# =======================================

#--- definition of global variables (arrays)
#--- definition des variables globales (arrays)
global num        # index for devices
global caption    # texts of captions
global zone       # window name of usefull screen parts
global info_image # some infos on the current image

#--- selection of langage
source ../gui/ups/langage.tcl

# --- charge des proc utilitaires pour Tk
source ../gui/ups/tkutil.tcl

#--- definition of captions
#--- definition des legendes
if {[string compare $langage english] ==0 } {
     set caption(main_title) "TP camera (c) A. Klotz & D. Marchais"
     set caption(acq) "CCD Acquisition"
     set caption(acqs) "Special Acquisition"
     set caption(load) "Load"
     set caption(save) "Save"
     set caption(go) "GO"
     set caption(wait) "Wait..."
     set caption(exit) "Exit"
     set caption(textexposure) "pose "
     set caption(textbinning) "binning "
}
if {[string compare $langage french] ==0 } {
     set caption(main_title) "TP camera (c) A. Klotz & D. Marchais"
     set caption(acq) "Acquisition CCD"
     set caption(acqs) "Acquisition Spéciale"
     set caption(load) "Charger"
     set caption(save) "Sauver"
     set caption(go) "GO"
     set caption(wait) "En cours..."
     set caption(exit) "Quitter"
     set caption(textexposure) "pose "
     set caption(textbinning) "binning "
}

#--- definition of colors
#--- definition des couleurs
set color(back) #123456
set color(text) #FFFFFF
set color(back_image) #000000

# --- initialisation de variables de zone
set zone(naxis1) 0
set zone(naxis2) 0

# =========================================
# === Setting the graphic interface.
# === Met en place l'interface graphique.
# =========================================

#--- hide the window root
#--- cahce la fenetre racine
wm withdraw .

#--- create the toplevel window .test
#--- cree la fenetre .test de niveau le plus haut
toplevel .test -class Toplevel -bg $color(back)
wm geometry .test 771x739+0+0
wm resizable .test 1 1
wm minsize .test 600 400
wm maxsize .test 1024 768
wm title .test $caption(main_title)

#--- create the command line
#--- cree la ligne de commande
entry .test.command_line \
   -font {{Arial}  8 bold} -textvariable command_line \
   -borderwidth 1 -relief groove
pack .test.command_line \
   -in .test -fill x -side bottom \
   -padx 3 -pady 3
set zone(command_line) .test.command_line

#--- create a console for status returned
#--- cree la console de retour d'etats
listbox .test.lst1 \
   -height 3 -font arial \
   -borderwidth 1 -relief sunken
pack .test.lst1 \
   -in .test -fill x -side bottom \
   -padx 3 -pady 3
set zone(status_list) .test.lst1

#--- create a vertical scrobar for the status listbox
#--- cree un acsenseur vertical pour la console de retour d'etats
scrollbar .test.lst1.scr1 -orient vertical \
   -command {.test.lst1 yview}
pack .test.lst1.scr1 \
   -in .test.lst1 -side right -fill y
set zone(status_scrl) .test.lst1.scr1

#--- create a frame to put buttons in it
#--- cree un frame pour y mettre des boutons
frame .test.frame1 \
   -borderwidth 0 -cursor arrow -bg $color(back)
pack .test.frame1 \
   -in .test -anchor s -side bottom -expand 0 -fill x

# --- cree une image pour le logo
catch {image delete upslogo}
image create photo upslogo
upslogo configure -file ../gui/ups/logo-ups.gif -format gif
label .test.frame1.upslogo1 -image upslogo
pack .test.frame1.upslogo1 -side left -padx 10 -pady 10

#--- create the frame for acquisition
frame .test.frame1.fra1 \
    -bg $color(back)
pack .test.frame1.fra1 \
   -in .test.frame1 -side left -anchor w

#--- create the menu 'exposure'
tk_optionMenu .test.frame1.fra1.optionmenu1 \
   exposure "$caption(textexposure) 0.01 s" "$caption(textexposure) 0.1 s" "$caption(textexposure) 1 s" "$caption(textexposure) 5 s" "$caption(textexposure) 10 s" "$caption(textexposure) 30 s"
   .test.frame1.fra1.optionmenu1 configure \
   -disabledforeground $color(text) -fg $color(text) \
   -activeforeground $color(text) \
   -activebackground $color(back) -bg $color(back) \
   -highlightbackground $color(back)
pack .test.frame1.fra1.optionmenu1 -side top -in .test.frame1.fra1 -pady 3

#--- create the menu 'binning'
tk_optionMenu .test.frame1.fra1.optionmenu2 \
   binning "$caption(textbinning) 1x1" "$caption(textbinning) 2x2" "$caption(textbinning) 4x4"
.test.frame1.fra1.optionmenu2 configure \
   -disabledforeground $color(text) -fg $color(text) \
   -activeforeground $color(text) \
   -activebackground $color(back) -bg $color(back) \
   -highlightbackground $color(back)
pack .test.frame1.fra1.optionmenu2 -side top -in .test.frame1.fra1 -pady 3

#--- create the button 'acquitiion'
#--- cree le bouton 'acquisition'
button .test.frame1.fra1.but_acq \
   -text $caption(acq) -borderwidth 4 \
   -command { acq_image $exposure $binning }
pack .test.frame1.fra1.but_acq \
   -in .test.frame1.fra1 -side left -anchor w \
   -padx 3 -pady 3
set zone(but_acq) .test.frame1.fra1.but_acq

#--- create the button 'special acquitiion'
#--- cree le bouton 'acquisition speciale'
button .test.frame1.fra1.but_acqs \
   -text $caption(acqs) -borderwidth 4 \
   -command { acqs_image $exposure $binning }
pack .test.frame1.fra1.but_acqs \
   -in .test.frame1.fra1 -side left -anchor w \
   -padx 3 -pady 3
set zone(but_acqs) .test.frame1.fra1.but_acqs

#--- create the button 'save'
#--- cree le bouton 'sauver'
button .test.frame1.but_save \
   -text $caption(save) -borderwidth 4 \
   -command { save_image }
pack .test.frame1.but_save \
   -in .test.frame1 -side left -anchor w \
   -padx 15 -pady 3

#--- create the button 'load'
#--- cree le bouton 'charger'
button .test.frame1.but_load \
   -text $caption(load) -borderwidth 4 \
   -command { load_image }
pack .test.frame1.but_load \
   -in .test.frame1 -side left -anchor w \
   -padx 15 -pady 3

#--- create the button 'exit'
#--- cree le bouton 'quitter'
button .test.frame1.but_exit \
   -text $caption(exit)  -borderwidth 4 \
   -command { destroy .test ; exit }
pack .test.frame1.but_exit \
   -in .test.frame1 -side left -anchor w \
   -padx 3 -pady 3

#--- create the canvas for the image
#--- cree le canevas pour l'image
canvas .test.image1 \
   -bg $color(back_image)
pack .test.image1 \
   -in .test -expand 1 -side top -anchor center -fill both
set zone(image1) .test.image1

# =========================================
# === Setting the binding.
# === Met en place les liaisons.
# =========================================

#--- destroy the toplevel window with the upper right cross
#--- detruit la fenetre principale avec la croix en haut a droite
bind .test <Destroy> { destroy .test; exit }

#--- execute a command from the command line
#--- execute une commande a partir de la ligne de commande
bind $zone(command_line) <Key-Return> {
   history add "$command_line"
   set resultat [eval $command_line]
   if { [string compare $resultat ""] != 0 } {
      $zone(status_list) insert end "$resultat"
   }
   set $command_line ""
}

#--- recall the command line
#--- rappel la ligne de commande
bind $zone(command_line) <Key-Up> {
   set $command_line [history before]
   $zone(command_line) icursor end
}
bind $zone(command_line) <Key-Down> {
   set $command_line [history after]
   $zone(command_line) icursor end
}
bind $zone(command_line) <Key-Escape> {
   set $command_line [history synchro]
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
# === Setting the astronomical devices ===
# ========================================

#--- declare a new buffer in memory to place images
set num(buf1) [buf::create]

#--- declare a new camera
catch {porttalk open all}
package require Thread
set num(cam1) [cam::create audine lpt1]

#set num(cam1) [::cam::create ethernaude -ip 195.83.102.123]
cam$num(cam1) buf $num(buf1)

#--- declare a new visu space to display the buffer
set num(visu1) [visu::create $num(buf1) 1 ]

#--- create a widget image in a canvas to display that of the visu space
$zone(image1) create image 1 1 -image imagevisu1 -anchor nw -tag img1

cd ../images

# ===================================
# === It is the end of the script ===
# ===================================
proc acq_image { {e} {b} } {
   #--- variables shared
   global num
   global caption
   global zone
   global info_image

   set ee 1
   set bb 2

   if {$e=="$caption(textexposure) 0.01 s"} { set ee 0.01 }
   if {$e=="$caption(textexposure) 0.1 s"} { set ee 0.1 }
   if {$e=="$caption(textexposure) 1 s"} { set ee 1 }
   if {$e=="$caption(textexposure) 5 s"} { set ee 5 }
   if {$e=="$caption(textexposure) 10 s"} { set ee 10 }
   if {$e=="$caption(textexposure) 30 s"} { set ee 30 }

   if {$b=="$caption(textbinning) 2x2"} { set bb 2 }
   if {$b=="$caption(textbinning) 1x1"} { set bb 1 }
   if {$b=="$caption(textbinning) 4x4"} { set bb 4 }

   camacq $ee $bb
}

proc camacq { {e "1"} {b "2"} } {
   #--- variables shared
   global num
   global caption
   global zone
   global info_image

   .test.lst1 delete 0 end
   .test.lst1 insert end "Acquisition en cours ($e s, binning $b x $b)..."
   .test.lst1 see end
   $zone(but_acq) configure -relief sunken -command { }

   cam1 exptime $e
   cam1 bin [list $b $b]
   cam1 acqnormal
  # set statusVariableName "::status_cam1
  # update
  # while { [set $statusVariableName] != "stand" } {
  #    vwait status_cam1
  # }

   #--- get statistics from the acquired image
   set myStatistics [buf1 stat]
   set max_dark [lrange $myStatistics 2 2]

   #--- and display it with the right thresholds
   set lc [lrange $myStatistics 1 1]
   if {$lc < 0} { set lc 0 }
   if {$lc > 32767} { set lc 0 }
   set hc [lrange $myStatistics 0 0]
   if {$hc < 0} { set hc 32767 }
   if {$hc > 32767} { set hc 32767 }
   .test.lst1 delete 0 end
   .test.lst1 insert end "Image visualisee (seuils ${lc} ${hc})"
   .test.lst1 see end

   visu1 cut [list $hc $lc]
   set zone(naxis1) [lindex [buf1 getkwd NAXIS1] 1]
   set zone(naxis2) [lindex [buf1 getkwd NAXIS2] 1]
   visu1 clear
   visu1 disp
   $zone(but_acq) configure -relief raised -command { acq_image $exposure $binning }

}

proc load_image {} {
   #--- variables shared
   global num
   global caption
   global zone
   global info_image

   set filename [tk_getOpenFile -title "Charger une image" -filetypes {{{Images FITS} {.fit}}}]
   if {[string compare $filename ""] != 0 } {
      set result [buf1 load $filename]
      set zone(naxis1) [lindex [buf1 getkwd NAXIS1] 1]
      set zone(naxis2) [lindex [buf1 getkwd NAXIS2] 1]
      visu1 clear
      visu1 disp
   }
}

proc save_image {} {
   #--- variables shared
   global num
   global caption
   global zone
   global info_image

   set filename [tk_getSaveFile -title "Sauver une image" -filetypes {{{Images FITS} {.fit}}}]
   if {[string compare $filename ""] != 0 } {
      set result [buf1 save $filename]
   }
}

proc acqs_image { {e} {b} } {
   #--- variables shared
   global num
   global caption
   global zone
   global info_image

   set ee 1
   set bb 2

   if {$e=="$caption(textexposure) 0.01 s"} { set ee 0.01 }
   if {$e=="$caption(textexposure) 0.1 s"} { set ee 0.1 }
   if {$e=="$caption(textexposure) 1 s"} { set ee 1 }
   if {$e=="$caption(textexposure) 5 s"} { set ee 5 }
   if {$e=="$caption(textexposure) 10 s"} { set ee 10 }
   if {$e=="$caption(textexposure) 30 s"} { set ee 30 }

   if {$b=="$caption(textbinning) 2x2"} { set bb 2 }
   if {$b=="$caption(textbinning) 1x1"} { set bb 1 }
   if {$b=="$caption(textbinning) 4x4"} { set bb 4 }

   camacqs $ee $bb
}

proc camacqs { {e "1"} {b "2"} } {
   #--- variables shared
   global num
   global caption
   global zone
   global info_image

   .test.lst1 delete 0 end
   .test.lst1 insert end "Acquisition spéciale en cours ($e s, binning $b x $b)..."
   .test.lst1 see end
   $zone(but_acqs) configure -relief sunken -command { }

   if {$e<=0} {set e 1}
   if {$b<=0} {set b 1}
   cam1 exptime $e
   cam1 bin [list $b $b]
   cam1 acqspecial

   #--- get statistics from the acquired image
   set myStatistics [buf1 stat]
   set max_dark [lrange $myStatistics 2 2]

   #--- and display it with the right thresholds
   set lc [lrange $myStatistics 1 1]
   if {$lc < 0} { set lc 0 }
   if {$lc > 32767} { set lc 0 }
   set hc [lrange $myStatistics 0 0]
   if {$hc < 0} { set hc 32767 }
   if {$hc > 32767} { set hc 32767 }
   .test.lst1 delete 0 end
   .test.lst1 insert end "Image visualisee (seuils ${lc} ${hc})"
   .test.lst1 see end

   visu1 cut [list $hc $lc]
   set zone(naxis1) [lindex [buf1 getkwd NAXIS1] 1]
   set zone(naxis2) [lindex [buf1 getkwd NAXIS2] 1]
   visu1 clear
   visu1 disp
   $zone(but_acqs) configure -relief raised -command { acqs_image $exposure $binning }
}

