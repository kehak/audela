#
# Fichier : snvisu.tcl
# Description : Visualisation des images de la nuit et comparaison avec des images de reference
# Auteur : Alain KLOTZ
# Mise à jour $Id: snvisu.tcl 10210 2013-09-14 19:43:35Z robertdelmas $
#

#--- Conventions pour ce script :
#--- Les indices 1 se rapportent a l'image de gauche
#--- Les indices 2 se rapportent a l'image de droite

global audace snvisu snconfvisu

source [ file join $audace(rep_plugin) tool supernovae snmacros.tcl ]
source [ file join $audace(rep_plugin) tool supernovae snmacros.cap ]
source [ file join $audace(rep_plugin) tool supernovae snvisuzoom.tcl ]
source [ file join $audace(rep_plugin) tool supernovae sntkutil.tcl ]

#--- Chargement de la configuration
catch { snconfvisuLoad }
snconfvisuVerif

set snvisu(afflog) 1 ; #--- Pour un affichage des images en mode logarithme

set rep(gz) "$snconfvisu(gzip)"

set rep(1)  "$snconfvisu(rep1)"
set rep(2)  "$snconfvisu(rep2)"
set rep(3)  "$snconfvisu(rep3)"

set snconfvisu(scrollbars) [string tolower "$snconfvisu(scrollbars)"]
if {$snconfvisu(scrollbars)!="on"} {
   set snconfvisu(scrollbars) off
}

set rep(blink,last) ""

# ===================================================================
# ===================================================================
# ===================================================================

# =======================================
# === Initialisation of the variables
# === Initialisation des variables
# =======================================

#--- Definition of global variables (arrays)
#--- Definition des variables globales (arrays)
global num        #--- Index for devices
global caption    #--- Texts of captions
global zone       #--- Window name of usefull screen parts
global info_image #--- Some infos on the current image
global rep
global snvisu
global snconfvisu
global color
global conf
global audace

#--- Load the captions
#--- Chargement des captions
source [ file join $audace(rep_plugin) tool supernovae snvisu.cap ]

set snvisu(blink_go)       "0"
set snvisu(exit_blink)     "1"
set snvisu(ima_rep2_exist) "0"
set snvisu(ima_rep3_exist) "0"
set snconfvisu(num_rep2_3) "0"
set extname $conf(extension,defaut)
set aa [ file join $rep(1) *$extname ]
set rep(x1) [searchGalaxySn $aa]
set rep00 {}
set aa [ file join $rep(1) *${extname}.gz ]
catch {set rep00 [searchGalaxySn $aa]}
set rep(x1) [concat $rep(x1) $rep00]
set rep(xx1) -1
set aa [ file join $rep(2) *$extname ]
set rep(x2) [searchGalaxySn $aa]
set rep(xx2) -1

set gnaxis1 384
set gnaxis2 260

# =========================================
# === Setting the graphic interface
# === Met en place l'interface graphique
# =========================================

#--- Hide the window root
#--- Cache la fenetre racine
wm focusmodel . passive
wm withdraw .

#--- Create the toplevel window .snvisu
#--- Cree la fenetre .snvisu de niveau le plus haut

if { [winfo exists $audace(base).snvisu] } {
   wm withdraw $audace(base).snvisu
   wm deiconify $audace(base).snvisu
   focus $audace(base).snvisu.frame7.but_exit
   return
}

toplevel $audace(base).snvisu -class Toplevel
wm geometry $audace(base).snvisu 860x510+0+0
wm resizable $audace(base).snvisu 1 1
wm maxsize $audace(base).snvisu [winfo screenwidth .] [winfo screenheight .]
if {$snconfvisu(scrollbars)=="on"} {
   wm minsize $audace(base).snvisu 860 520
} else {
   wm minsize $audace(base).snvisu 860 490
}
wm title $audace(base).snvisu $caption(snvisu,main_title)

wm protocol $audace(base).snvisu WM_DELETE_WINDOW { snDelete }

#--- Create the command line
#--- Cree la ligne de commande
entry $audace(base).snvisu.command_line \
   -textvariable command_line \
   -borderwidth 1 -relief groove
pack $audace(base).snvisu.command_line \
   -in $audace(base).snvisu -fill x -side bottom \
   -padx 3 -pady 3
set zone(command_line) $audace(base).snvisu.command_line

#--- Create a console for status returned
#--- Cree la console de retour d'etats
listbox $audace(base).snvisu.lst1 \
   -height 3 \
   -borderwidth 1 -relief sunken \
   -yscrollcommand [list $audace(base).snvisu.lst1.scr1 set]
pack $audace(base).snvisu.lst1 \
   -in $audace(base).snvisu -fill x -side bottom -anchor ne \
   -padx 3 -pady 3
set zone(status_list) $audace(base).snvisu.lst1

#--- Create a vertical scrollbar for the status listbox
#--- Cree un acsenseur vertical pour la console de retour d'etats
scrollbar $audace(base).snvisu.lst1.scr1 -orient vertical \
   -takefocus 1 -borderwidth 1 \
   -command [list $audace(base).snvisu.lst1 yview]
pack $audace(base).snvisu.lst1.scr1 \
   -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne

#--- Create a frame to put widgets in it
#--- Cree un frame pour y mettre des 'widgets'
frame $audace(base).snvisu.frame0 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame0 \
   -in $audace(base).snvisu -anchor s -side bottom -expand 0 -fill x

#--- Create a frame to put buttons in it
#--- Cree un frame pour y mettre des boutons
frame $audace(base).snvisu.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame1 \
   -in $audace(base).snvisu.frame0 -anchor s -side left -expand 1 -fill x -padx 5 -pady 5

#--- Create a frame to put buttons in it
#--- Cree un frame pour y mettre des boutons
frame $audace(base).snvisu.frame7 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame7 \
   -in $audace(base).snvisu.frame1 -anchor s -side bottom -expand 1 -fill x -padx 5 -pady 5

#--- Create the button 'Image Folder'
#--- Cree le bouton 'Dossier nuit'
button $audace(base).snvisu.frame7.but_rep1 \
   -text $caption(snvisu,rep1) -borderwidth 2 \
   -command { changeDir 1 }
pack $audace(base).snvisu.frame7.but_rep1 \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Previous'
#--- Cree le bouton 'Precedente'
button $audace(base).snvisu.frame7.but_prev \
   -text $caption(snvisu,prev) -borderwidth 2 \
   -command { prevImage }
pack $audace(base).snvisu.frame7.but_prev \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Next'
#--- Cree le bouton 'Suivante'
button $audace(base).snvisu.frame7.but_next \
   -text $caption(snvisu,next) -borderwidth 2 \
   -command { nextImage }
pack $audace(base).snvisu.frame7.but_next \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Sky Background'
#--- Cree le bouton 'Fond du ciel'
button $audace(base).snvisu.frame7.but_sky_back \
   -text $caption(snvisu,background) -borderwidth 2 \
   -command { snSubSky }
pack $audace(base).snvisu.frame7.but_sky_back \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Start Blink'
#--- Cree le bouton 'GO Blink'
button $audace(base).snvisu.frame7.but_blink \
   -text $caption(snvisu,blink_go) -borderwidth 2 \
   -command {
      snBlinkImage
   }
pack $audace(base).snvisu.frame7.but_blink \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Save'
#--- Cree le bouton 'Enregistrer'
button $audace(base).snvisu.frame7.but_save \
   -text $caption(snvisu,save) -borderwidth 2 \
   -command { confirmSave }
pack $audace(base).snvisu.frame7.but_save \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Html'
#--- Cree le bouton 'Html'
button $audace(base).snvisu.frame7.but_html \
   -text $caption(snvisu,html) -borderwidth 2 \
   -command { htmImage }
pack $audace(base).snvisu.frame7.but_html \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Go to'
#--- Cree le bouton 'Aller a'
button $audace(base).snvisu.frame7.but_goto \
   -text $caption(snvisu,goto) -borderwidth 2 \
   -command { gotoImage }
pack $audace(base).snvisu.frame7.but_goto \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create the button 'Exit'
#--- Cree le bouton 'Quitter'
button $audace(base).snvisu.frame7.but_exit \
   -text $caption(snvisu,exit) -borderwidth 2 \
   -command { snDelete }
pack $audace(base).snvisu.frame7.but_exit \
   -in $audace(base).snvisu.frame7 -side left -anchor center \
   -expand true -ipadx 5 -ipady 5

#--- Create a frame to put label in it
#--- Cree un frame pour y mettre un label
frame $audace(base).snvisu.frame8 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame8 \
   -in $audace(base).snvisu.frame1 -anchor center -expand 1 -fill both

#--- Bouton de configuration
button $audace(base).snvisu.frame8.but_config \
   -text "$caption(snvisu,configuration)" -borderwidth 2 \
   -command { snSetup }
pack $audace(base).snvisu.frame8.but_config \
   -in $audace(base).snvisu.frame8 -side left -anchor center \
   -padx 10 -ipadx 5 -ipady 5

#--- Bouton de configuration
button $audace(base).snvisu.frame8.but_raccourcis \
   -text "$caption(snvisu,raccourcis)" -borderwidth 2 \
   -command { ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::supernovae::getPluginType ] ] \
      [ ::supernovae::getPluginDirectory ] [ ::supernovae::getPluginHelp ] sn_raccourcis }
pack $audace(base).snvisu.frame8.but_raccourcis \
   -in $audace(base).snvisu.frame8 -side left -anchor center \
   -padx 10 -ipadx 5 -ipady 5

#--- Bouton d'appel au logiciel de carte
#--- Je n'affiche le bouton que si le logiciel est pret
#--- et si le logiciel est deja lance
if { [ info commands "::carte::isReady" ] != "" } {
   if  { [ ::carte::isReady ] == 0 } {
      button $audace(base).snvisu.frame8.but_cdc \
         -text "$caption(snvisu,carte)" -borderwidth 2 \
         -command { displayMap }
      pack $audace(base).snvisu.frame8.but_cdc \
         -in $audace(base).snvisu.frame8 -side left -anchor center \
         -padx 10 -ipadx 5 -ipady 5
   }
}

#--- Label du nom de l'image
label $audace(base).snvisu.lab1 \
   -text "" -borderwidth 0 -relief flat
pack $audace(base).snvisu.lab1 \
   -in $audace(base).snvisu.frame8 -anchor center \
   -padx 10 -pady 4
set zone(label1) $audace(base).snvisu.lab1

#--- Create a frame to put button and radio-buttons in it
#--- Cree un frame pour y mettre un bouton et des radio-boutons
frame $audace(base).snvisu.frame4_color_invariant \
   -borderwidth 2 -cursor arrow -bg $audace(color,backColor)
pack $audace(base).snvisu.frame4_color_invariant \
   -in $audace(base).snvisu.frame0 -anchor s -side right -expand 0 -fill x -padx 5 -pady 6

#--- Create a frame to put radio-buttons in it
#--- Cree un frame pour y mettre des radio-boutons
frame $audace(base).snvisu.frame5 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame5 \
   -in $audace(base).snvisu.frame4_color_invariant -anchor s -side top -expand 0 -fill x

#--- Create a frame to put button in it
#--- Cree un frame pour y mettre le bouton
frame $audace(base).snvisu.frame6 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame6 \
   -in $audace(base).snvisu.frame4_color_invariant -anchor s -side top -expand 0 -fill x

#--- Create the radio-buttons
#--- Cree les radio-boutons
#--- Bouton radio 1 "Dossier de reference perso"
radiobutton $audace(base).snvisu.frame5.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
   -bg $audace(color,backColor) -activebackground $audace(color,activeBackColor) -text $caption(snvisu,perso) -value 0 \
   -variable snconfvisu(num_rep2_3) -command { displayImages }
pack $audace(base).snvisu.frame5.but_rad0 \
   -in $audace(base).snvisu.frame5 -side left -anchor center \
   -padx 3 -pady 3
#--- Bouton radio 2 "Dossier de reference DSS"
radiobutton $audace(base).snvisu.frame5.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
   -bg $audace(color,backColor) -activebackground $audace(color,activeBackColor) -text $caption(snvisu,dss) -value 1 \
   -variable snconfvisu(num_rep2_3) -command { displayImages }
pack $audace(base).snvisu.frame5.but_rad1 \
   -in $audace(base).snvisu.frame5 -side right -anchor center \
   -padx 3 -pady 3

