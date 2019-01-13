#
# Mise à jour $Id: tuto.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#!/bin/sh
# the next line restarts using wish \
#exec wish "$0" "$@"

proc int {value} {
   set a [expr ceil($value)]
   set point [expr [string first . $a]-1]
   set value [string range $a 0 $point]
}

proc caption_def { langage } {
   global texte caption
   #--- definition of captions
   if {[string compare $langage french] ==0 } {
      set caption(main_title) "Un tutoriel pour les utilisateurs de l'EthernAude"
      set caption(tuto_about) "A propos..."
      set caption(tuto_quit)  "Quitter"
      set caption(tuto_tools) "Outils"
      set texte(tuto_1)    "Tutoriel pour les utilisateurs de l'EthernAude"
      set texte(tuto_2)    "Ce tutoriel vous permettra de réaliser vos premières images avec votre caméra CCD connectée avec un boîtier EthernAude. Pour toute information complémentaire, consulter le site web http://www.astrosurf.com/ethernaude"
      set texte(tuto_0)    "Présentation générale de l'EthernAude."
      set texte(tuto_3)    "Brancher l'EthernAude avec une caméra Audine"
      set texte(tuto_4)    "Connexions entre le boîtier et la caméra."
      set texte(tuto_5)    "Présentation du câble réseau."
      set texte(tuto_6)    "Connexion directe par un câble réseau croisé."
      set texte(tuto_7)    "Connexion par un Hub ou par un Switch."
      set texte(tuto_8)    "Mise en marche électrique."
      set texte(tuto_10_0) "Tests de fonctionnement"
      set texte(tuto_10)   "Connexion logicielle entre l'ordinateur et l'EthernAude."
      set texte(tuto_11)   "Premières images."
      set texte(tuto_12)   "Pour aller plus loin."
      set texte(tuto_20_0) "Câblage pour utiliser la prise DB9"
      set texte(tuto_20)   "Câblage RS232."
      set texte(tuto_21)   "Câblage I2C."
      set texte(tuto_22)   "Brochage de la prise DB9."
      set texte(tuto_30_0) "Visite à l'intérieur du boîtier"
      set texte(tuto_30)   "Démontage du capot."
      set texte(tuto_31)   "Choisir le CCD Kaf-0401E ou Kaf-1602E."
      set texte(tuto_32)   "Reprogrammer le microcontrôleur caméra."
      set texte(tuto_33)   "Reprogrammer le microcontrôleur Ethernet."
      set texte(tuto_about0) "Tutoriel EthernAude"
      set texte(tuto_about1) "Tutoriel pour le boîtier EthernAude\n\n\Aude (c) 2002\n"
      set texte(tuto_update) "Mise à jour du"
      set texte(next_topic)  "Page suivante :"
   } else {
      set caption(main_title) "Tutorial for EthernAude Users"
      set caption(tuto_about) "About..."
      set caption(tuto_quit)  "Exit"
      set caption(tuto_tools) "Tools"
      set texte(tuto_1)    "Tutorial for EthernAude Users"
      set texte(tuto_2)    "This tutorial helps you shoot your first images with your CCD camera connected to an EthernAude device. For more information, please refer to http://www.astrosurf.com/ethernaude"
      set texte(tuto_0)    "EthernAude Overview."
      set texte(tuto_3)    "EthernAude with a Genesis/Audine camera"
      set texte(tuto_4)    "Device - Camera Connections."
      set texte(tuto_5)    "What is a Network Cable?"
      set texte(tuto_6)    "Crossover Cable Direct Connection."
      set texte(tuto_7)    "Connection through a Hub or a Switch."
      set texte(tuto_8)    "Swiching On."
      set texte(tuto_10_0) "Operation Tests"
      set texte(tuto_10)   "Computer - EthernAude Software Connection."
      set texte(tuto_11)   "First Images."
      set texte(tuto_12)   "Beyond Basics."
      set texte(tuto_20_0) "Wiring for a DB9 socket"
      set texte(tuto_20)   "RS232 Wiring."
      set texte(tuto_21)   "I2C Wiring."
      set texte(tuto_22)   "DB9 socket pins."
      set texte(tuto_30_0) "A Tour Inside the Box"
      set texte(tuto_30)   "Removing the Cover."
      set texte(tuto_31)   "Choosing the Kaf-0401E or Kaf-1602E CCD."
      set texte(tuto_32)   "Updating the Microcontroller Software for the Camera."
      set texte(tuto_33)   "Updating the Microcontroller Software for Ethernet."
      set texte(tuto_about0) "Audine Tutorial"
      set texte(tuto_about1) "Tutorial for the EthernAude device\n\n\Aude (c) 2002\n"
      set texte(tuto_update) "Updated On"
      set texte(next_topic)  "Next Topic:"
   }
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

global num texte caption

caption_def $langage

# ========================================
# === Setting the astronomical devices ===
# ========================================

#--- si la fenetre secondaire existe deja, je la detruis
if { [winfo exists .second] } {
   destroy .second
}

#--- si la fenetre principale existe deja, je la deiconifie et je sors du script
if { [winfo exists .main] } {
   wm deiconify .main
   focus .main
   return
}

#--- declare a new buffer in memory to place images
set num(bufNo) [buf::create]

#--- declare a new visu space to display the buffer
set num(visuNo) [visu::create $num(bufNo) 100 ]

#--- declare a new image
set num(imageNo) $num(visuNo)

wm withdraw .
if {[info command .main] == "" } {
   toplevel .main -class Toplevel
}
wm title .main "$texte(tuto_1) (visu$num(visuNo))"
set screenwidth [int [expr [winfo screenwidth .main]*.85]]
set screenheight [int [expr [winfo screenheight .main]*.85]]
wm geometry .main ${screenwidth}x${screenheight}+0+0
wm maxsize .main [winfo screenwidth .main] [winfo screenheight .main]
wm minsize .main ${screenwidth} ${screenheight}
wm resizable .main 1 1
wm protocol .main WM_DELETE_WINDOW tuto_exit
set widgetDemo 1

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

set font {Helvetica 12 bold}
if {[info command .main.menuBar] == "" } {
   menu .main.menuBar -tearoff 0
   .main.menuBar add cascade -menu .main.menuBar.file -label $caption(tuto_tools) -underline 0
   menu .main.menuBar.file -tearoff 0
   # On the Mac use the specia .apple menu for the about item
   if {$::tcl_platform(platform) == "macintosh"} {
      .main.menuBar add cascade -menu .menuBar.apple
      menu .main.menuBar.apple -tearoff 0
      .main.menuBar.apple add command -label $caption(tuto_about) -command "aboutBox"
   } else {
      .main.menuBar.file add command -label $caption(tuto_about) -command "aboutBox" \
         -underline 0 -accelerator "<F1>"
      .main.menuBar.file add sep
   }
   .main.menuBar.file add command -label $caption(tuto_quit) -command "tuto_exit" -underline 0 \
       -accelerator "Meta-Q"
   .main configure -menu .main.menuBar
   bind .main <F1> aboutBox
}

if {[info command .main.statusBar] == "" } {
   frame .main.statusBar
   label .main.statusBar.lab -text "   " -relief sunken -bd 1 \
       -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
   label .main.statusBar.foo -width 8 -relief sunken -bd 1 \
       -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
}
pack .main.statusBar.lab -side left -padx 2 -expand yes -fill both
pack .main.statusBar.foo -side left -padx 2
pack .main.statusBar -side bottom -fill x -pady 2

if {[info command .main.textFrame] == "" } {
   frame .main.textFrame
   scrollbar .main.s -orient vertical -command {.main.t yview} -highlightthickness 0 \
       -takefocus 1
   text .main.t -yscrollcommand {.main.s set} -wrap word -font $font
   #\
   #    -setgrid 1 -highlightthickness 0 -padx 4 -pady 2 -takefocus 0
}
pack .main.s -in .main.textFrame -side right -fill y
pack .main.t -in .main.textFrame -expand yes -fill both -padx 1
pack .main.textFrame -expand yes -fill both

# Create a bunch of tags to use in the text widget, such as those for
# section titles and demo descriptions.  Also define the bindings for
# tags.

.main.t tag configure title -font {Helvetica 14 bold}

# We put some "space" characters to the left and right of each demo description
# so that the descriptions are highlighted only when the mouse cursor
# is right over them (but not when the cursor is to their left or right)
#
.main.t tag configure demospace -lmargin1 1c -lmargin2 1c

if {[winfo depth .main] == 1} {
   .main.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -underline 1
   .main.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -underline 1
   .main.t tag configure hot -background black -foreground white
} else {
   .main.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -foreground blue -underline 1
   .main.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -foreground #303080 -underline 1
   .main.t tag configure hot -foreground red -underline 1
}
.main.t tag bind demo <ButtonRelease-1> {
   invoke [.main.t index {@%x,%y}] .main
}
set lastLine ""
.main.t tag bind demo <Enter> {
   set lastLine [.main.t index {@%x,%y linestart}]
   .main.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
   .main.t config -cursor hand2
   #showStatus [.main.t index {@%x,%y}]
}
.main.t tag bind demo <Leave> {
   .main.t tag remove hot 1.0 end
   .main.t config -cursor xterm
   .main.statusBar.lab config -text ""
}
.main.t tag bind demo <Motion> {
   set newLine [.main.t index {@%x,%y linestart}]
   if {[string compare $newLine $lastLine] != 0} {
      .main.t tag remove hot 1.0 end
      set lastLine $newLine

      set tags [.main.t tag names {@%x,%y}]
      set i [lsearch -glob $tags demo-*]
      if {$i >= 0} {
         .main.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
      }
   }
   #showStatus [.main.t index {@%x,%y}]
}

# Create the text for the text widget.

.main.t insert end "$texte(tuto_1)\n\n" title
.main.t insert end "$texte(tuto_2)\n\n"
.main.t insert end " $texte(tuto_0) \n\n" {demo demo-pres1}

.main.t insert end "$texte(tuto_3)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_4)" {demo demo-plug1}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_5)" {demo demo-rj45}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_6)" {demo demo-plug2}
.main.t insert end " \n " {demospace}
.main.t insert end "4. $texte(tuto_7)" {demo demo-plug3}
.main.t insert end " \n " {demospace}
.main.t insert end "5. $texte(tuto_8)" {demo demo-on}
.main.t insert end " \n " {demospace}

