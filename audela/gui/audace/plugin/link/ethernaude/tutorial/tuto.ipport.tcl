#
# Mise à jour $Id: tuto.ipport.tcl 9792 2013-07-21 08:22:58Z robertdelmas $
#

#!/bin/sh
# the next line restarts using wish \
#exec wish "$0" "$@"

global ipeth

proc caption_def_plugcam { langage } {
   global texte caption ipeth
   #--- definition of captions
   set ipeth(os) $::tcl_platform(os)
   set ip [lindex [hostaddress] 0]
   set ipeth(ip) $ip
   set ipeth(ipon) yes
   if {[lindex $ipeth(ip) 0]==0} {
      set ipeth(ipon) no
   }
   set ipeth(ipnum) "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2].[lindex $ip 3]"
   set ipeth(ipnumeth) "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2]"
   set ipeth(ipnumpc) "[lindex $ip 3]"
   set ipeth(ipnumet) [expr $ipeth(ipnumpc)+40]
   if {$ipeth(ipnumet)>255} {
      set ipeth(ipnumet) [expr $ipeth(ipnumpc)-10]
   }
   set ipeth(ipnumethernaude) "$ipeth(ipnumeth).$ipeth(ipnumet)"
   set ipeth(ipnumethernaudeping) [lindex [::audace_ping $ipeth(ipnumethernaude)] 0]

if {[string compare $langage french] ==0 } {
   set caption(ethernaude)   "EthernAude"
   set caption(connect)      "Connecter"
   set caption(cam_connect)  "Caméra connectée"
   set caption(cam_connect1) "Caméra déjà connectée"
   set texte(firstdark_1) "Tutoriel pour les utilisateurs de l'EthernAude"
   set texte(firstdark_2) "Connexion logicielle entre l'ordinateur et l'EthernAude."
   set texte(firstdark_3) "\
Pour communiquer sur un réseau informatique, l'ordinateur et\
le boîtier EthernAude possèdent un numéro IP (Internet Protocol).\
La connexion de l'ordinateur sur l'EthernAude est réalisée sur\
le port numéro 192. Ce numéro est fixe et vient en complément du\
numéro IP. Avant de continuer, assurez-vous qu'un seul boîtier\
EthernAude est connecté sur votre réseau (cette restriction ne vaut\
que pour ce test de connexion)."
   if {$ipeth(ipon)=="yes"} {
      if {$ipeth(ipnumethernaudeping)==1} {
         set textip "Un appareil, qui a ce numéro, a été détecté sur le réseau. Vérifier qu'il s'agisse bien de l'EthernAude."
      } else {
         set textip "Ce numéro n'est pas encore utilisé."
      }
      set texte(firstdark_4) "\
Actuellement, votre ordinateur possède le numéro IP $ipeth(ipnum).\
Le boîtier EthernAude doit être configuré pour avoir un\
numéro IP dont les trois premiers nombres sont $ipeth(ipnumeth).\
Le dernier numéro doit être différent de $ipeth(ipnumpc) (celui\
de votre ordinateur). Par exemple, $ipeth(ipnumethernaude).\
$textip. Vérifier\
que ce numéro est différent de ceux des autres appareils\
branchés sur le réseau.\n\
\n\
Dans le panneau de droite, indiquer le numéro IP de l'EthernAude\
et appuyer sur le bouton Connecter pour établir\
la connexion avec l'ordinateur.\
Dans une première étape, le numéro IP de l'EthernAude est mis à\
jour par le programme IPSetting (système Windows seulement). La seconde étape établit la connexion\
entre l'ordinateur et le boîtier.\
Si la connexion s'est bien passée alors le message\
\"Camera connected\" doit apparaître."
   } else {
      set texte(firstdark_4) "\
Actuellement, votre ordinateur n'est pas configuré pour une utilisation\
en réseau. Consulter l'aide de votre système d'exploitation.\n\n\
"
   }
   set texte(firstdark_exit) " Retour à la page principale."
} else {
   set caption(ethernaude)   "EthernAude"
   set caption(connect)      "Connect"
   set caption(cam_connect)  "Camera connected"
   set caption(cam_connect1) "Camera already connected"
   set texte(firstdark_1) "Tutorial for EthernAude Users"
   set texte(firstdark_2) "Computer - EthernAude Software Connection"
   set texte(firstdark_3) "\
To communicate through a network, both the computer and the EthernAude\
device have IP numbers (Internet Protocol).\
Port 192 is used to connect the computer to the EthernAude device.\
That number is constant and completes the IP number.\
Before continuing, verify that only one EthernAude device is connected\
to your network (this restriction only applies to this connection test)."
   if {$ipeth(ipon)=="yes"} {
      if {$ipeth(ipnumethernaudeping)==1} {
         set textip "A device with that number has been detected in the network.  Verify that it is the EthernAude device."
      } else {
         set textip "This number is not yet used."
      }
      set texte(firstdark_4) "\
Your computer currently has the IP $ipeth(ipnum) number.\
The EthernAude device must be set to have an IP number\
with the following three first numbers $ipeth(ipnumeth).\
The last number must be different from $ipeth(ipnumpc) (=the\
number for this computer). For example, $ipeth(ipnumethernaude).\
$textip. Verify\
that this IP number is different from those of the other devices\
linked to the network.\n\
\n\
On the right panel, write the IP number of the EthernAude device\
and push the Connect button to connect to the computer.\
In a first step, the EthernAude IP number is updated using\
the IPsetting software (Windows OS only).\
The second step connects the computer\
and the EthernAude device.\
If the connection process succeeds, the message\
\"Camera connected\" should be displayed.\
"
   } else {
      set texte(firstdark_4) "\
Your computer is not currently configured to be used in a network.\
Read the Help section of the OS manual.\n\n\
"
   }
   set texte(firstdark_exit) " Return to the Main Page."
}
}