#--- Create the button 'Reference Folder'
#--- Cree le bouton 'Dossier reference'
button $audace(base).snvisu.frame6.but_rep2 \
   -text $caption(snvisu,rep2) -borderwidth 2 \
   -command { if { $snconfvisu(num_rep2_3) == "0" } { changeDir 2 } elseif { $snconfvisu(num_rep2_3) == "1" } { changeDir 3 } }
pack $audace(base).snvisu.frame6.but_rep2 \
   -in $audace(base).snvisu.frame6 -side bottom -anchor n \
   -padx 5 -pady 3 -ipadx 5 -ipady 5

#--- Create a frame to put scales in it
#--- Cree un frame pour y mettre des glissieres
if {$snconfvisu(scrollbars)=="on"} {
   set gnaxis1scale [expr 14+$gnaxis1]
} else {
   set gnaxis1scale $gnaxis1
}
frame $audace(base).snvisu.frame2 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame2 \
   -in $audace(base).snvisu -anchor s -side bottom -expand 0 -fill x

    scale $audace(base).snvisu.frame2.sca1 -orient horizontal -to 32767 -from -10000 -length $gnaxis1scale \
       -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
       -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) \
       -relief raised -command changeHiCut1
    pack $audace(base).snvisu.frame2.sca1 \
       -in $audace(base).snvisu.frame2 -anchor s -side left -expand 1 -fill x -padx 10
    set zone(sh1) $audace(base).snvisu.frame2.sca1

    scale $audace(base).snvisu.frame2.sca2 -orient horizontal -to 32767 -from -10000 -length $gnaxis1scale \
       -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
       -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) \
       -relief raised -command changeHiCut2
    pack $audace(base).snvisu.frame2.sca2 \
       -in $audace(base).snvisu.frame2 -anchor e -side right -expand 1 -fill x -padx 10
    set zone(sh2) $audace(base).snvisu.frame2.sca2

#--- Create a frame to put time in it
#--- Cree un frame pour y mettre les heures
frame $audace(base).snvisu.frame3 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snvisu.frame3 \
   -in $audace(base).snvisu -anchor n -side top -expand 0 -fill x

   #--- Label de l'heure de l'image
   label $audace(base).snvisu.frame3.labh1 \
      -text "" -borderwidth 0 -relief flat
   pack $audace(base).snvisu.frame3.labh1 \
      -in $audace(base).snvisu.frame3 -side left -anchor nw \
      -padx 30 -pady 10
   set zone(labelh1) $audace(base).snvisu.frame3.labh1

   #--- Label de l'heure de l'image
   label $audace(base).snvisu.frame3.labh2 \
      -text "" -borderwidth 0 -relief flat
   pack $audace(base).snvisu.frame3.labh2 \
      -in $audace(base).snvisu.frame3 -side right -anchor ne \
      -padx 30 -pady 10
   set zone(labelh2) $audace(base).snvisu.frame3.labh2

#--- Create the canvas for the image
#--- Cree le canevas pour l'image 1
if {$snconfvisu(scrollbars)=="on"} {
   snScrolledCanvas $audace(base).snvisu.image1 right \
      -width $gnaxis1 -height $gnaxis2
   set zone(image1) $audace(base).snvisu.image1.canvas
} else {
   canvas $audace(base).snvisu.image1 \
      -width $gnaxis1 -height $gnaxis2
   set zone(image1) $audace(base).snvisu.image1
}
$zone(image1) configure -cursor fleur
pack $audace(base).snvisu.image1 \
   -in $audace(base).snvisu -expand 1 -fill both -side left -anchor e -padx 10

#--- Create the canvas for the image
#--- Cree le canevas pour l'image 2
if {$snconfvisu(scrollbars)=="on"} {
   snScrolledCanvas $audace(base).snvisu.image2 right \
      -width $gnaxis1 -height $gnaxis2
   set zone(image2) $audace(base).snvisu.image2.canvas
} else {
   canvas $audace(base).snvisu.image2 \
      -width $gnaxis1 -height $gnaxis2
   set zone(image2) $audace(base).snvisu.image2
}
$zone(image2) configure -cursor fleur
pack $audace(base).snvisu.image2 \
   -in $audace(base).snvisu -expand 1 -fill both -side right -anchor e -padx 10

#--- La fenetre est active
focus $audace(base).snvisu

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).snvisu

# =========================================
# === Setting the binding
# === Met en place les liaisons
# =========================================

#--- Execute a command from the command line
#--- Execute une commande a partir de la ligne de commande
bind $zone(command_line) <Key-Return> {
   history add "$command_line"
   set resultat [eval $command_line]
   if { [string compare $resultat ""] != 0 } {
      $zone(status_list) insert end "$resultat"
   }
   set $command_line ""
}

#--- Recall the command line
#--- Rappel la ligne de commande
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

bind $audace(base).snvisu <Key-space> {
   nextImage
}

bind $audace(base).snvisu <Key-F1> {
   nextImage
}

bind $audace(base).snvisu <Key-F2> {
   snSubSky
}

bind $audace(base).snvisu <Key-F3> {
   set snvisu(exit_blink) "1"
   if { $snvisu(blink_go) == "0" } {
      snBlinkImage
   }
}

bind $audace(base).snvisu <Key-F4> {
   confirmSave
}

bind $audace(base).snvisu <Key-F5> {
   snHeader $num(buffer1)
}

bind $audace(base).snvisu <Key-F6> {
   snHeader $num(buffer2)
}

bind $audace(base).snvisu <Key-F7> {
   noCosmic
}

if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
   bind $zone(sh1) <Motion> {
      visu$num(visu1) disp
      if { [ winfo exists $audace(base).snZoom1 ] } {
         visu$num(visuZoom1) disp
      }
   }
   bind $zone(sh2) <Motion> {
      visu$num(visu2) disp
      if { [ winfo exists $audace(base).snZoom2 ] } {
         visu$num(visuZoom2) disp
      }
   }
} else {
   bind $zone(sh1) <ButtonRelease> {
      visu$num(visu1) disp
      if { [ winfo exists $audace(base).snZoom1 ] } {
         visu$num(visuZoom1) disp
      }
   }
   bind $zone(sh2) <ButtonRelease> {
      visu$num(visu2) disp
      if { [ winfo exists $audace(base).snZoom2 ] } {
         visu$num(visuZoom2) disp
      }
   }
}

#--- Affiche le zoom de la zone pointee dans l'image 1
bind $zone(image1) <ButtonPress-1> {
   if { [ buf$num(buffer1) imageready ] == "1" } {
      if { [ lindex [ buf$num(buffer1) getkwd NAXIS1 ] 1 ] != "0" } {
         #--- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
         set xy [ snScreen2Canvas1 [ list %x %y ] ]
         #--- Transforme les coordonnees canvas (x,y) en coordonnees image (xi,yi)
         set xyi [ snCanvas2Picture1 $xy ]
         set xi [ lindex $xyi 0 ]
         set yi [ lindex $xyi 1 ]
         snZoomDisp1 $xi $yi 4
      }
   }
}

#--- Affiche le zoom de la zone pointee dans l'image 2
bind $zone(image2) <ButtonPress-1> {
   if { [ buf$num(buffer2) imageready ] == "1" } {
      if { [ lindex [ buf$num(buffer2) getkwd NAXIS1 ] 1 ] != "0" } {
         #--- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
         set xy [ snScreen2Canvas2 [ list %x %y ] ]
         #--- Transforme les coordonnees canvas (x,y) en coordonnees image (xi,yi)
         set xyi [ snCanvas2Picture2 $xy ]
         set xi [ lindex $xyi 0 ]
         set yi [ lindex $xyi 1 ]
         snZoomDisp2 $xi $yi 4
      }
   }
}

# ========================================
# === Setting the astronomical devices ===
# ========================================

#--- Declare a new buffer in memory to place images
set num(buffer1) [::buf::create]
buf$num(buffer1) extension $conf(extension,defaut)
if { $conf(fichier,compres) == "0" } {
   buf$num(buffer1) compress "none"
} else {
   buf$num(buffer1) compress "gzip"
}
if { $conf(format_fichier_image) == "0" } {
   buf$num(buffer1) bitpix ushort
} else {
   buf$num(buffer1) bitpix float
}

#--- Declare a new buffer in memory to place images
set num(buffer2) [::buf::create]
buf$num(buffer2) extension $conf(extension,defaut)
if { $conf(fichier,compres) == "0" } {
   buf$num(buffer2) compress "none"
} else {
   buf$num(buffer2) compress "gzip"
}
if { $conf(format_fichier_image) == "0" } {
   buf$num(buffer2) bitpix ushort
} else {
   buf$num(buffer2) bitpix float
}

#--- Declare a new buffer in memory to place images
set num(buffer1b) [::buf::create]
buf$num(buffer1b) extension $conf(extension,defaut)
if { $conf(fichier,compres) == "0" } {
   buf$num(buffer1b) compress "none"
} else {
   buf$num(buffer1b) compress "gzip"
}
if { $conf(format_fichier_image) == "0" } {
   buf$num(buffer1b) bitpix ushort
} else {
   buf$num(buffer1b) bitpix float
}

#--- Declare a new buffer in memory to place images
set num(buffer2b) [::buf::create]
buf$num(buffer2b) extension $conf(extension,defaut)
if { $conf(fichier,compres) == "0" } {
   buf$num(buffer2b) compress "none"
} else {
   buf$num(buffer2b) compress "gzip"
}
if { $conf(format_fichier_image) == "0" } {
   buf$num(buffer2b) bitpix ushort
} else {
   buf$num(buffer2b) bitpix float
}

#--- Image visu100 et visu200
set num(visu1) [::visu::create $num(buffer1) 100 ]
set num(visu2) [::visu::create $num(buffer2) 200 ]

visu$num(visu1) zoom $snconfvisu(zoom_normal)
visu$num(visu2) zoom $snconfvisu(zoom_normal)

#--- Create a widget image in a canvas to display that of the visu space
$zone(image1) create image 0 0 -image imagevisu100 -anchor nw -tag display
$zone(image2) create image 0 0 -image imagevisu200 -anchor nw -tag display

# ===================================
# === It is the end of the script ===
# ===================================

proc snDelete { } {
   global num
   global audace
   global conf
   global snvisu
   global snconfvisu

   #--- On ne ferme SnVisu que s'il n'y a pas de blink en cours
   if { $snvisu(blink_go) == "1" } {
      return
   }
   #---
   snconfvisuSave
   #--- Supprime les images et les visu
   if { [ info exists num(visuZoom1) ] } {
      image delete imagevisu$num(visuZoom1)
      ::visu::delete $num(visuZoom1)
      unset num(visuZoom1)
   }
   if { [ info exists num(visuZoom2) ] } {
      image delete imagevisu$num(visuZoom2)
      ::visu::delete $num(visuZoom2)
      unset num(visuZoom2)
   }
   #--- Supprime les images
   image delete imagevisu100
   image delete imagevisu200
   #--- Supprime les visu
   ::visu::delete $num(visu1)
   ::visu::delete $num(visu2)
   #--- Supprime les buffer
   ::buf::delete $num(buffer1)
   ::buf::delete $num(buffer2)
   ::buf::delete $num(buffer1b)
   ::buf::delete $num(buffer2b)
   #---
   destroy $audace(base).snvisu
   #--- Effacement des fenetres des zooms si elles existent
   if { [ winfo exists $audace(base).snZoom1 ] } {
      destroy $audace(base).snZoom1
   }
   if { [ winfo exists $audace(base).snZoom2 ] } {
      destroy $audace(base).snZoom2
   }
   #--- Effacement des fenetres gotoImage, htmImage et snSetup si elles existent
   if { [ winfo exists $audace(base).snvisu_1 ] } {
      destroy $audace(base).snvisu_1
   }
   if { [ winfo exists $audace(base).snvisu_2 ] } {
      destroy $audace(base).snvisu_2
   }
   if { [ winfo exists $audace(base).snvisu_3 ] } {
      destroy $audace(base).snvisu_3
   }
   #--- Nettoyage des eventuels fichiers crees
   set ext $conf(extension,defaut)
   catch {
      file delete [ file join $snconfvisu(rep1) filter$ext ]
      file delete [ file join $snconfvisu(rep1) filter2$ext ]
      file delete [ file join $snconfvisu(rep1) filter3$ext ]
   }
}