.main.t insert end \n {} "$texte(tuto_10_0)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_10)" {demo demo-ipport}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_11)" {demo demo-firstlight}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_12)" {demo demo-softs}
.main.t insert end " \n " {demospace}

.main.t insert end \n {} "$texte(tuto_20_0)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_20)" {demo demo-rs232}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_21)" {demo demo-i2c}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_22)" {demo demo-db9}
.main.t insert end " \n " {demospace}

.main.t insert end \n {} "$texte(tuto_30_0)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_30)" {demo demo-capot}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_31)" {demo demo-kaf}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_32)" {demo demo-sxkey}
.main.t insert end " \n " {demospace}
.main.t insert end "4. $texte(tuto_33)" {demo demo-sxkeyio}
.main.t insert end " \n " {demospace}

.main.t insert end " \n " {demospace}
.main.t insert end " \n " {demospace}

.main.t insert end "$texte(tuto_update) 28 janvier 2006 (A. Klotz & C. Jasinski)\n\n"

.main.t configure -state disabled
focus .main.s

# invoke --
# This procedure is called when the user clicks on a demo description.
# It is responsible for invoking the demonstration.
#
# Arguments:
# index - The index of the character that the user clicked on.

proc invoke {index base} {
   global tk_library
   global audace
   if {[info exists audace]==1} {
      set rep [ file join $audace(rep_plugin) link ethernaude tutorial ]
   } else {
      set rep "."
   }
   set tags [$base.t tag names $index]
   set i [lsearch -glob $tags demo-*]
   if {$i < 0} {
      return
   }
   set cursor [$base.t cget -cursor]
   $base.t configure -cursor watch
   update
   set demo [string range [lindex $tags $i] 5 end]

   #uplevel [list source [file join $tk_library demos $demo.tcl]]
   #--- nettoie la zone
   #.main.t insert end \n {} "tutu\n" title
   #destroy .main
   #foreach w [winfo children .main] {
   #   .main.t insert end \n {} "$w\n" title
   #   pack forget $w
   #   destroy $w
   #}
   #.main.t configure -state disabled
   if {$base == ".second" } {
      wm deiconify .main
      destroy .second
   }
   if {[string compare $demo "exit"] == 0 } {
      #uplevel [list source tuto.tcl]
      focus -force .main
   } else {
      uplevel [ list source [ file join $rep tuto.$demo.tcl ] ]
      focus -force .second
   }
   update
   if {$base == ".main" } {
      $base.t configure -cursor $cursor
      $base.t tag add visited "$index linestart +1 chars" "$index lineend -1 chars"
   }
}

