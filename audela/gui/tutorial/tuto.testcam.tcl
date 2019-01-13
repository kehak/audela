#
# Mise à jour $Id: tuto.testcam.tcl 11001 2014-09-27 08:08:54Z robertdelmas $
#

#!/bin/sh
# the next line restarts using wish \
#exec wish "$0" "$@"

proc caption_def_firstdark { langage } {
   global texte caption
   #--- definition of captions
   if {[string compare $langage english] ==0 } {
      set caption(main_title) "Snapshot:  First Steps in the CCD World"
      set caption(description) "Push the red button to shoot a dark frame of"
      set caption(go) "START"
      set caption(wait) "Wait..."
      set caption(compute) "Compute..."
      set caption(exit) "Exit"
      set caption(thermlevel) "Thermal Level ="
      set caption(max_zero) "Connection Problem"
      set caption(satured) "Some pixels are saturated"
      set caption(maxdark) "Maximum Value ="

      set caption(set0) "Set 0"
      set caption(set255) "Set 255"
      set caption(test) "Test"
      set caption(test2) "Test2"

      set texte(testcam_1) "CCD Imagery for Beginners"
      set texte(testcam_2) "Electronic Tests for Audine"
      set texte(testcam_3) "This series of tests is used to check the Audine camera kit assembly \
without CCD chip as described in the documentation.\n
Set 0\n
This test enables you to perform the following settings:
Turn the P3 potentiometer on the lower board until you read +6.0 V on pin 7 of the CCD support.
Turn the P4 potentiometer on the lower board until you read -4.0 V on pin 8 of the CCD support.
Turn the P1 potentiometer on the lower board until you read +0.5 V on pin 22 of the CCD support.\n
Set 255\n
This test enables you to perform the following settings:\n
Turn the P2 potentiometer on the lower board until you read -8.0 V on pin 22 of the CCD support.\n
Test of the Number paramater\n
This command performs a number of image area / horizontal register transfer cycles equal to the value of\
the Number parameter.  This test is used to analyze the CCD input signals with an oscilloscope.\n
Test2 of the Number paramater\n
This command performs a number of quick reading cycles of the CCD chip.  This test is used to analyze the\
CCD input signals with an oscilloscope.\n"
      set texte(testcam_exit) " Return to the main page."
   }
   if {[string compare $langage french] ==0 } {
      set caption(set0) "Set 0"
      set caption(set255) "Set 255"
      set caption(test) "Test"
      set caption(test2) "Test2"

      set texte(testcam_1) "Initiation à l'imagerie CCD"
      set texte(testcam_2) "Tests électroniques pour le kit Audine"
      set texte(testcam_3) "Cette série de tests est proposée pour vérifier le montage du kit de la caméra Audine \
sans CCD comme décrit dans la documentation.\n
Set 0\n
Ce test permet de faire les réglages suivants :
Agir sur le potentiomètre P3 de la carte inférieure jusqu'à lire +6.0 V sur la broche 7 du support du CCD.
Agir sur le potentiomètre P4 de la carte inférieure jusqu'à lire -4.0 V sur la broche 8 du support du CCD.
Agir sur le potentiomètre P1 de la carte inférieure jusqu'à lire +0.5 V sur la broche 22 du support du CCD.\n
Set 255\n
Ce test permet de faire les réglages suivants :
Agir sur le potentiomètre P2 de la carte inférieure jusqu'à lire -8.0 V sur la broche 22 du support du CCD.\n
Test 'nombre'\n
Cette commande exécute un nombre de cycles de transfert Zone image / Registre horizontal égal à la valeur du\
paramètre nombre. Ce test est utile pour analyser les signaux d'entrée CCD avec un oscilloscope.\n
Test2 'nombre'\n
Cette commande exécute un nombre de cycles de lecture rapide du CCD. Ce test est utile pour analyser les\
signaux d'entrée CCD avec un oscilloscope.\n"
      set texte(testcam_exit) " Retour à la page principale."
   }
}

proc tuto_testcam_exit { } {
   wm deiconify .main
   destroy .second
}