proc snBufLog { numbuf bufno } {
   set n1 [buf$numbuf getpixelswidth]
   if {$n1==0} {
      return [list 0 0]
   }
   if {$numbuf!=$bufno} {
      buf$numbuf copyto $bufno
   }
   set res   [buf$bufno stat]
   set fond  [lindex $res 6]
   set sigma [lindex $res 7]
   set seuil [expr $fond-3.*$sigma]
   buf$bufno log 1000 [expr -1.*$seuil]
   set res   [buf$bufno stat]
   set fond  [lindex $res 6]
   set sigma [lindex $res 7]
   set sb    [expr $fond-5.*$sigma]
   set n1    [buf$bufno getpixelswidth]
   set n2    [buf$bufno getpixelsheight]
   set d     4
   set x1    [expr $n1/2-$d]
   set x2    [expr $n1/2+$d]
   set y1    [expr $n2/2-$d]
   set y2    [expr $n2/2+$d]
   set box   [list $x1 $y1 $x2 $y2]
   set res   [buf$bufno stat $box]
   set maxi  [lindex $res 2]
   set sh    [expr 1.*$maxi]
   if {$sh<=$sb} {
      set sh [expr $sb+10.*$sigma]
   }
   buf$bufno setkwd  [list MIPS-LO [expr int($sb)] float "seuil bas" ""]
   buf$bufno setkwd  [list MIPS-HI [expr int($sh)] float "seuil haut" ""]
   buf$numbuf setkwd [list MIPS-LO [expr int($sb)] float "seuil bas" ""]
   buf$numbuf setkwd [list MIPS-HI [expr int($sh)] float "seuil haut" ""]
   return [list $sh $sb]
}

proc getSeuils { numbuf } {
   set hi [lindex [buf$numbuf getkwd MIPS-HI] 1]
   if {$hi==""} {
      set hi [lindex [buf$numbuf getkwd DATAMAX] 1]
   }
   if {$hi==""} {
      set hi 32768
   }
   set lo [lindex [buf$numbuf getkwd MIPS-LO] 1]
   if {$lo==""} {
      set lo [lindex [buf$numbuf getkwd DATAMIN] 1]
   }
   if {$lo==""} {
      set lo 32768
   }
   return [list $hi $lo]
}

proc setSeuils { numbuf } {
   set hi [lindex [buf$numbuf getkwd MIPS-HI] 1]
   if {$hi==""} {
      set hi [lindex [buf$numbuf getkwd DATAMAX] 1]
   }
   if {$hi==""} {
      set hi "nf"
   }
   set lo [lindex [buf$numbuf getkwd MIPS-LO] 1]
   if {$lo==""} {
      set lo [lindex [buf$numbuf getkwd DATAMIN] 1]
   }
   if {$lo==""} {
      set lo "nf"
   }
   if { $hi=="nf" || $lo=="nf" } {
      set hi [lindex [buf$numbuf getkwd MIPS-HI] 1]
      set lo [lindex [buf$numbuf getkwd MIPS-LO] 1]
   }
   visu$numbuf cut [list $hi $lo]
}

proc noCosmic { } {
   global audace
   global caption
   global conf
   global rep
   global zone
   global num

   #--- Applique un filtre median sur l'image de la nuit pour eliminer les cosmiques
   if { [ buf$num(buffer1) imageready ] == "1" } {
      set filename [lindex $rep(x1) $rep(xx1)]
      set name [file tail "$filename"]
      set extname $conf(extension,defaut)
      set name [string range $name 0 [expr [string last "$extname" "$name"]-1]]
      ttscript2 "IMA/SERIES \"$rep(1)\" \"$name\" . . \"$extname\" \"$rep(1)\" \"filter\" . \"$extname\" FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
      set filename [ file join $rep(1) filter$extname ]
      $audace(base).snvisu.lst1 insert end "$caption(snvisu,filter) $rep(1) $name -> $filename"
      $audace(base).snvisu.lst1 yview moveto 1.0
      #--- Disparition du sautillement des widgets inferieurs
      pack $audace(base).snvisu.lst1.scr1 \
         -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      #---
      set result [buf$num(buffer1) load $filename]
      visu$num(visu1) disp
      $zone(sh1) set [lindex [getSeuils $num(buffer1)] 0]
   }
}

proc snSubSky { } {
   global audace
   global caption
   global conf
   global rep
   global zone
   global num
   global snvisu
   global snconfvisu

   #---
   set rep(blink,last) ""

   #--- Gestion du bouton 'sky_back'
   $audace(base).snvisu.frame7.but_sky_back configure -relief groove -state disabled
   update

   catch {
      set filename [lindex $rep(x1) $rep(xx1)]
      set name [file tail $filename]
      set extname $conf(extension,defaut)
      set name [string range $name 0 [expr [string last "$extname" "$name"]-1]]
      ttscript2 "IMA/SERIES \"$rep(1)\" \"$name\"  . . \"$extname\" \"$rep(1)\" \"filter\" . \"$extname\" BACK sub "
      ttscript2 "IMA/SERIES \"$rep(1)\" \"filter\" . . \"$extname\" \"$rep(1)\" \"filter\" . \"$extname\" STAT"
      set filename [ file join $rep(1) filter$extname ]
      $audace(base).snvisu.lst1 insert end "$caption(snvisu,filter) $rep(1) $name -> $filename"
      $audace(base).snvisu.lst1 yview moveto 1.0
      #--- Disparition du sautillement des widgets inferieurs
      pack $audace(base).snvisu.lst1.scr1 \
         -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      #---
      set result [buf$num(buffer1) load $filename]
      visu$num(visu1) disp
      $zone(sh1) set [lindex [getSeuils $num(buffer1)] 0]

      if { ( $snvisu(ima_rep2_exist) == "1" ) && ( $snconfvisu(num_rep2_3) == "0" ) } {
         set filename $rep(nom2)
         set name [file tail $filename]
         set name [string range $name 0 [expr [string last "$extname" "$name"]-1]]
         set extname $conf(extension,defaut)
         ttscript2 "IMA/SERIES \"$rep(2)\" \"$name\"   . . \"$extname\" \"$rep(1)\" \"filter2\" . \"$extname\" BACK sub "
         ttscript2 "IMA/SERIES \"$rep(1)\" \"filter2\" . . \"$extname\" \"$rep(1)\" \"filter2\" . \"$extname\" STAT"
         set filename [ file join $rep(1) filter2$extname ]
         $audace(base).snvisu.lst1 insert end "$caption(snvisu,filter) $rep(2) $name -> $filename"
         $audace(base).snvisu.lst1 yview moveto 1.0
         #--- Disparition du sautillement des widgets inferieurs
         pack $audace(base).snvisu.lst1.scr1 \
            -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
         #---
         set result [buf$num(buffer2) load $filename]
         visu$num(visu2) disp
         $zone(sh2) set [lindex [getSeuils $num(buffer2)] 0]
      } elseif { ( $snvisu(ima_rep3_exist) == "1" ) && ( $snconfvisu(num_rep2_3) == "1" ) } {
         set filename $rep(nom2)
         set name [file tail $filename]
         set name [string range $name 0 [expr [string last "$extname" "$name"]-1]]
         set extname $conf(extension,defaut)
         ttscript2 "IMA/SERIES \"$rep(3)\" \"$name\"   . . \"$extname\" \"$rep(1)\" \"filter2\" . \"$extname\" BACK sub "
         ttscript2 "IMA/SERIES \"$rep(1)\" \"filter2\" . . \"$extname\" \"$rep(1)\" \"filter2\" . \"$extname\" STAT"
         set filename [ file join $rep(1) filter2$extname ]
         $audace(base).snvisu.lst1 insert end "$caption(snvisu,filter) $rep(3) $name -> $filename"
         $audace(base).snvisu.lst1 yview moveto 1.0
         #--- Disparition du sautillement des widgets inferieurs
         pack $audace(base).snvisu.lst1.scr1 \
            -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
         #---
         set result [buf$num(buffer2) load $filename]
         visu$num(visu2) disp
         $zone(sh2) set [lindex [getSeuils $num(buffer2)] 0]
      }
   }

   #--- Gestion du bouton 'sky_back'
   $audace(base).snvisu.frame7.but_sky_back configure -relief raised -state normal
   update
}

proc changeDir { numbuf } {
   global audace
   global caption
   global conf
   global rep
   global zone
   global snconfvisu
   global cwdWindow
   global num

   #--- Initialisation des variables a 2 (0 et 1 reservees a Configuration --> Repertoires)
   set cwdWindow(rep_images)      "2"
   set cwdWindow(rep_travail)     "2"
   set cwdWindow(rep_scripts)     "2"
   set cwdWindow(rep_catalogues)  "2"
   set cwdWindow(rep_userCatalog) "2"
   set cwdWindow(rep_archives)    "2"

   #--- Initialisation du titre de la fenetre de navigation des repertoires
   if { $numbuf == "1" } {
       set title $caption(snvisu,rep1)
   } elseif { $numbuf == "2" } {
       set title "$caption(snvisu,rep2) - $caption(snvisu,perso)"
   } elseif { $numbuf == "3" } {
       set title "$caption(snvisu,rep2) - $caption(snvisu,dss)"
   }
   #--- Gestion des erreurs (initialisation dans un mauvais repertoire)
   set parent "$audace(base).snvisu"
   set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep($numbuf)" $title $parent ]" } msg ]
   if { $numerror == "1" } {
      set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $parent ]"
   }
   if {[string compare $filename ""] != 0 } {
      catch {
         set rep($numbuf) "$filename"
         set extname $conf(extension,defaut)
         set aa [ file join $rep($numbuf) *$extname ]
         set rep(x$numbuf) [searchGalaxySn $aa]

         set rep00 {}
         set aa [ file join $rep($numbuf) *${extname}.gz ]
         catch {set rep00 [searchGalaxySn $aa]}
         set rep(x$numbuf) [concat $rep(x$numbuf) $rep00]

         set rep(xx$numbuf) -1
         set snconfvisu(rep$numbuf) "$rep($numbuf)"
      }
   }
}

proc nextImage { } {
   #--- Variables shared
   global rep
   global zone
   global snconfvisu

   #---
   set rep(blink,last) ""
   #---
   incr rep(xx1)
   displayImages
   if { $snconfvisu(auto_blink) == "1" } {
      snBlinkImage
   }
}

proc prevImage { } {
   #--- Variables shared
   global rep
   global zone
   global snconfvisu

   #---
   set rep(blink,last) ""
   #---
   incr rep(xx1) -1
   displayImages
   if { $snconfvisu(auto_blink) == "1" } {
      snBlinkImage
   }
}

