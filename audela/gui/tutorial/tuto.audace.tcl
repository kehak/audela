#
# Mise à jour $Id: tuto.audace.tcl 13001 2016-01-30 23:13:57Z robertdelmas $
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

      set texte(firstdark_1) "CCD Imagery for Beginners"
      set texte(firstdark_2) "Acquisition of Images through Practice"
      set texte(firstdark_3) "You are now capable of shooting images through this basic interface.\
You can now start using the Aud'ACE interface:  it is much more powerful but also more complex. Aud'ACE will enable you to process\
your images, modify the viewing thresholds, etc.\n\n
Let's take the plunge now!\n"
      set texte(firstdark_exit) " Return to the Main Page."
   }
   if {[string compare $langage french] ==0 } {
      set caption(main_title) "Snapshot : Premiers pas dans le monde du CCD"
      set caption(description) "Appuyer sur le bouton rouge pour faire une pose de"
      set caption(go) "DEMARRER"
      set caption(wait) "En cours..."
      set caption(compute) "Analyse..."
      set caption(exit) "Quitter"
      set caption(thermlevel) "Niveau thermique ="
      set caption(max_zero) "Problème de connexion"
      set caption(satured) "Des pixels sont saturés"
      set caption(maxdark) "Valeur maximum ="

      set texte(firstdark_1) "Initiation à l'imagerie CCD"
      set texte(firstdark_2) "L'acquisition par la pratique"
      set texte(firstdark_3) "Ca y est, vous êtes maintenant capables d'obtenir des images du ciel grâce à cette petite interface.\
Vous pouvez maintenant passer à l'interface Aud'ACE qui est plus élaborée (mais aussi plus complexe). Aud'ACE vous permettra de prétraiter\
vos images, de modifier leurs seuils de visualisation, etc. \n\n
En route pour l'aventure !\n"
      set texte(firstdark_exit) " Retour à la page principale."
   }
}

proc tuto_audace_exit { } {
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
set color(go)         #FF0000
set color(text)       #FFFF00
set color(back_image) #000000

#----------------------------------------------------------------
# The code below creates the main window, consisting of a menu bar
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
wm protocol .second WM_DELETE_WINDOW tuto_audace_exit
set widgetDemo 1

#----------------------------------------------------------------
# The code below creates the main window, consisting of a menu bar
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
# === Create the snapshot commander ===
# =====================================

#--- create the window .snap
frame .second.snap -height 400 -width 500 -bg $color(back)
pack .second.snap -side right -pady 15 -padx 10

#--- create the widget to start an acquisition
button .second.snap.red_button \
   -bg $color(go) -borderwidth 3 -text $caption(go) \
   -fg $color(text) -relief raised \
   -activebackground $color(go) \
   -command { acquisition_firstdark $exposure }
pack .second.snap.red_button \
   -in .second.snap -expand 1 -side top -anchor center -pady 10
set zone(red_button) .second.snap.red_button

#--- create the widget for the upper text
label .second.snap.label1 \
   -text $caption(description) \
   -fg $color(text) -bg $color(back) \
   -font systemfixed -padx 10 -pady 4
pack .second.snap.label1 \
   -in .second.snap -anchor center -expand 1 -fill both -side top

#--- create the widget to select the integration time
tk_optionMenu .second.snap.optionmenu1 \
   exposure "1 s" "5 s" "10 s" "15 s" "30 s" "60 s"
.second.snap.optionmenu1 configure \
   -disabledforeground $color(text) -fg $color(text) \
   -activeforeground $color(text) \
   -activebackground $color(back) -bg $color(back) \
   -highlightbackground $color(back)
pack .second.snap.optionmenu1 -side top -in .second.snap

#--- create the widget for the image
canvas .second.snap.image1 \
   -bg $color(back_image) \
   -height 256 -width 384
pack .second.snap.image1 \
   -in .second.snap -expand 1 -side top -anchor center -pady 10 -padx 10
set zone(image1) .second.snap.image1

#--- create a frame for statistics
frame .second.snap.frame1 -bg $color(back)
pack .second.snap.frame1 -in .second.snap -expand 1 -fill x -side top -anchor center
label .second.snap.frame1.label1 \
   -text " " \
   -fg $color(text) -bg $color(back) \
   -font systemfixed
pack .second.snap.frame1.label1 \
   -in .second.snap.frame1 -fill both -side left -padx 10
label .second.snap.frame1.label2 \
   -text " " \
   -fg $color(text) -bg $color(back) \
   -font systemfixed
pack .second.snap.frame1.label2 \
   -in .second.snap.frame1 -fill both -side right -padx 10
frame .second.snap.frame2 -bg $color(back) -height 10
pack .second.snap.frame2 -in .second.snap -expand 1 -fill x -side top -anchor center

#--- create a widget image in a canvas to display that of the visu space
$zone(image1) create image 1 1 -image imagevisu100 -anchor nw -tag img1

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

.second.t insert end "$texte(firstdark_1)\n" title
.second.t insert end "$texte(firstdark_2)\n\n" title
.second.t insert end "$texte(firstdark_3)\n\n"

.second.t insert end "$texte(firstdark_exit)" {demo demo-exit}
.second.t insert end " \n " {demospace}
.second.t insert end " \n " {demospace}

.second.t configure -state disabled
focus .second.s
wm withdraw .main

##################################################################
# procedure to acquire an image
##################################################################
proc acquisition_firstdark {exposure} {
   #--- shared variables
   global num
   global caption
   global zone

   #--- Change the red button text
   $zone(red_button) configure -text $caption(wait) -relief groove
   grab $zone(red_button)
   update

   #--- The image from this cam will be transfered to that buffer
   cam$num(cam1) buf $num(buf1)

   #--- configure the acquisition
   set expos [lindex $exposure 0]
   cam$num(cam1) exptime $expos
   cam$num(cam1) bin {2 2}

   #--- start the acquisition
   #--- and stops the script during the exposure
   #--- (waits for the variable cam1_status to change)
   cam$num(cam1) acq
   set statusVariableName "::status_cam$num(cam1)"
   update
   while { [set $statusVariableName] != "stand" } {
      vwait status_cam$num(cam1)
   }

   #--- Change the red button text
   $zone(red_button) configure -text $caption(compute) -relief groove
   update

   #--- get statistics from the acquired image
   set myStatistics [buf$num(buf1) stat]
   set max_dark [lrange $myStatistics 2 2]

   #--- and display it with the right thresholds
   set lc [lrange $myStatistics 1 1]
   if {$lc < 0} { set lc 0 }
   if {$lc > 32767} { set lc 0 }
   set hc [lrange $myStatistics 0 0]
   if {$hc < 0} { set hc 32767 }
   if {$hc > 32767} { set hc 32767 }

   visu$num(visu1) cut [list $hc $lc]
   visu$num(visu1) disp

   #--- get statistics from the acquired image
   set myStatistics [buf$num(buf1) stat]
   set mean_therm [lrange $myStatistics 4 4]

   set th_level [expr ${mean_therm}/${expos}]
   # --- .second.snap.frame1.label1 configure -text "$caption(thermlevel) [format %5.2f $th_level] /s"
   if {$max_dark == 0} {
      .second.snap.frame1.label2 configure -text "$caption(max_zero)"
   } elseif {$max_dark >= 32767} {
      .second.snap.frame1.label2 configure -text "$caption(satured)"
   } else {
      .second.snap.frame1.label2 configure -text "$caption(maxdark) $max_dark"
   }

   #--- Change the text of the red button
   grab release $zone(red_button)
   $zone(red_button) configure -text $caption(go) -relief raised

}