# widget --
# This script demonstrates the various widgets provided by Tk,
# along with many of the features of the Tk toolkit.  This file
# only contains code to generate the main window for the
# application, which invokes individual demonstrations.  The
# code for the actual demonstrations is contained in separate
# ".tcl" files is this directory, which are sourced by this script
# as needed.
#
# SCCS: @(#) widget 1.35 97/07/19 15:42:22

#--- definition of global variables (associative arrays)
global num       # index for devices
global caption   # texts of captions
global texte     # texts of text aeras
global zone      # window name of usefull screen parts

caption_def_firstdark $langage

#--- definition of colors
set color(back)       #101040
set color(backlight)  #A0A0C0
set color(go)         #FF0000
set color(text)       #FFFF00
set color(back_image) #000000

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

#--- si la fenetre secondaire existe deja, je la deiconifie et je sors du script
if { [winfo exists .second] } {
   wm deiconify .second
   focus .second
   return
}

catch {imagevisu100 blank}

toplevel .second -class Toplevel
wm title .second $texte(tuto_1)
set screenwidth [int [expr [winfo screenwidth .second]*.85]]
set screenheight [int [expr [winfo screenheight .second]*.85]]
wm geometry .second ${screenwidth}x${screenheight}+0+0
wm maxsize .second [winfo screenwidth .second] [winfo screenheight .second]
wm minsize .second ${screenwidth} ${screenheight}
wm resizable .second 1 1
wm protocol .second WM_DELETE_WINDOW tuto_testcam_exit
set widgetDemo 1

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

set font {Helvetica 12 bold}
menu .second.menuBar -tearoff 0
.second.menuBar add cascade -menu .second.menuBar.file -label $caption(tuto_tools)  -underline 0
menu .second.menuBar.file -tearoff 0

# On the Mac use the specia .apple menu for the about item
if {$::tcl_platform(platform) == "macintosh"} {
   .second.menuBar add cascade -menu .menuBar.apple
   menu .second.menuBar.apple -tearoff 0
   .second.menuBar.apple add command -label $caption(tuto_about) -command "aboutBox"
} else {
   .second.menuBar.file add command -label $caption(tuto_about) -command "aboutBox" \
      -underline 0 -accelerator "<F1>"
   .second.menuBar.file add sep
}

.second.menuBar.file add command -label $caption(tuto_quit) -command "exit" -underline 0 \
   -accelerator "Meta-Q"
.second configure -menu .second.menuBar
bind .second <F1> aboutBox

frame .second.statusBar
label .second.statusBar.lab -text "   " -relief sunken -bd 1 \
   -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
label .second.statusBar.foo -width 8 -relief sunken -bd 1 \
   -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
pack .second.statusBar.lab -side left -padx 2 -expand yes -fill both
pack .second.statusBar.foo -side left -padx 2
pack .second.statusBar -side bottom -fill x -pady 2

# =====================================
# === Create the commander ===
# =====================================

#--- create the window .second
frame .second.second -height 400 -width 500 -bg $color(backlight)
pack .second.second -side right -pady 15 -padx 10

#--- Bouton SET0
button .second.second.button_set0 \
   -bg $color(backlight) -borderwidth 3 -text $caption(set0) \
   -fg $color(text) -relief raised \
   -activebackground $color(go) \
   -command { cam1 set0 }
pack .second.second.button_set0 \
   -in .second.second -expand 1 -side top -anchor center -pady 10

#--- Bouton SET255
button .second.second.button_set255 \
   -bg $color(backlight) -borderwidth 3 -text $caption(set255) \
   -fg $color(text) -relief raised \
   -activebackground $color(go) \
   -command { cam1 set255 }
pack .second.second.button_set255 \
   -in .second.second -expand 1 -side top -anchor center -pady 10

#--- Frame test
frame .second.second.frame_test \
   -bg $color(backlight) -borderwidth 3
pack .second.second.frame_test \
   -in .second.second -expand 1 -side top -anchor center -pady 10

#--- Bouton test
button .second.second.frame_test.button_test \
   -bg $color(backlight) -borderwidth 3 -text $caption(test) \
   -fg $color(text) -relief raised \
   -activebackground $color(go) \
   -command { cam1 test $nb }
pack .second.second.frame_test.button_test \
   -in .second.second.frame_test -expand 1 -side left -anchor center -pady 5

#--- Menu de nombre de boucles
tk_optionMenu .second.second.frame_test.optionmenu1 \
   nb "10000" " 1000" "    1"