proc displayImages { } {
   #--- Variables shared
   global audace
   global caption
   global color
   global rep
   global zone
   global num
   global snvisu
   global snconfvisu
   global conf

   #--- Initialisation
   set snvisu(ima_rep2_exist) "0"
   set snvisu(ima_rep3_exist) "0"
   set snconfvisu(binarypath) ""
   set rep(DSS)               ""
   set afflog                 "$snvisu(afflog)"

   #--- Effacement des fenetres des zooms si elles existent
   if { [ winfo exists $audace(base).snZoom1 ] } {
      destroy $audace(base).snZoom1
   }
   if { [ winfo exists $audace(base).snZoom2 ] } {
      destroy $audace(base).snZoom2
   }

   #--- Nettoyage des 2 canvas avant affichage
   catch {
      #--- Du canvas de l'image 1
      visu$num(visu1)   clear
      buf$num(buffer1)  clear
      buf$num(buffer1b) clear
      #--- Du canvas de l'image 2
      visu$num(visu2)   clear
      buf$num(buffer2)  clear
      buf$num(buffer2b) clear
   }

   #---
   if {$afflog==0} {
      visu$num(visu1) buf $num(buffer1)
      visu$num(visu2) buf $num(buffer2)
   } else {
      visu$num(visu1) buf $num(buffer1b)
      visu$num(visu2) buf $num(buffer2b)
   }

   #--- Traitement des limites
   set total [llength $rep(x1)]
   if { $rep(xx1) >= $total } {
      set rep(xx1) $total
   }
   if { $rep(xx1) < 0 } {
      set rep(xx1) -1
   }
   #---
   if { ( $rep(xx1) < $total ) && ( $rep(xx1) >= 0 ) } {
      set filename [lindex $rep(x1) $rep(xx1)]
      set a [catch {buf$num(buffer1) load $filename} result]
      if {$a==1} {
         return
      }
      #---
      set sbh      [ buf$num(buffer1) stat ]
      set sh       [ lindex $sbh 0 ]
      set sb       [ lindex $sbh 1 ]
      set scalemax [ lindex $sbh 2 ]
      set scalemin [ lindex $sbh 3 ]
      visu$num(visu1) cut [ list $sh $sb ]
      #--- Affichage en mode logarithme
      if {$afflog==1} {
         visu$num(visu1) cut [ snBufLog $num(buffer1) $num(buffer1b) ]
      }
      #---
      visu$num(visu1) disp
      if {$afflog==0} {
         set nume $num(buffer1)
      } else {
         set nume $num(buffer1b)
      }
      set scalecut [ lindex [ getSeuils $nume ] 0 ]
      set err [ catch { buf$nume stat } s ]
      if { $err == "0" } {
         set scalemax [ lindex $s 2 ]
         set scalemin [ lindex $s 3 ]
         if {($scalecut>=$scalemin)&&($scalecut<=$scalemax)} {
            set ds1 [expr $scalemax-$scalecut]
            set ds2 [expr $scalecut-$scalemin]
            if {$ds1>$ds2} {
               set scalemin [expr $scalecut-$ds1]
            } else {
               set scalemax [expr $scalecut+$ds2]
            }
         }
         $zone(sh1) configure -to $scalemax -from $scalemin
      }
      $zone(sh1) set $scalecut
      update
      #---
      $zone(labelh1) configure -text [lindex [buf$num(buffer1) getkwd DATE-OBS] 1]
      set user [lindex [buf$num(buffer1) getkwd USER] 1]
      if {$user!=""} {
         set user " (user=[string trim ${user}])"
      }
      set name [lindex [buf$num(buffer1) getkwd NAME] 1]
      if {$name!=""} {
         set name " (name=[string trim ${name}])"
      }
      set gren_ha [lindex [buf$num(buffer1) getkwd GREN_HA] 1]
      set gren_dec [lindex [buf$num(buffer1) getkwd DEC] 1]
      set gren_alt [lindex [buf$num(buffer1) getkwd GREN_ALT] 1]
      set fwhm [lindex [buf$num(buffer1) getkwd FWHM] 1]
      set complus ""
      if {($gren_ha!="")&&($gren_dec!="")&&($gren_alt!="")&&($fwhm!="")} {
         set complus " (ha=[string trim ${gren_ha}] dec=[string trim ${gren_dec}] elev=[string trim ${gren_alt}] fwhm=[string trim ${fwhm}])"
      }
      $audace(base).snvisu.lst1 insert end "$caption(snvisu,image1) -> $filename $result [snCenterRaDec $num(buffer1)] $user $name $complus"
      $audace(base).snvisu.lst1 yview moveto 1.0
      #--- Disparition du sautillement des widgets inferieurs
      pack $audace(base).snvisu.lst1.scr1 \
         -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      #---
      set name [file tail $filename]
      set snvisu(name) $name
      $zone(label1) configure -text "$name    [expr $rep(xx1)+1]/$total"
      #---
      set zone(naxis1) [lindex [buf$num(buffer1) getkwd NAXIS1] 1]
      set zone(naxis2) [lindex [buf$num(buffer1) getkwd NAXIS2] 1]
      catch { $zone(image1) configure -scrollregion [list 0 0 $zone(naxis1) $zone(naxis2)] }
      #---
      set posimoins [string last - $name]
      if {$posimoins==-1} {
         set posimoins [string last . $name]
      }
      set shortname [string range $name 0 [expr ${posimoins}-1]]
      #--- j'affiche le premier radio bouton en GROOVE si l'image existe dans rep(2)
      set filename2 [ file join $rep(2) ${shortname}[file extension $name] ]
      if { [ string last ".gz" "$filename2" ] == -1 } {
         if { [ file exists $filename2 ] == 1 || [ file exists $filename2.gz ] == 1 } {
            $audace(base).snvisu.frame5.but_rad0 configure -bg $audace(color,entryBackColor)
            set snvisu(ima_rep2_exist) "1"
         } else {
            buf$num(buffer2) clear
            $audace(base).snvisu.frame5.but_rad0 configure -bg $audace(color,backColor)
            set snvisu(ima_rep2_exist) "0"
         }
      } else {
         set filename2 [ string trimright "$filename2" ".gz" ]
         if { [ file exists $filename2 ] == 1 || [ file exists $filename2.gz ] == 1 } {
            $audace(base).snvisu.frame5.but_rad0 configure -bg $audace(color,entryBackColor)
            set snvisu(ima_rep2_exist) "1"
         } else {
            buf$num(buffer2) clear
            $audace(base).snvisu.frame5.but_rad0 configure -bg $audace(color,backColor)
            set snvisu(ima_rep2_exist) "0"
         }
      }
      #--- j'affiche le deuxieme radio bouton en GROOVE si l'image existe dans rep(3)
      set filename3 [ file join $rep(3) ${shortname}[file extension $name] ]
      set rep(DSS) $filename3
      #--- Cas des images DSS au format .cpa sur le DVD
      if { $snconfvisu(dss_dvd) == "1" } {
         set filename3 "[ string toupper [ file tail [ file rootname $filename3 ] ] ].cpa"
         if { [ string range $filename3 0 2 ] == "NGC" || [ string range $filename3 0 2 ] == "PGC" } {
            ::searchFileDVD $filename3
         }
         if { $snconfvisu(binarypath) == "" } {
            #--- Restauration de l'ancienne valeur de filename3
            set filename3 [ file join $rep(3) ${shortname}[file extension $name] ]
         }
      }
      #---
      if { [ string last ".gz" "$filename3" ] == -1 } {
         if { [ file exists $rep(DSS) ] == 1 || [ file exists $filename3 ] == 1 || [ file exists $filename3.gz ] == 1 || $snconfvisu(binarypath) != "" } {
            $audace(base).snvisu.frame5.but_rad1 configure -bg $audace(color,entryBackColor)
            set snvisu(ima_rep3_exist) "1"
         } else {
            buf$num(buffer2) clear
            $audace(base).snvisu.frame5.but_rad1 configure -bg $audace(color,backColor)
            set snvisu(ima_rep3_exist) "0"
         }
      } else {
         set filename3 [ string trimright "$filename3" ".gz" ]
         if { [ file exists $rep(DSS) ] == 1 || [ file exists $filename3 ] == 1 || [ file exists $filename3.gz ] == 1 || $snconfvisu(binarypath) != "" } {
            $audace(base).snvisu.frame5.but_rad1 configure -bg $audace(color,entryBackColor)
            set snvisu(ima_rep3_exist) "1"
         } else {
            buf$num(buffer2) clear
            $audace(base).snvisu.frame5.but_rad1 configure -bg $audace(color,backColor)
            set snvisu(ima_rep3_exist) "0"
         }
      }
      #--- je selectionne l'image a afficher
      if { $snconfvisu(num_rep2_3) == "0" } {
         set filename $filename2
      } elseif { $snconfvisu(num_rep2_3) == "1" } {
         set filename $filename3
      }
      set rep(gz2) no
      if { [ string last ".gz" "$filename" ] == -1 } {
         if {[file exists $filename]==0} {
            if {[file exists $filename.gz]==1} {
               set filename $filename.gz
               set rep(gz2) yes
            }
         }
      } else {
         if { [ file exists $filename] == 0 } {
            if { [ file exists [ file rootname $filename ] ] == 1 } {
               set filename [ file rootname $filename ]
               set rep(gz2) no
            }
         } else {
            set rep(gz2) yes
         }
      }
      if { ( ( $snconfvisu(num_rep2_3) == "0" ) && ( $snvisu(ima_rep2_exist) == "1" ) ) || \
           ( ( $snconfvisu(num_rep2_3) == "1" ) && ( $snvisu(ima_rep3_exist) == "1" ) ) } {
         if { $snconfvisu(priorite_dvd) == "1" } {
            if { $snconfvisu(binarypath) != "" } {
               catch { snLoadimaNofits $filename3 [ file dirname $snconfvisu(binarypath) ] } result
               set rep(nom2) $snconfvisu(binarypath)
               $audace(base).snvisu.lst1 insert end "$caption(snvisu,image2) -> $snconfvisu(binarypath) $result"
            } else {
               catch { buf$num(buffer2) load $filename } result
               set rep(nom2) $filename
               $audace(base).snvisu.lst1 insert end "$caption(snvisu,image2) -> $filename $result"
            }
         } else {
            if { [ file exists $rep(DSS) ] == "1" } {
               if { $snconfvisu(num_rep2_3) == "0" } {
                  catch { buf$num(buffer2) load $filename } result
                  set rep(nom2) $filename
                  $audace(base).snvisu.lst1 insert end "$caption(snvisu,image2) -> $filename $result"
               } else {
                  catch { buf$num(buffer2) load $rep(DSS) } result
                  set rep(nom2) $rep(DSS)
                  $audace(base).snvisu.lst1 insert end "$caption(snvisu,image2) -> $rep(DSS) $result"
               }
            } else {
               if { $snconfvisu(num_rep2_3) == "0" } {
                  catch { buf$num(buffer2) load $filename } result
                  set rep(nom2) $filename
                  $audace(base).snvisu.lst1 insert end "$caption(snvisu,image2) -> $filename $result"
               } else {
                  catch { snLoadimaNofits $filename3 [ file dirname $snconfvisu(binarypath) ] } result
                  set rep(nom2) $snconfvisu(binarypath)
                  $audace(base).snvisu.lst1 insert end "$caption(snvisu,image2) -> $snconfvisu(binarypath) $result"
               }
            }
         }
         $audace(base).snvisu.lst1 yview moveto 1.0
         $zone(labelh2) configure -text [lindex [buf$num(buffer2) getkwd DATE-OBS] 1]
         #--- Disparition du sautillement des widgets inferieurs
         pack $audace(base).snvisu.lst1.scr1 \
            -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      }
      #---
      catch {
         set sbh [ buf$num(buffer2) stat ]
         set sh  [ lindex $sbh 0 ]
         set sb  [ lindex $sbh 1 ]
         visu$num(visu2) cut [ list $sh $sb ]
      }
      #--- Affichage en mode logarithme
      if {$afflog==1} {
         visu$num(visu2) cut [ snBufLog $num(buffer2) $num(buffer2b) ]
      }
      if {$result==""} {
         #---
         visu$num(visu2) disp
         if {$afflog==0} {
            set nume $num(buffer2)
         } else {
            set nume $num(buffer2b)
         }
         set scalecut [ lindex [ getSeuils $nume ] 0 ]
         set err [ catch { buf$nume stat } s ]
         if { $err == "0" } {
            set scalemax [ lindex $s 2 ]
            set scalemin [ lindex $s 3 ]
            if {($scalecut>=$scalemin)&&($scalecut<=$scalemax)} {
               set ds1 [expr $scalemax-$scalecut]
               set ds2 [expr $scalecut-$scalemin]
               if {$ds1>$ds2} {
                  set scalemin [expr $scalecut-$ds1]
               } else {
                  set scalemax [expr $scalecut+$ds2]
               }
            }
            $zone(sh2) configure -to $scalemax -from $scalemin
         }
         $zone(sh2) set $scalecut
         update
         #---
         set zone(naxis1_2) [lindex [buf$num(buffer2) getkwd NAXIS1] 1]
         set zone(naxis2_2) [lindex [buf$num(buffer2) getkwd NAXIS2] 1]
         catch { $zone(image2) configure -scrollregion [list 0 0 $zone(naxis1_2) $zone(naxis2_2)] }
      } else {
         visu$num(visu2) disp
         if {$afflog==0} {
            $zone(sh2) set [lindex [getSeuils $num(buffer2)] 0]
         } else {
            $zone(sh2) set [lindex [getSeuils $num(buffer2b)] 0]
         }
         $zone(labelh2) configure -text ""
      }
   } else {
      #---
      $audace(base).snvisu.lst1 insert end "$caption(snvisu,0image)"
      $audace(base).snvisu.lst1 yview moveto 1.0
      #---
      $zone(label1) configure -text ""
      #--- Disparition du sautillement des widgets inferieurs
      pack $audace(base).snvisu.lst1.scr1 \
         -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      #---
   }
}