proc connect_ethernaude {} {
   global ipeth caption num
   if { [llength [cam::list] ] == 1 } {
      if { [ info exists num(camNo) ] == "1" } {
         if {[lindex [cam$num(camNo) drivername] 0]=="libethernaude"} {
            tk_messageBox -message "$caption(cam_connect1)" -icon info
            return
         }
      }
      catch { cam::delete $num(camNo) }
   }
   #--- Si une camera est connectee, j'arrete les plugins camera
   if { [ ::cam::list ] != "" } {
      ::confCam::stopPlugin
   }
   #--- Je connecte l'Audine via la liaison EthernAude
   setip "$ipeth(ipnumethernaude)"
   set eth_canspeed [ expr round((-7.11)/(39.51-7.11)*30.) ]
   set erreur [ catch { cam::create ethernaude udp -ip $ipeth(ipnumethernaude) \
      -shutterinvert "1" -canspeed $eth_canspeed -num 500 } msg ]
   if { $erreur == "1" } {
      tk_messageBox -message "$msg" -icon error
      return
   } else {
      #--- Je nettoye le buffer et la visu
      buf$num(bufNo) clear
      visu$num(visuNo) clear
      #--- Je change de variable
      set num(camNo) $msg
      #--- J'associe le buffer de la visu
      cam$num(camNo) buf $num(bufNo)
      #--- J'ecris dans la Console
      ::console::affiche_saut "\n"
      ::console::affiche_erreur "$caption(ethernaude) : $ipeth(ipnumethernaude) \n"
      ::console::affiche_erreur "[ cam$num(camNo) name ] ([ cam$num(camNo) ccd ]) \n\n"
   }
   tk_messageBox -message "$caption(cam_connect)" -icon info
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
global zone      # window name of usefull screen parts

#--- selection of langage
caption_def_plugcam $langage

#--- definition of colors
set color(back)       #101040
set color(backlight)  #A0A0C0
set color(go)         #FF0000
set color(text)       #0000AA
set color(back_image) #000000

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

toplevel .second -class Toplevel
wm title .second "$texte(tuto_1) (visu$num(visuNo))"
set screenwidth [int [expr [winfo screenwidth .second]*.85]]
set screenheight [int [expr [winfo screenheight .second]*.85]]
wm geometry .second ${screenwidth}x${screenheight}+0+0
wm maxsize .second [winfo screenwidth .second] [winfo screenheight .second]
wm minsize .second ${screenwidth} ${screenheight}
wm resizable .second 1 1
wm protocol .second WM_DELETE_WINDOW tuto_ipport_exit
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
   .second.menuBar.apple add command -label $caption(tuto_about)  -command "aboutBox"
} else {
   .second.menuBar.file add command -label $caption(tuto_about)  -command "aboutBox" \
      -underline 0 -accelerator "<F1>"
   .second.menuBar.file add sep
}

.second.menuBar.file add command -label $caption(tuto_quit) -command "tuto_exit" -underline 0 \
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

if {$ipeth(ipon)=="yes"} {

   #--- create the window .second
   frame .second.second -height 400 -width 500 -bg $color(backlight)
   pack .second.second -side right -pady 15 -padx 10

   #--- label
   label .second.second.lab1 \
      -bg $color(backlight) -borderwidth 3 -text "IP EthernAude" \
      -fg $color(text)
   pack .second.second.lab1 \
      -in .second.second -expand 1 -side top -anchor center -pady 10

   #--- entry
   entry .second.second.ent1 \
      -bg $color(backlight) -borderwidth 3 -textvariable ipeth(ipnumethernaude) \
      -fg $color(text)
   pack .second.second.ent1 \
      -in .second.second -expand 1 -side top -anchor center -pady 10 -padx 10

   #--- Bouton
   button .second.second.button_on \
      -bg $color(backlight) -borderwidth 3 -text "$caption(connect)" \
      -fg $color(text) -relief raised \
      -activebackground $color(go) \
      -command { connect_ethernaude }
   pack .second.second.button_on \
      -in .second.second -expand 1 -side top -anchor center -pady 10
}

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
.second.t insert end "$texte(firstdark_4)\n\n"

.second.t insert end " \n " {demospace}
.second.t insert end "$texte(next_topic) $texte(tuto_11)" {demo demo-firstlight}
.second.t insert end " \n " {demospace}
.second.t insert end " \n " {demospace}
.second.t insert end "$texte(firstdark_exit)" {demo demo-exit}
.second.t insert end " \n " {demospace}
.second.t insert end " \n " {demospace}

.second.t configure -state disabled
focus .second.s
wm withdraw .main

proc tuto_ipport_exit { } {
   global ipeth

   catch {unset ipeth}
   wm deiconify .main
   destroy .second
}