# showStatus --
#
# Show the name of the demo program in the status bar. This procedure
# is called when the user moves the cursor over a demo description.
#
proc showStatus index {
   global tk_library
   set tags [.main.t tag names $index]
   set i [lsearch -glob $tags demo-*]
   set cursor [.main.t cget -cursor]
   if {$i < 0} {
      .main.statusBar.lab config -text " "
      set newcursor xterm
   } else {
      set demo [string range [lindex $tags $i] 5 end]
      .main.statusBar.lab config -text "Run the \"$demo\" sample program"
      set newcursor hand2
   }
   if [string compare $cursor $newcursor] {
      .main.t config -cursor $newcursor
   }
}

# aboutBox --
#
# Pops up a message box with an "about" message
#
proc aboutBox {} {
   global texte
   tk_messageBox -icon info -type ok -title $texte(tuto_about0) -message \
      $texte(tuto_about1)
}

proc tuto_exit { } {
   global audace num
   ::buf::delete $num(bufNo)
   ::visu::delete $num(visuNo)
   if { [ info exists num(camNo) ] == "1" } {
      ::cam::delete $num(camNo)
      unset num(camNo)
   }
   catch {
      image delete image21
      image delete image100
      unset texte
   }
   if { [ info exists audace ] == "1" } {
      if { [ winfo exists .main ] } {
         if { [ winfo exists .second ] } {
            destroy .second
         }
         destroy .main
      }
   } else {
      destroy .
      exit
   }
}