proc gotoImage { } {
   #--- Variables shared
   global audace
   global caption
   global num
   global zone
   global info_image

   #---
   if { [winfo exists $audace(base).snvisu_1] } {
      wm withdraw $audace(base).snvisu_1
      wm deiconify $audace(base).snvisu_1
      focus $audace(base).snvisu_1.but_cancel
      return
   }

   #--- Create the toplevel window .snvisu_1
   #--- Cree la fenetre .snvisu_1 de niveau le plus haut
   toplevel $audace(base).snvisu_1 -class Toplevel
   wm title $audace(base).snvisu_1 $caption(snvisu,secondary_title)
   set posx_snvisu_1 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 1 ]
   set posy_snvisu_1 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 2 ]
   wm geometry $audace(base).snvisu_1 +[ expr $posx_snvisu_1 + 490 ]+[ expr $posy_snvisu_1 + 160 ]
   wm resizable $audace(base).snvisu_1 0 0
   wm transient $audace(base).snvisu_1 $audace(base).snvisu
   wm protocol $audace(base).snvisu_1 WM_DELETE_WINDOW { set command_line2 "" ; destroy $audace(base).snvisu_1 }

   #--- Create the label and the command line
   #--- Cree l'etiquette et la ligne de commande
   frame $audace(base).snvisu_1.frame1 -borderwidth 0 -relief raised
      label $audace(base).snvisu_1.frame1.label \
         -text $caption(snvisu,image_numero) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_1.frame1.label \
         -fill x -side left \
         -padx 5 -pady 5
      entry $audace(base).snvisu_1.frame1.command_line \
         -textvariable command_line2 \
         -borderwidth 1 -relief groove -takefocus 1 -width 8
      pack $audace(base).snvisu_1.frame1.command_line \
         -fill x -side right \
         -padx 5 -pady 5
   pack $audace(base).snvisu_1.frame1 -side top -fill both -expand 1

   #--- Je place le focus immediatement dans la zone de saisie
   focus $audace(base).snvisu_1.frame1.command_line

   #--- Create the button 'Cancel'
   #--- Cree le bouton 'Annuler'
   button $audace(base).snvisu_1.but_cancel \
      -text $caption(snvisu,cancel) -borderwidth 2 \
      -command { set command_line2 "" ; destroy $audace(base).snvisu_1 }
   pack $audace(base).snvisu_1.but_cancel \
      -in $audace(base).snvisu_1 -side left -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- Create the button 'GO'
   #--- Cree le bouton 'GO'
   button $audace(base).snvisu_1.but_go \
      -text $caption(snvisu,go) -borderwidth 2 \
      -command {
         if { $command_line2 != "" } {
            set rep(xx1) [expr $command_line2-1]
            displayImages
            destroy $audace(base).snvisu_1
         }
      }
   pack $audace(base).snvisu_1.but_go \
      -in $audace(base).snvisu_1 -side left -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- La touche Escape est equivalente au bouton "but_cancel"
   bind $audace(base).snvisu_1 <Key-Escape>  { $audace(base).snvisu_1.but_cancel invoke }

   #--- La touche Return est equivalente au bouton "but_go"
   bind $audace(base).snvisu_1 <Key-Return>  { $audace(base).snvisu_1.but_go invoke }

   $audace(base).snvisu_1.frame1.command_line selection range 0 end

   #--- La fenetre est active
   focus $audace(base).snvisu_1

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snvisu_1
}

proc snSetup { } {
   #--- Variables shared
   global audace
   global caption
   global conf
   global snconfvisu

   #---
   if { [winfo exists $audace(base).snvisu_3] } {
      wm withdraw $audace(base).snvisu_3
      wm deiconify $audace(base).snvisu_3
      focus $audace(base).snvisu_3.but_cancel
      return
   }

   #--- Create the toplevel window .snvisu_3
   #--- Cree la fenetre .snvisu_3 de niveau le plus haut
   toplevel $audace(base).snvisu_3 -class Toplevel
   wm title $audace(base).snvisu_3 $caption(snvisu,config_title)
   set posx_snvisu_3 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 1 ]
   set posy_snvisu_3 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 2 ]
   wm geometry $audace(base).snvisu_3 +[ expr $posx_snvisu_3 + 165 ]+[ expr $posy_snvisu_3 + 100 ]
   wm resizable $audace(base).snvisu_3 0 0
   wm transient $audace(base).snvisu_3 $audace(base).snvisu
   wm protocol $audace(base).snvisu_3 WM_DELETE_WINDOW { set command_line2 "" ; destroy $audace(base).snvisu_3 }

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $audace(base).snvisu_3.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $audace(base).snvisu_3.frame1.label \
         -text $caption(snvisu,rafraich_images) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame1.label \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Bouton radio 1 - Option "motion"
      radiobutton $audace(base).snvisu_3.frame1.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(snvisu,motion) -value "motion" -variable snconfvisu(cuts_change) \
         -command {
            global audace
            global num
            global zone
            bind $zone(sh1) <Motion> {
               visu$num(visu1) disp
               if { [ winfo exists $audace(base).snZoom1 ] } {
                  visu$num(visuZoom1) disp
               }
            }
            bind $zone(sh2) <Motion> {
               visu$num(visu2) disp
               if { [ winfo exists $audace(base).snZoom2 ] } {
                  visu$num(visuZoom2) disp
               }
            }
         }
      pack $audace(base).snvisu_3.frame1.but_rad0 \
         -in $audace(base).snvisu_3.frame1 -side left -anchor center \
         -padx 5 -pady 5
      #--- Bouton radio 2 - Option "release"
      radiobutton $audace(base).snvisu_3.frame1.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(snvisu,release) -value "release" -variable snconfvisu(cuts_change) \
         -command {
            global audace
            global num
            global zone
            bind $zone(sh1) <ButtonRelease> {
               visu$num(visu1) disp
               if { [ winfo exists $audace(base).snZoom1 ] } {
                  visu$num(visuZoom1) disp
               }
            }
            bind $zone(sh2) <ButtonRelease> {
               visu$num(visu2) disp
               if { [ winfo exists $audace(base).snZoom2 ] } {
                  visu$num(visuZoom2) disp
               }
            }
         }
      pack $audace(base).snvisu_3.frame1.but_rad1 \
         -in $audace(base).snvisu_3.frame1 -side left -anchor center \
         -padx 5 -pady 5
   pack $audace(base).snvisu_3.frame1 -side top -fill both -expand 1

   #--- Create the label and the command lines
   #--- Cree l'etiquette et les lignes de commande
   frame $audace(base).snvisu_3.frame2 -borderwidth 0 -relief raised
      #--- Label
      label $audace(base).snvisu_3.frame2.label \
         -text $caption(snvisu,blink_delai) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame2.label \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Entry
      entry $audace(base).snvisu_3.frame2.command_line \
         -textvariable snconfvisu(delai_blink) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $audace(base).snvisu_3.frame2.command_line \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Label
      label $audace(base).snvisu_3.frame2.label1 \
         -text $caption(snvisu,blink_nbre) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame2.label1 \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Entry
      entry $audace(base).snvisu_3.frame2.command_line_1 \
         -textvariable snconfvisu(nb_blink) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $audace(base).snvisu_3.frame2.command_line_1 \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Label
      label $audace(base).snvisu_3.frame2.label2 \
         -text $caption(snvisu,auto_blink) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame2.label2 \
         -fill x -side left \
         -padx 5 -pady 5

      #--- Checkbutton
      checkbutton $audace(base).snvisu_3.frame2.auto -text "$caption(snvisu,auto_blink)" \
         -highlightthickness 0 -variable snconfvisu(auto_blink)
      pack $audace(base).snvisu_3.frame2.auto \
        -in $audace(base).snvisu_3.frame2 -anchor center -side left \
        -padx 5 -pady 5

   pack $audace(base).snvisu_3.frame2 -side top -fill both -expand 1

   #--- Create the label and the command lines
   #--- Cree l'etiquette et les lignes de commande
   frame $audace(base).snvisu_3.frame2b -borderwidth 0 -relief raised
      #--- Label
      label $audace(base).snvisu_3.frame2b.label \
         -text $caption(snvisu,zoom_normal) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame2b.label \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Entry
      entry $audace(base).snvisu_3.frame2b.command_line \
         -textvariable snconfvisu(zoom_normal) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $audace(base).snvisu_3.frame2b.command_line \
         -fill x -side left \
         -padx 5 -pady 5
   pack $audace(base).snvisu_3.frame2b -side top -fill both -expand 1

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $audace(base).snvisu_3.frame3 -borderwidth 0 -relief raised
      #--- Label
      label $audace(base).snvisu_3.frame3.label \
         -text $caption(snvisu,scrollbar) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame3.label \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Bouton radio 1 - Option avec scrollbar
      radiobutton $audace(base).snvisu_3.frame3.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(snvisu,scroollbar_on) -value "on" -variable snconfvisu(scrollbars) \
         -command { }
      pack $audace(base).snvisu_3.frame3.but_rad0 \
         -in $audace(base).snvisu_3.frame3 -side left -anchor center \
         -padx 5 -pady 5
      #--- Bouton radio 2 - Option sans scrollbar
      radiobutton $audace(base).snvisu_3.frame3.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(snvisu,scroollbar_off) -value "off" -variable snconfvisu(scrollbars) \
         -command { }
      pack $audace(base).snvisu_3.frame3.but_rad1 \
         -in $audace(base).snvisu_3.frame3 -side left -anchor center \
         -padx 5 -pady 5
   pack $audace(base).snvisu_3.frame3 -side top -fill both -expand 1

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $audace(base).snvisu_3.frame4 -borderwidth 0 -relief raised
      #--- Label
      label $audace(base).snvisu_3.frame4.label \
         -text $caption(snvisu,image_gzip) \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_3.frame4.label \
         -fill x -side left \
         -padx 5 -pady 5
      #--- Bouton radio 1 - Option enregistrement image non compressee
      radiobutton $audace(base).snvisu_3.frame4.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$conf(extension,defaut)" -value "no" -variable snconfvisu(gzip) \
         -command { set rep(gz) "$snconfvisu(gzip)" }
      pack $audace(base).snvisu_3.frame4.but_rad0 \
         -in $audace(base).snvisu_3.frame4 -side left -anchor center \
         -padx 5 -pady 5
      #--- Bouton radio 2 - Option enregistrement image compressee
      radiobutton $audace(base).snvisu_3.frame4.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$conf(extension,defaut).gz" -value "yes" -variable snconfvisu(gzip) \
         -command { set rep(gz) "$snconfvisu(gzip)" }
      pack $audace(base).snvisu_3.frame4.but_rad1 \
         -in $audace(base).snvisu_3.frame4 -side left -anchor center \
         -padx 5 -pady 5
   pack $audace(base).snvisu_3.frame4 -side top -fill both -expand 1

   #--- Create the checkbutton, the button et the command line
   #--- Cree le checkbutton, le bouton et la ligne de commande
   frame $audace(base).snvisu_3.frame5 -borderwidth 0 -relief raised
      #--- Checkbutton images DSS sur disque dur ou sur DVD
      checkbutton $audace(base).snvisu_3.frame5.dss_dvd -text "$caption(snvisu,dss_dvd)" \
         -highlightthickness 0 -variable snconfvisu(dss_dvd)
      pack $audace(base).snvisu_3.frame5.dss_dvd \
        -in $audace(base).snvisu_3.frame5 -anchor center -side left \
        -padx 5 -pady 5
      #--- Entry
      entry $audace(base).snvisu_3.frame5.ent \
         -textvariable snconfvisu(rep_dss_dvd) -width 6
      pack $audace(base).snvisu_3.frame5.ent \
         -in $audace(base).snvisu_3.frame5 -anchor center -side left \
         -padx 5 -pady 5
      #--- Bouton parcourir
      button $audace(base).snvisu_3.frame5.explore -text "$caption(snvisu,parcourir)" -width 1 \
         -command {
            set initialdir $snconfvisu(rep_dss_dvd)
            set title $caption(snvisu,rep_dss_dvd)
            set snconfvisu(rep_dss_dvd) [ tk_chooseDirectory -title "$title" -initialdir "$initialdir" \
               -parent "$audace(base).snvisu_3" ]
            if { $snconfvisu(rep_dss_dvd) == "" } {
               set snconfvisu(rep_dss_dvd) "$initialdir"
            }
            $audace(base).snvisu_3.frame5.ent configure -textvariable snconfvisu(rep_dss_dvd)
         }
      pack $audace(base).snvisu_3.frame5.explore \
         -in $audace(base).snvisu_3.frame5 -anchor center -side left \
         -padx 5 -pady 5 -ipady 5
   pack $audace(base).snvisu_3.frame5 -side top -fill both -expand 1

   #--- Create the checkbutton
   #--- Cree le checkbutton
   frame $audace(base).snvisu_3.frame6 -borderwidth 0 -relief raised
      #--- Checkbutton images DSS sur disque dur ou sur DVD
      checkbutton $audace(base).snvisu_3.frame6.priorite_dvd -text "$caption(snvisu,priorite_dvd)" \
         -highlightthickness 0 -variable snconfvisu(priorite_dvd)
      pack $audace(base).snvisu_3.frame6.priorite_dvd \
        -in $audace(base).snvisu_3.frame6 -anchor center -side left \
        -padx 5 -pady 5
   pack $audace(base).snvisu_3.frame6 -side top -fill both -expand 1

   #--- Create the button 'Cancel'
   #--- Cree le bouton 'Annuler'
   button $audace(base).snvisu_3.but_cancel \
      -text $caption(snvisu,cancel) -borderwidth 2 \
      -command { destroy $audace(base).snvisu_3 }
   pack $audace(base).snvisu_3.but_cancel \
      -in $audace(base).snvisu_3 -side left -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- Create the button 'GO'
   #--- Cree le bouton 'GO'
   button $audace(base).snvisu_3.but_go \
      -text $caption(snvisu,go) -borderwidth 2 \
      -command {
         ::snSetupSave
         destroy $audace(base).snvisu_3
         tk_messageBox -message "$caption(snvisu,alerte1)\n$caption(snvisu,alerte2)\n$caption(snvisu,alerte3)\n" -icon warning -title "$caption(snvisu,attention)"
      }
   pack $audace(base).snvisu_3.but_go \
      -in $audace(base).snvisu_3 -side left -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- Create the button 'Help'
   #--- Cree le bouton 'Aide'
   button $audace(base).snvisu_3.but_help \
      -text $caption(snvisu,aide) -borderwidth 2 \
      -command {
         ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::supernovae::getPluginType ] ] \
            [ ::supernovae::getPluginDirectory ] [ ::supernovae::getPluginHelp ] sn_config
      }
   pack $audace(base).snvisu_3.but_help \
      -in $audace(base).snvisu_3 -side right -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- La touche Escape est equivalente au bouton "but_cancel"
   bind $audace(base).snvisu_3 <Key-Escape> { $audace(base).snvisu_3.but_cancel invoke }

   #--- La touche Return est equivalente au bouton "but_go"
   bind $audace(base).snvisu_3 <Key-Return> { $audace(base).snvisu_3.but_go invoke }

   #--- La fenetre est active
   focus $audace(base).snvisu_3

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snvisu_3
}