.second.second.frame_test.optionmenu1 configure \
   -disabledforeground $color(text) -fg $color(text) \
   -activeforeground $color(text) \
   -activebackground $color(backlight) -bg $color(backlight) \
   -highlightbackground $color(backlight)
pack .second.second.frame_test.optionmenu1 -side left -in .second.second.frame_test

#--- Frame test2
frame .second.second.frame_test2 \
   -bg $color(backlight) -borderwidth 3
pack .second.second.frame_test2 \
   -in .second.second -expand 1 -side top -anchor center -pady 10

#--- Bouton test2
button .second.second.frame_test2.button_test2 \
   -bg $color(backlight) -borderwidth 3 -text $caption(test2) \
   -fg $color(text) -relief raised \
   -activebackground $color(go) \
   -command { cam1 test2 $nb2 }
pack .second.second.frame_test2.button_test2 \
   -in .second.second.frame_test2 -expand 1 -side left -anchor center -pady 5

#--- Menu de nombre de boucles
tk_optionMenu .second.second.frame_test2.optionmenu1 \
   nb2 "3" "2" "1" "10"
.second.second.frame_test2.optionmenu1 configure \
   -disabledforeground $color(text) -fg $color(text) \
   -activeforeground $color(text) \
   -activebackground $color(backlight) -bg $color(backlight) \
   -highlightbackground $color(backlight)
pack .second.second.frame_test2.optionmenu1 -side left -in .second.second.frame_test2

#

frame .second.textFrame
pack .second.textFrame -expand yes -fill both
scrollbar .second.s -orient vertical -command {.second.t yview} -highlightthickness 0 \
   -takefocus 1
pack .second.s -in .second.textFrame -side right -fill y
text .second.t -yscrollcommand {.second.s set} -wrap word -font $font
#\
#   -setgrid 1 -highlightthickness 0 -padx 4 -pady 2 -takefocus 0
pack .second.t -in .second.textFrame -expand yes -fill both -padx 1

# Create a bunch of tags to use in the text widget, such as those for
# section titles and demo descriptions.  Also define the bindings for
# tags.

.second.t tag configure title -font {Helvetica 14 bold}

# We put some "space" characters to the left and right of each demo description
# so that the descriptions are highlighted only when the mouse cursor
# is right over them (but not when the cursor is to their left or right)
#
.second.t tag configure demospace -lmargin1 1c -lmargin2 1c

if {[winfo depth .second] == 1} {
   .second.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -underline 1
   .second.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -underline 1
   .second.t tag configure hot -background black -foreground white
} else {
   .second.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -foreground blue -underline 1
   .second.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -foreground #303080 -underline 1
   .second.t tag configure hot -foreground red -underline 1
}
.second.t tag bind demo <ButtonRelease-1> {
   invoke [.second.t index {@%x,%y}] .second
}
set lastLine ""
.second.t tag bind demo <Enter> {
   set lastLine [.second.t index {@%x,%y linestart}]
   .second.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
   .second.t config -cursor hand2
   #showStatus [.second.t index {@%x,%y}]
}
.second.t tag bind demo <Leave> {
   .second.t tag remove hot 1.0 end
   .second.t config -cursor xterm
   .second.statusBar.lab config -text ""
}
.second.t tag bind demo <Motion> {
   set newLine [.second.t index {@%x,%y linestart}]
   if {[string compare $newLine $lastLine] != 0} {
      .second.t tag remove hot 1.0 end
      set lastLine $newLine

      set tags [.second.t tag names {@%x,%y}]
      set i [lsearch -glob $tags demo-*]
      if {$i >= 0} {
        .second.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
      }
   }
   #showStatus [.second.t index {@%x,%y}]
}

# Create the text for the text widget.

# ====================
# === Setting text ===
# ====================

.second.t insert end "$texte(testcam_1)\n" title
.second.t insert end "$texte(testcam_2)\n\n" title
.second.t insert end "$texte(testcam_3)\n\n"

.second.t insert end "$texte(testcam_exit)" {demo demo-exit}
.second.t insert end " \n " {demospace}
.second.t insert end " \n " {demospace}

.second.t configure -state disabled
focus .second.s
wm withdraw .main