proc changeHiCut1 { foo } {
   global audace num snvisu

   #--- Mise a jour des seuils de visualisation de l'image 1
   set sbh [visu$num(visu1) cut]
   visu$num(visu1) cut [list $foo [lindex $sbh 1]]
   set snvisu(seuil_g_haut) $foo
   set snvisu(seuil_g_bas)  [lindex $sbh 1]
   #--- Mise a jour des seuils de visualisation de la loupe de l'image 1
   if { [ winfo exists $audace(base).snZoom1 ] } {
      changeHiCutZoom1 $foo
   }
}
proc changeHiCut2 { foo } {
   global audace num snvisu

   #--- Mise a jour des seuils de visualisation de l'image 2
   set sbh [visu$num(visu2) cut]
   visu$num(visu2) cut [list $foo [lindex $sbh 1]]
   set snvisu(seuil_d_haut) $foo
   set snvisu(seuil_d_bas)  [lindex $sbh 1]
   #--- Mise a jour des seuils de visualisation de la loupe de l'image 2
   if { [ winfo exists $audace(base).snZoom2 ] } {
      changeHiCutZoom2 $foo
   }
}

proc confirmSave { } {
   global audace caption num

   if { [ buf$num(buffer1) imageready ] == "1" } {
      set choix [ tk_messageBox -type yesno -icon warning -title "$caption(snvisu,save1)" \
         -message "$caption(snvisu,confirm)" ]
      if { [ winfo exists $audace(base).snvisu ] } {
         if { $choix == "yes" } {
            saveImage
         }
         focus $audace(base).snvisu
      }
   }
}

proc saveImage { } {
   global audace
   global caption
   global num
   global rep
   global snconfvisu
   global zone

   #---
   set rep(blink,last) ""
   #---
   set filename [lindex $rep(x1) $rep(xx1)]
   if { $filename != "" } {
      set name [file tail $filename]
      set shortname [string range $name 0 [expr [string last - $name]-1]]
      if { $shortname != "" } {
         set filename [ file join $rep(2) ${shortname}[file extension $name] ]
      } else {
         set filename [ file join $rep(2) $name ]
      }
      #--- Destruction des eventuels fichiers existants deja
      catch { file delete $filename }
      catch { file delete $filename.gz }
      #---
      if { $rep(gz) == "yes" } {
         set result [ buf$num(buffer1) save $filename ]
         gzip $filename
         $audace(base).snvisu.lst1 insert end "$caption(snvisu,newref) -> $filename.gz"
      } else {
         set result [ buf$num(buffer1) save $filename ]
         $audace(base).snvisu.lst1 insert end "$caption(snvisu,newref) -> $filename"
      }
      $audace(base).snvisu.lst1 yview moveto 1.0
      #--- Disparition du sautillement des widgets inferieurs
      pack $audace(base).snvisu.lst1.scr1 \
         -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      #--- Mise a jour de l'affichage avec la nouvelle image de reference
      displayImages
   } else {
      #---
      $audace(base).snvisu.lst1 insert end "$caption(snvisu,0image)"
      $audace(base).snvisu.lst1 yview moveto 1.0
      #---
      $zone(label1) configure -text ""
      #--- Disparition du sautillement des widgets inferieurs
      pack $audace(base).snvisu.lst1.scr1 \
         -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
      #---
   }
}

proc saveImagesJpeg { { invew 0 } { invns 0 } } {
   #--- Sauve les deux buffers en Jpeg
   global audace conf num rep

   set filename [lindex $rep(x1) $rep(xx1)]
   set shortname [file rootname [file tail $filename]]
   set rep(gif_dss) "[string tolower $shortname].gif"

   #---
  set rep1 "$rep(1)"
   set extname $conf(extension,defaut)
   set filename [ file join $rep1 "i$extname" ]

   #--- buffer 1
   set result [buf$num(buffer1) save "$filename"]
   set date [lindex [buf$num(buffer1) getkwd DATE-OBS] 1]
   set rep(jpeg1_dateobs) $date
   set    daten [string range $date 0 3]
   append daten [string range $date 5 6]
   append daten [string range $date 8 9]
   append daten [string range $date 11 12]
   append daten [string range $date 14 15]
   set jpgname [ file join $rep(1) "${shortname}-${daten}.jpg" ]
   set rep(jpeg1) [string tolower "${shortname}-${daten}.jpg"]
   set rep(jpeg1_naxis1) [lindex [buf$num(buffer1) getkwd NAXIS1] 1]
   set rep(jpeg1_naxis2) [lindex [buf$num(buffer1) getkwd NAXIS2] 1]
   if {$invew==1} {
      ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" INVERT mirror "
   }
   if {$invns==1} {
      ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" INVERT flip "
   }
   ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" STAT \"jpegfile=$jpgname\""
   ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" DELETE"

   #--- buffer 2
   set result [buf$num(buffer2) save $filename]
   set date [lindex [buf$num(buffer2) getkwd DATE-OBS] 1]
   set rep(jpeg2_dateobs) $date
   set    daten [string range $date 0 3]
   append daten [string range $date 5 6]
   append daten [string range $date 8 9]
   append daten [string range $date 11 12]
   append daten [string range $date 14 15]
   set jpgname [ file join $rep(1) [string tolower "${shortname}-${daten}.jpg"] ]
   set rep(jpeg2) [string tolower "${shortname}-${daten}.jpg"]
   set rep(jpeg2_naxis1) [lindex [buf$num(buffer2) getkwd NAXIS1] 1]
   set rep(jpeg2_naxis2) [lindex [buf$num(buffer2) getkwd NAXIS2] 1]
   if {$invew==1} {
      ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" INVERT mirror "
   }
   if {$invns==1} {
      ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" INVERT flip "
   }
   ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" STAT \"jpegfile=$jpgname\""
   ttscript2 "IMA/SERIES \"$rep1\" \"i\" . . \"$extname\" \"$rep1\" \"i\" . \"$extname\" DELETE"

   #--- conversion FIT en JPG de l'image DSS si elle existe dans rep(3)
   set repDSS $rep(3)
   set filenameDSS [ file join $repDSS ${shortname}$extname ]
   set rep(jpg_dss) ""
   if { [file exists $filenameDSS] } {
      set rep(jpg_dss) "$shortname-DSS.jpg"
      ttscript2 "IMA/SERIES \"$repDSS\" \"$shortname\" . . \"$extname\" \"$rep1\" \"$shortname-DSS\" . \"$extname\" STAT \"jpegfile\""
      ttscript2 "IMA/SERIES \"$rep1\" \"$shortname-DSS\" . . \"$extname\" \"$rep1\" \"$shortname-DSS\" . \"$extname\" DELETE"
   }
}

proc htmImage { } {
   #--- Variables shared
   global audace
   global caption
   global num
   global zone
   global info_image
   global rep
   global htmlp

   #--- Les 2 images doivent etre presentes
   if { [ buf$num(buffer1) imageready ] == "0" } {
      return
   }
   if { [ buf$num(buffer2) imageready ] == "0" } {
      return
   }
   #---
   set filename [lindex $rep(x1) $rep(xx1)]
   set name [file tail $filename]
   set dossier [file dirname $filename]
   set name [string range $name 0 [expr [string first . $name]-1] ]
   set jdobs [mc_date2jd [lindex [buf$num(buffer1) getkwd DATE-OBS] 1] ]
   set jdobs [expr $jdobs-0.5]
   set ymdhms [mc_date2ymdhms $jdobs]
   set a [expr [lindex $ymdhms 0]-2000]
   set m [lindex $ymdhms 1]
   set d [lindex $ymdhms 2]
   set a [format "%02d" $a]
   set m [format "%02d" $m]
   set d [format "%02d" $d]

   set htmlp(filenamehtml) [ file join ${dossier} ${name}-${a}${m}${d}.html ]
   set htmlp(name) ${name}

   set htmlp(observer) "Alain Klotz"
   set htmlp(e-mail)   "alain.klotz@free.fr"
   set htmlp(posns)    40
   set htmlp(dirns)    N
   set htmlp(posew)    12
   set htmlp(direw)    W
   set htmlp(magest)   17.4
   set htmlp(invew)    0
   set htmlp(invns)    0

   #---
   if { [winfo exists $audace(base).snvisu_2] } {
      wm withdraw $audace(base).snvisu_2
      wm deiconify $audace(base).snvisu_2
      focus $audace(base).snvisu_2.fra_button.but_cancel
      return
   }

   #--- Create the toplevel window .snvisu_2
   #--- Cree la fenetre .snvisu_2 de niveau le plus haut
   toplevel $audace(base).snvisu_2 -class Toplevel
   wm title $audace(base).snvisu_2 $caption(snvisu,html_title)
   set posx_snvisu_2 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 1 ]
   set posy_snvisu_2 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 2 ]
   wm geometry $audace(base).snvisu_2 +[ expr $posx_snvisu_2 + 515 ]+[ expr $posy_snvisu_2 + 100 ]
   wm resizable $audace(base).snvisu_2 0 0
   wm transient $audace(base).snvisu_2 $audace(base).snvisu
   wm protocol $audace(base).snvisu_2 WM_DELETE_WINDOW { destroy $audace(base).snvisu_2 }

   #--- Buttons frame
   frame $audace(base).snvisu_2.fra_button \
      -borderwidth 0 -cursor arrow

      #--- Create the button 'Cancel'
      #--- Cree le bouton 'Annuler'
      button $audace(base).snvisu_2.fra_button.but_cancel \
         -text $caption(snvisu,cancel) -borderwidth 2 \
         -command { destroy $audace(base).snvisu_2 ; return }
      pack $audace(base).snvisu_2.fra_button.but_cancel \
         -in $audace(base).snvisu_2.fra_button -side left -anchor w \
         -padx 5 -pady 5 -ipadx 5 -ipady 5

      #--- Create the button 'GO'
      #--- Cree le bouton 'GO'
      button $audace(base).snvisu_2.fra_button.but_go \
         -text $caption(snvisu,go) -borderwidth 2 \
         -command { snMakeHtml }
      pack $audace(base).snvisu_2.fra_button.but_go \
         -in $audace(base).snvisu_2.fra_button -side left -anchor w \
         -padx 5 -pady 5 -ipadx 5 -ipady 5

   pack $audace(base).snvisu_2.fra_button \
      -in $audace(base).snvisu_2 -anchor s -side bottom -expand 0 -fill x

   #--- Frame de la magnitude estimee
   frame $audace(base).snvisu_2.fra_magest \
      -borderwidth 0 -cursor arrow
      #--- Label de la magnitude estimee
      label $audace(base).snvisu_2.fra_magest.lab_magest \
         -text "$caption(snvisu,magnitude)" \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_2.fra_magest.lab_magest \
         -in $audace(base).snvisu_2.fra_magest -side left \
         -padx 3
      #--- Entry de la magnitude estimee
      entry $audace(base).snvisu_2.fra_magest.entry_magest \
         -textvariable htmlp(magest) \
         -borderwidth 1 -relief groove -width 10
      pack $audace(base).snvisu_2.fra_magest.entry_magest \
         -in $audace(base).snvisu_2.fra_magest -side left \
         -padx 3
   pack $audace(base).snvisu_2.fra_magest \
      -in $audace(base).snvisu_2 -pady 3 -anchor s -side bottom -expand 0 -fill x

   #--- Checkbutton du decalage E/W
   checkbutton $audace(base).snvisu_2.chk_invew \
      -text "$caption(snvisu,invert,mirror)" -variable htmlp(invew)
   pack $audace(base).snvisu_2.chk_invew \
      -in $audace(base).snvisu_2 -side bottom \
      -padx 20 -pady 3 -anchor w
   #--- Frame du decalage E/W
   frame $audace(base).snvisu_2.fra_posew \
      -borderwidth 0 -cursor arrow
      #--- Label du decalage E/W
      label $audace(base).snvisu_2.fra_posew.lab_posew \
         -text "$caption(snvisu,offsetew)" \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_2.fra_posew.lab_posew \
         -in $audace(base).snvisu_2.fra_posew -side left \
         -padx 3 -pady 3
      #--- Entry du decalage E/W
      entry $audace(base).snvisu_2.fra_posew.entry_posew \
         -textvariable htmlp(posew) \
         -borderwidth 1 -relief groove -width 10
      pack $audace(base).snvisu_2.fra_posew.entry_posew \
         -in $audace(base).snvisu_2.fra_posew -side left \
         -padx 3 -pady 3
      #--- Menu du decalage E/W
      menubutton $audace(base).snvisu_2.fra_posew.optionmenu1 -textvariable htmlp(direw) \
         -menu $audace(base).snvisu_2.fra_posew.optionmenu1.menu -relief raised
      pack $audace(base).snvisu_2.fra_posew.optionmenu1 -in $audace(base).snvisu_2.fra_posew \
         -anchor center -pady 2 -padx 4 -ipadx 3
      set m [menu $audace(base).snvisu_2.fra_posew.optionmenu1.menu -tearoff 0 ]
      foreach pos_e_o "$caption(snvisu,east) $caption(snvisu,west)" {
        $m add radiobutton -label "$pos_e_o" \
            -indicatoron "1" \
            -value "$pos_e_o" \
            -variable htmlp(direw) \
            -command { }
      }
   pack $audace(base).snvisu_2.fra_posew \
      -in $audace(base).snvisu_2 -anchor s -side bottom -expand 0 -fill x

   #--- Checkbutton du decalage N/S
   checkbutton $audace(base).snvisu_2.chk_invns \
      -text "$caption(snvisu,invert,flip)" -variable htmlp(invns)
   pack $audace(base).snvisu_2.chk_invns \
      -in $audace(base).snvisu_2 -side bottom \
      -padx 20 -pady 3 -anchor w
   #--- Frame du decalage N/S
   frame $audace(base).snvisu_2.fra_posns \
      -borderwidth 0 -cursor arrow
      #--- Label du decalage N/S
      label $audace(base).snvisu_2.fra_posns.lab_posns \
         -text "$caption(snvisu,offsetns)" \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_2.fra_posns.lab_posns \
         -in $audace(base).snvisu_2.fra_posns -side left \
         -padx 3 -pady 3
      #--- Entry du decalage N/S
      entry $audace(base).snvisu_2.fra_posns.entry_posns \
         -textvariable htmlp(posns) \
         -borderwidth 1 -relief groove -width 10
      pack $audace(base).snvisu_2.fra_posns.entry_posns \
         -in $audace(base).snvisu_2.fra_posns -side left \
         -padx 3 -pady 3
      #--- Menu du decalage N/S
      menubutton $audace(base).snvisu_2.fra_posns.optionmenu1 -textvariable htmlp(dirns) \
         -menu $audace(base).snvisu_2.fra_posns.optionmenu1.menu -relief raised
      pack $audace(base).snvisu_2.fra_posns.optionmenu1 -in $audace(base).snvisu_2.fra_posns \
         -anchor center -pady 2 -padx 4 -ipadx 3
      set m [menu $audace(base).snvisu_2.fra_posns.optionmenu1.menu -tearoff 0 ]
      foreach pos_n_s "$caption(snvisu,north) $caption(snvisu,south)" {
        $m add radiobutton -label "$pos_n_s" \
            -indicatoron "1" \
            -value "$pos_n_s" \
            -variable htmlp(dirns) \
            -command { }
      }
   pack $audace(base).snvisu_2.fra_posns \
      -in $audace(base).snvisu_2 -anchor s -side bottom -expand 0 -fill x

   #--- Frame de l'adresse messagerie de l'observateur
   frame $audace(base).snvisu_2.fra_e-mail \
      -borderwidth 0 -cursor arrow
      #--- Label de l'adresse messagerie de l'observateur
      label $audace(base).snvisu_2.fra_e-mail.lab_posns \
         -text "$caption(snvisu,e-mail)" \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_2.fra_e-mail.lab_posns \
         -in $audace(base).snvisu_2.fra_e-mail -side left \
         -padx 3 -pady 3
      #--- Entry de l'adresse messagerie de l'observateur
      entry $audace(base).snvisu_2.fra_e-mail.entry_posns \
         -textvariable htmlp(e-mail) \
         -borderwidth 1 -relief groove -width 30
      pack $audace(base).snvisu_2.fra_e-mail.entry_posns \
         -in $audace(base).snvisu_2.fra_e-mail -side left \
         -padx 3 -pady 3
   pack $audace(base).snvisu_2.fra_e-mail \
      -in $audace(base).snvisu_2 -anchor s -side bottom -expand 0 -fill x

   #--- Frame de l'observateur
   frame $audace(base).snvisu_2.fra_observer \
      -borderwidth 0 -cursor arrow
      #--- Label de l'observateur
      label $audace(base).snvisu_2.fra_observer.lab_posns \
         -text "$caption(snvisu,observer)" \
         -borderwidth 0 -relief flat
      pack $audace(base).snvisu_2.fra_observer.lab_posns \
         -in $audace(base).snvisu_2.fra_observer -side left \
         -padx 3 -pady 3
      #--- Entry de l'observateur
      entry $audace(base).snvisu_2.fra_observer.entry_posns \
         -textvariable htmlp(observer) \
         -borderwidth 1 -relief groove -width 30
      pack $audace(base).snvisu_2.fra_observer.entry_posns \
         -in $audace(base).snvisu_2.fra_observer -side left \
         -padx 3 -pady 3
   pack $audace(base).snvisu_2.fra_observer \
      -in $audace(base).snvisu_2 -anchor s -side bottom -expand 0 -fill x

   #--- La fenetre est active
   focus $audace(base).snvisu_2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snvisu_2
}

proc snMakeHtml { } {
   global audace
   global caption
   global htmlp
   global rep

   #--- Ici on fabrique les images Jpeg
   saveImagesJpeg $htmlp(invew) $htmlp(invns)
   #--- Ici on fabrique la page html
   set texte "<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">\n"
   append texte "<html>\n"
   append texte "<head>\n"
   append texte "   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n"
   append texte "   <meta name=\"Author\" content=\"SNVisu script\">\n"
   append texte "   <title>A possible supernova</title>\n"
   append texte "</head>\n"
   append texte "<body>\n"
   append texte "<center>\n"
   append texte "<h1>\n"
   append texte "Possible Supernova in $htmlp(name) </h1></center>\n"
   #--- You should adapt text from this section...
   append texte "<center><b>by <a href=\"mailto:$htmlp(e-mail)\">$htmlp(observer)</a></b></center>\n"
   append texte "<h2>\n"
   append texte "1. Instrumental design</h2>\n"
   append texte "I observed about 300 galaxies by clear night since 1 feb 2000 with a fully "
   append texte "automatized LX200 telescope (8\" diameter). The CCD is an Audine equiped "
   append texte "by an Kaf-401E chip (grade 0 quality). The camera has no shutter. An \"unsmearing\" "
   append texte "algorithm is used after the dark correction. The flat correction is not "
   append texte "performed. Each image is integrated 60 seconds with a binning 2x2 (sampling "
   append texte "is 4.4 arcsec/pixel). About 300 to 400 fields are recorded each night. "
   append texte "A quick visu software, named SNVisu, was created with the AudeLA platform. "
   append texte "It allows to see the night image (at left) and the reference image (at "
   append texte "right) on the same screen.\n"
   append texte "<h2>\n"
   append texte "2. Images</h2>\n"
   append texte "The screen copy below indicate the DATE-OBS of the images (UT). North is "
   append texte "up and East is left (no inversion).\n"
   #--- ... until this section
   append texte "<table COLS=2 WIDTH=\"100%\" ><tr><td>"
   append texte "<center><img SRC=\"$rep(jpeg1)\" height=$rep(jpeg1_naxis2) width=$rep(jpeg1_naxis1)></center>"
   append texte "</td><td>"
   append texte "<center><img SRC=\"$rep(jpeg2)\" height=$rep(jpeg2_naxis2) width=$rep(jpeg2_naxis1)></center>"
   append texte "</td></tr><tr><td>"
   append texte "<center>Candidate : $rep(jpeg1_dateobs)</center>"
   append texte "</td><td>"
   append texte "<center>Reference : $rep(jpeg2_dateobs)</center>"
   append texte "</td></tr></table>"
   append texte "<br>The possible supernova is located at about $htmlp(posns)\" $htmlp(dirns), $htmlp(posew)\" $htmlp(direw) from the nucleus of "
   append texte "the galaxy. The magnitude is estimated to $htmlp(magest). Bellow, the DSS image :\n"
   if { "$rep(jpg_dss)" != "" } {
      append texte "<BR><center><img SRC=\"$rep(jpg_dss)\" height=300 width=300></center>"
   } else {
      append texte "<BR><center><img SRC=\"$rep(gif_dss)\" height=300 width=300></center>"
   }
   append texte "</body>\n"
   append texte "</html>\n"
   #--- Enregistre la page html
   set fileId [open $htmlp(filenamehtml) w]
   puts $fileId $texte
   close $fileId
   $audace(base).snvisu.lst1 insert end "$caption(snvisu,page_html) $htmlp(filenamehtml)"
   $audace(base).snvisu.lst1 yview moveto 1.0
   #--- Disparition du sautillement des widgets inferieurs
   pack $audace(base).snvisu.lst1.scr1 \
    -in $audace(base).snvisu.lst1 -fill y -side right -anchor ne
   #---
   destroy $audace(base).snvisu_2
   return
}

proc snHeader { bufnum } {
   global audace caption color num snvisu

   set i 0
   if [winfo exists $audace(base).snheader] {
      destroy $audace(base).snheader
   }

   if { [ buf$bufnum imageready ] == "1" } {
      if { $bufnum == "$num(buffer1)" } {
         set title "$caption(snvisu,fits_header) : $snvisu(name)     [ lindex [ buf$num(buffer1) getkwd DATE-OBS ] 1 ]"
      } elseif { $bufnum == "$num(buffer2)" } {
         set title "$caption(snvisu,fits_header) - $caption(snvisu,reference) : \
            $snvisu(name)      [ lindex [ buf$num(buffer2) getkwd DATE-OBS ] 1 ]"
      }
   } else {
      if { $bufnum == "$num(buffer1)" } {
         set title "$caption(snvisu,fits_header)"
      } elseif { $bufnum == "$num(buffer2)" } {
         set title "$caption(snvisu,fits_header) - $caption(snvisu,reference)"
      }
   }

   toplevel $audace(base).snheader
   wm transient $audace(base).snheader $audace(base).snvisu
   if { [ buf$bufnum imageready ] == "1" } {
      wm minsize $audace(base).snheader 632 303
   }
   wm resizable $audace(base).snheader 1 1
   wm title $audace(base).snheader "$title"
   wm geometry $audace(base).snheader 632x303+3+75

   Scrolled_Text $audace(base).snheader.slb -width 150 -height 20
   pack $audace(base).snheader.slb -fill y -expand true

   if { [ buf$bufnum imageready ] == "1" } {
      $audace(base).snheader.slb.list tag configure keyw -foreground $color(blue)
      $audace(base).snheader.slb.list tag configure egal -foreground $color(black)
      $audace(base).snheader.slb.list tag configure valu -foreground $color(red)
      $audace(base).snheader.slb.list tag configure comm -foreground $color(green1)
      $audace(base).snheader.slb.list tag configure unit -foreground $color(orange)
      foreach kwd [ lsort -dictionary [ buf$bufnum getkwds ] ] {
         set liste [ buf$bufnum getkwd $kwd ]
         #--- je fais une boucle pour traiter les mots cles a valeur multiple
         foreach { name value type comment unit } $liste {
            $audace(base).snheader.slb.list insert end "[format "%8s" $name] " keyw
            $audace(base).snheader.slb.list insert end "= "                    egal
            $audace(base).snheader.slb.list insert end "$value "               valu
            $audace(base).snheader.slb.list insert end "$comment "             comm
            $audace(base).snheader.slb.list insert end "$unit\n"               unit
         }
      }
   } else {
      $audace(base).snheader.slb.list insert end "$caption(snvisu,header,noimage)"
   }

   #--- La nouvelle fenetre est active
   focus $audace(base).snheader

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snheader
}

proc snBlinkImage { } {
   global audace
   global caption
   global conf
   global num
   global snconfvisu
   global snvisu
   global zone
   global rep

   #--- Execute le blink uniquement s'il y a une image dans le canvas 1
   if { [ buf$num(buffer2) imageready ] == "0" } {
      return
   }

   #--- Animation en cours
   set snvisu(blink_go) "1"

   #--- Initialisation
   set rep(blink,last) ""
   set afflog          "$snvisu(afflog)"

   #---
   if {$afflog==0} {
      visu$num(visu1) buf $num(buffer1)
      visu$num(visu2) buf $num(buffer2)
   } else {
      visu$num(visu1) buf $num(buffer1b)
      visu$num(visu2) buf $num(buffer2b)
   }

   #--- Recentrage de l'image de reference
   set b [::buf::create]
   set ext $conf(extension,defaut)
   buf$b extension "$ext"
   set compress [buf$audace(bufNo) compress]
   buf$b compress "$compress"
   set bitpix [buf$audace(bufNo) bitpix]
   buf$b bitpix "$bitpix"
   set filename [lindex $rep(x1) $rep(xx1)]
   if {$rep(blink,last)!=$filename} {
      set rep(blink,last) "$filename"
      buf$num(buffer2) copyto $b
      set dimx [lindex [buf$num(buffer1) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$num(buffer1) getkwd NAXIS2 ] 1]
      buf$b window [list 1 1 $dimx $dimy]
      buf$b            save [ file join $audace(rep_images) dummy2 ]
      buf$num(buffer1) save [ file join $audace(rep_images) dummy1 ]
      set objefile "__dummy__"
      set error [ catch {
         set wcs1 [snVerifWCS $num(buffer1)]
         set wcs2 [snVerifWCS $b]
         if {($wcs1==0)||($wcs2==0)} {
            ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"dummy\" 1 2 \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" STAT objefile"
            ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"$objefile\" 1 2 \"$ext\" \"$audace(rep_images)\" \"dummyb\" 1 \"$ext\" REGISTER translate=never"
            ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"$objefile\" 1 2 \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" DELETE"
         } else {
            ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"dummy\" 1 2 \"$ext\" \"$audace(rep_images)\" \"dummyb\" 1 \"$ext\" REGISTER matchwcs"
         }
      } msg ]
      #--- Interception de l'erreur
      if { $error == "1" } {
         tk_messageBox -title "$caption(snvisu,attention)" -type ok -message "$msg \n"
         #--- Detruit les fichiers intermediaires
         file delete [ file join $snconfvisu(rep1) dummy1$ext ]
         file delete [ file join $snconfvisu(rep1) dummy2$ext ]
         file delete [ file join $snconfvisu(rep1) dummyb2$ext ]
         catch { file delete [ file join $snconfvisu(rep1) __dummy__1$ext ] }
         file delete [ file join [pwd] com.lst ]
         file delete [ file join [pwd] dif.lst ]
         file delete [ file join [pwd] eq.lst ]
         file delete [ file join [pwd] in.lst ]
         file delete [ file join [pwd] ref.lst ]
         file delete [ file join [pwd] xy.lst ]
         #---
         return
      }
      buf$b load [ file join $audace(rep_images) dummyb2 ]
      #--- Affichage en mode logarithme
      if {$afflog==1} {
         set shsb [snBufLog $b $b]
      } else {
         set shsb [visu$num(visu2) cut]
      }
      #---
      set text0 "[buf$b getkwd MIPS-LO]"
      set text0 [lreplace $text0 1 1 [lindex $shsb 1]]
      buf$b setkwd $text0
      set text0 "[buf$b getkwd MIPS-HI]"
      set text0 [lreplace $text0 1 1 [lindex $shsb 0]]
      buf$b setkwd $text0
      buf$b save [ file join $audace(rep_images) dummyb2 ]
      ttscript2 "IMA/SERIES \"$audace(rep_images)\" \"dummyb\" 1 1 \"$ext\" \"$audace(rep_images)\" \"$objefile\" 1 \"$ext\" DELETE"
   } else {
      catch { buf$b load [ file join $audace(rep_images) dummyb2 ] }
   }

   #--- Gestion du bouton 'blink'
   $audace(base).snvisu.frame7.but_blink configure -text $caption(snvisu,blink_stop) -command { set snvisu(exit_blink) "0" }
   update

   #--- Creation de la Tk_photoimage pour le blink
   catch { image delete imagevisu101 }
   ::visu::create $b 101 101
   image create photo imagevisu101
   visu101 zoom $snconfvisu(zoom_normal)
   visu101 disp [ list $snvisu(seuil_d_haut) $snvisu(seuil_d_bas) ]

   #--- Animation
   for { set t 1 } { $t <= $snconfvisu(nb_blink) } { incr t } {
      catch {
         $zone(image1) itemconfigure display -image imagevisu100
         update
         after $snconfvisu(delai_blink)
         $zone(image1) itemconfigure display -image imagevisu101
         update
         after $snconfvisu(delai_blink)
      }
      if { $snvisu(exit_blink) == "0" } {
         break
      }
   }

   #--- Detruit les visu et les Tk_photoimage
   ::visu::delete 101
   catch { image delete imagevisu101 }
   ::buf::delete $b

   #--- Detruit les fichiers intermediaires
   file delete [ file join $snconfvisu(rep1) dummy1$ext ]
   file delete [ file join $snconfvisu(rep1) dummy2$ext ]
   file delete [ file join $snconfvisu(rep1) dummyb2$ext ]
   catch { file delete [ file join $snconfvisu(rep1) __dummy__1$ext ] }
   file delete [ file join [pwd] com.lst ]
   file delete [ file join [pwd] dif.lst ]
   file delete [ file join [pwd] eq.lst ]
   file delete [ file join [pwd] in.lst ]
   file delete [ file join [pwd] ref.lst ]
   file delete [ file join [pwd] xy.lst ]

   #--- Reconfigure pour Aud'ACE normal
   catch {$zone(image1) itemconfigure display -image imagevisu100}
   update

   #--- Gestion du bouton 'blink'
   $audace(base).snvisu.frame7.but_blink configure -text $caption(snvisu,blink_go) -command { set snvisu(exit_blink) "1" ; snBlinkImage }
   update

   #--- Animation terminee
   set snvisu(blink_go) "0"

}

#===============================================
#  displayMap
#  affiche la carte avec l'objet
#
#  Recupere les coordoonnees J2000.0 de l'objet dans le fichier fit ou sn.log
#  et envoie la commande a carteduciel "moveTo  rah ram ras decd decm decs "
#  Si les coordonnees ne sont pas trouvees, utilise le nom du fichier comme
#  nom d'objet et envoie la commande "find objectname"
#
#  Petite erreur negligeable : Comme je n'ai pas les coordonnees J2000.0,
#  j'envoie les coordonnes du jour
#===============================================
proc displayMap { } {
   global rep
   global num

   set found 0
   set shortname ""
   set ra ""
   set dec ""

   if { $found ==  0 }  {
      #--- Premiere tentatvive : je recupere les coordonnees dans le fichier FIT
      set ra  [lindex [buf$num(buffer1) getkwd RA] 1]
      set dec [lindex [buf$num(buffer1) getkwd DEC] 1]

      #--- si l'image du premier buffer n'a pas les mots cles, je chercher dans le second buffer
      if { "$ra" == "" && "$dec" == "" } {
         set ra  [lindex [buf$num(buffer2) getkwd RA] 1]
         set dec [lindex [buf$num(buffer2) getkwd DEC] 1]
      }

      if { "$ra" != "" && "$dec" != "" } {
         #--- je convertis RA au format HMS
         set ra "[mc_angle2hms $ra 360 zero 0 auto string]"
         #--- je supprime les decimales des secondes
         set ra [string range $ra 0 [expr [string first "s" "$ra" ]  ] ]

         #--- je convertis DEC au format DMS
         set dec "[mc_angle2dms $dec 90 zero 0 + string ] "
         #--- je supprime les decimales des secondes
         set dec [string range $dec 0 [expr [string first "s" "$dec" ]  ] ]

         set found 1
      }
   }

   if { $found ==  0 }  {
      #--- deuxieme  tentative : je recupere les coordonnees dans le fichier sn.log
      set snlog "sn.log"
      set filename [lindex $rep(x1) $rep(xx1)]

      if { "$filename" != "" } {
         set shortname [file rootname [file tail $filename]]
         #--- Dans le cas des fichiers compresses *.extension.gz, il faut supprimer l'extension qui reste
         if { [string first "." "$shortname" ] != -1 } {
            set  shortname [ file rootname $shortname  ]
         }

         if { "$shortname" != "" } {
            #--- j'ouvre le fichier sn.log
            set vector ""
            catch {
               set fileId [open [ file join $rep(1) ${snlog} ] r]
               set vector [read $fileId];
               close  $fileId
            } result

            if { $vector != "" } {
               #--- je cherche l'objet dans le fichier sn.log
               set indice 0
               set line  [lindex $vector $indice]
               while { ($line != "") && ($found == 0)} {
                  set line  [lindex $vector $indice]
                  if { $shortname == [lindex $line 0]  } {
                     set ra  "[ lindex $line 1 ]h[ lindex $line 2 ]m[ lindex $line 3 ]s"
                     set dec "[ lindex $line 4 ]d[ lindex $line 5 ]m[ lindex $line 6 ]s"
                     set found 1
                  }
                  incr indice
               }
            }
         }
      }
   }

   if { $found == 0 }  {
      #--- troisieme tentative : je recupere le nom de l'objet
      #--- attention : cette solution depends des catalogues presents dans carteduciel
      #---             (catalogues presents par defaut : NGC, IC )
      set filename [lindex $rep(x1) $rep(xx1)]
      if { "$filename" != "" } {
         set shortname [file rootname [file tail $filename]]
         #--- Dans le cas des fichiers compresses *.extension.gz, il faut supprimer l'extension qui reste
         if { [string first "." "$shortname" ] != -1 } {
            set  shortname [ file rootname $shortname  ]
         }
         if { "$shortname" != "" } {
            set found 1
         }
      }
   }

   #--- j'envoi la commande d'affichage
   if { $found == 1} {
      set zoom_objet "10"
      set avant_plan "1"
      ::carte::gotoObject "$shortname" "$ra" "$dec" $zoom_objet $avant_plan
   }
}

