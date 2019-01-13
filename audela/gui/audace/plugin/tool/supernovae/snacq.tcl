#
# Fichier : snacq.tcl
# Description : Outil d'acquisition d'images pour la recherche de supernovae
#               Automatic supernovae research tool
# Auteur : Alain KLOTZ
# Mise à jour $Id: snacq.tcl 13000 2016-01-30 23:10:32Z robertdelmas $
#

# ===================================================================
# ===================================================================
# ===================================================================

global audace conf snconf

#--- Initialisation des repertoires
set sn(inidir)        [ pwd ]
set snconf(repsnaude) [ file join $audace(rep_plugin) tool supernovae ]

#--- Chargement des scripts associes
source [ file join $snconf(repsnaude) snmacros.tcl ]
source [ file join $snconf(repsnaude) snmacros.cap ]

#--- Chargement de la configuration
catch { snconfacqLoad }
snconfacqVerif

#--- Recuperation de la localisation de l'observateur
catch { set snconf(localite) "$audace(posobs,observateur,gps)" }

#--- Recuperation du repertoire dedie aux images
catch { set snconf(dossier) "$audace(rep_images)" }

#--- Recuperation du nom de l'observateur
catch { set snconf(fits,OBSERVER) "$conf(posobs,nom_observateur)" }

# ===================================================================
# ===================================================================
# ===================================================================

set extname          $conf(extension,defaut)
set snconf(darkfile) "d$snconf(exptime)b$snconf(binning)$extname"
set snconf(biasfile) "d0b$snconf(binning)$extname"

#--- Definition of global variables (arrays)
#--- Definition des variables globales (arrays)
global num        #--- Index for devices
global caption    #--- Texts of captions
global zone       #--- Window name of usefull screen parts
global info_image #--- Some infos on the current image
global audace
global sn
global snconf
global conf
global color

#--- Initialisation pour la sortie par appui sur Quitter
set sn(exit)      "0"
set sn(stop)      "0"
set sn(exit_visu) "0"

#--- Load the captions
source [ file join $snconf(repsnaude) snacq.cap ]

# ==========================================
# ===   Setting the graphic interface    ===
# === Met en place l'interface graphique ===
# ==========================================

#--- Create the toplevel window .snacq
#--- Cree la fenetre .snacq de niveau le plus haut

if { [winfo exists $audace(base).snacq] } {
   wm withdraw $audace(base).snacq
   wm deiconify $audace(base).snacq
   focus $audace(base).snacq.frame2.but_exit
   return
}

#---
if { [ info exists snconf(geometry) ] } {
   set deb [ expr 1 + [ string first + $snconf(geometry) ] ]
   set fin [ string length $snconf(geometry) ]
   set snconf(position) "+[ string range $snconf(geometry) $deb $fin ]"
}

#---
toplevel $audace(base).snacq -class Toplevel
wm geometry $audace(base).snacq 570x460$snconf(position)
wm resizable $audace(base).snacq 1 1
wm minsize $audace(base).snacq 510 420
wm title $audace(base).snacq $caption(snacq,main_title)
wm protocol $audace(base).snacq WM_DELETE_WINDOW { ::recupPositionSnAcq ; ::exitSnAcq }

#--- Cree un frame pour l'etat des connexions
frame $audace(base).snacq.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame1 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Cree un label pour la camera
   if {[::cam::list]!=""} {
      set cap1 "$caption(snacq,typecam) [lindex [cam$audace(camNo) info] 1]"
      set fg $color(blue)
   } else {
      set cap1 $caption(snacq,nocam)
      set fg $color(red)
   }
   label $audace(base).snacq.frame1.labURL_cam \
      -text $cap1 -borderwidth 0 -relief flat -fg $fg
   pack $audace(base).snacq.frame1.labURL_cam \
      -in $audace(base).snacq.frame1 -side left \
      -padx 8 -pady 3

   #--- Cree un label pour le telescope
   set snconf(telescope) $conf(telescope)
   if {[::tel::list]!=""} {
      set cap2 "$caption(snacq,typetel) [ tel$audace(telNo) name ]"
      set fg $color(blue)
   } else {
      set cap2 $caption(snacq,notel)
      set fg $color(red)
   }
   label $audace(base).snacq.frame1.labURL_tel \
      -text $cap2 -borderwidth 0 -relief flat -fg $fg
   pack $audace(base).snacq.frame1.labURL_tel \
      -in $audace(base).snacq.frame1 -side left \
      -padx 8 -pady 3

#--- Cree un frame pour le dossier
frame $audace(base).snacq.frame9 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame9 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Cree un label pour le dossier
   label $audace(base).snacq.frame9.label_rep \
      -text $caption(snacq,dossier) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame9.label_rep \
      -in $audace(base).snacq.frame9 -side left \
      -padx 3 -pady 3

   #--- Cree un label pour le chemin du dossier
   label $audace(base).snacq.frame9.labURL_chemin_rep \
      -text $snconf(dossier) \
      -borderwidth 0 -relief flat -fg $color(blue)
   pack $audace(base).snacq.frame9.labURL_chemin_rep \
      -in $audace(base).snacq.frame9 -side left \
      -padx 3 -pady 3

#--- Cree un frame pour la logalite et la hauteur du Soleil
frame $audace(base).snacq.frame10 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame10 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Cree un label pour la localite
   label $audace(base).snacq.frame10.label_localite \
      -text $caption(snacq,localite) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame10.label_localite \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

   #--- Cree un label pour la position de la localite
   label $audace(base).snacq.frame10.labURL_position_localite \
      -text $snconf(localite) \
      -borderwidth 0 -relief flat -fg $color(blue)
   pack $audace(base).snacq.frame10.labURL_position_localite \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

   #--- Cree un label pour la hauteur du soleil
   label $audace(base).snacq.frame10.label_haurore \
      -text $caption(snacq,haurore) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame10.label_haurore \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

   #--- Cree une ligne d'entree pour la hauteur du soleil
   entry $audace(base).snacq.frame10.entry_haurore \
      -textvariable snconf(haurore) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame10.entry_haurore \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

#--- Cree un frame pour y mettre des boutons
frame $audace(base).snacq.frame11 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame11 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame11.label_houest \
      -text $caption(snacq,houest) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame11.label_houest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame11.entry_houest \
      -textvariable snconf(houest) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame11.entry_houest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame11.label_hest \
      -text $caption(snacq,hest) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame11.label_hest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame11.entry_hest \
      -textvariable snconf(hest) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame11.entry_hest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame12 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame12 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame12.label_decinf \
      -text $caption(snacq,decinf) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame12.label_decinf \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame12.entry_decinf \
      -textvariable snconf(decinf) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame12.entry_decinf \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame12.label_decsup \
      -text $caption(snacq,decsup) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame12.label_decsup \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame12.entry_decsup \
      -textvariable snconf(decsup) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame12.entry_decsup \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame12.label_waittime \
      -text "$caption(snacq,waittime)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame12.label_waittime \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame12.entry_waittime \
      -textvariable snconf(waittime) \
      -borderwidth 1 -relief groove -width 6
   pack $audace(base).snacq.frame12.entry_waittime \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame13 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame13 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_exptime \
      -text "$caption(snacq,exptime)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_exptime \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_exptime \
      -textvariable snconf(exptime) \
      -borderwidth 1 -relief groove -width 4
   pack $audace(base).snacq.frame13.entry_exptime \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_binning \
      -text "$caption(snacq,binning)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_binning \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_binning \
      -textvariable snconf(binning) \
      -borderwidth 1 -relief groove -width 3
   pack $audace(base).snacq.frame13.entry_binning \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_nbimages \
      -text "$caption(snacq,nbimages)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_nbimages \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_nbimages \
      -textvariable snconf(nbimages) \
      -borderwidth 1 -relief groove -width 2
   pack $audace(base).snacq.frame13.entry_nbimages \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_unsmearing \
      -text $caption(snacq,unsmearing) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_unsmearing \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_unsmearing \
      -textvariable snconf(unsmearing) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame13.entry_unsmearing \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame14 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame14 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame14.label_fichier_sn \
      -text "$caption(snacq,fichier_sn)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame14.label_fichier_sn \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Recherche des catalogues de galaxies disponibles pour la recherche de supernovae
   set catasupernovae      ""
   set list_catasupernovae ""
   set list_fichier [ glob -nocomplain -dir [ file join $snconf(repsnaude) cata_supernovae ] *.txt ]
   for { set i 0 } { $i <= [ expr [ llength $list_fichier ] - 1 ] } { incr i } {
      set catasupernovae [ file tail [ lindex $list_fichier $i ] ]
      lappend list_catasupernovae "$catasupernovae"
   }

   #--- Create a combobox
   #--- Cree une combobox
   #--- Combobox catalogues de galaxies
   set list_combobox "$list_catasupernovae"
   ComboBox $audace(base).snacq.frame14.combobox_fichier_sn \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable snconf(fichier_sn) \
      -values $list_combobox
   pack $audace(base).snacq.frame14.combobox_fichier_sn \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame14.label_magsup \
      -text "$caption(snacq,magsup)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame14.label_magsup \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame14.entry_magsup \
      -textvariable snconf(magsup) \
      -borderwidth 1 -relief groove -width 5
   pack $audace(base).snacq.frame14.entry_magsup \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame14.label_maginf \
      -text "$caption(snacq,maginf)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame14.label_maginf \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame14.entry_maginf \
      -textvariable snconf(maginf) \
      -borderwidth 1 -relief groove -width 5
   pack $audace(base).snacq.frame14.entry_maginf\
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame15 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame15 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame15.label_foclen \
      -text "$caption(snacq,foclen)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame15.label_foclen \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   if {[::cam::list]!=""} {
      ::keyword::onChangeConfOptic $audace(visuNo)
      set snconf(foclen) $::keyword::private(focale_resultante)
      set cap3 "$snconf(foclen)"
      set fg $color(blue)
   } else {
      set cap3 "------"
      set fg $color(red)
   }
   label $audace(base).snacq.frame15.labURL_foclen \
      -textvariable cap3 \
      -borderwidth 0 -relief flat -fg $fg
   pack $audace(base).snacq.frame15.labURL_foclen \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame15.label_observer \
      -text "$caption(snacq,fits,OBSERVER)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame15.label_observer \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame15.labURL_observer \
      -text $snconf(fits,OBSERVER) \
      -borderwidth 0 -relief flat -fg $color(blue)
   pack $audace(base).snacq.frame15.labURL_observer \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame16 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame16 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame16.label_en-tete_fits \
      -text "$caption(snacq,en-tete_fits)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame16.label_en-tete_fits \
      -in $audace(base).snacq.frame16 -side left \
      -padx 3 -pady 3

   #--- Create a button
   #--- Cree un boutton
   button $audace(base).snacq.frame16.but_mots_cles \
      -text "$caption(snacq,mots_cles)" -borderwidth 2 \
      -command { ::keyword::run $audace(visuNo) ::conf(supernovae,keywordConfigName) }
   pack $audace(base).snacq.frame16.but_mots_cles \
      -in $audace(base).snacq.frame16 -side left -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   #--- Create a label
   #--- Cree un label
   entry $audace(base).snacq.frame16.labNom \
      -textvariable ::conf(supernovae,keywordConfigName) \
      -state readonly -takefocus 0 -justify center
   pack $audace(base).snacq.frame16.labNom -side left -padx 6

   #--- Create a checkbutton
   #--- Cree un checkbutton
   checkbutton $audace(base).snacq.frame16.checkbutton -text "$caption(snacq,avancement_acq)" \
      -highlightthickness 0 -variable snconf(avancementAcq)
   pack $audace(base).snacq.frame16.checkbutton \
      -in $audace(base).snacq.frame16 -side right -anchor w \
      -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

#--- Create a frame to put buttons in it
#--- Cree un frame pour y mettre des boutons
frame $audace(base).snacq.frame2 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame2 \
   -in $audace(base).snacq -anchor s -side bottom -expand 0 -fill x

#--- Create the button GO and ...
#--- Cree le boutton GO et ...
button $audace(base).snacq.frame2.but_go2 \
   -text $caption(snacq,go2) -borderwidth 2 \
   -command { goSnAcq 1 }
pack $audace(base).snacq.frame2.but_go2 \
   -in $audace(base).snacq.frame2 -side left -anchor w \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_go \
   -text $caption(snacq,go) -borderwidth 2 \
   -command { goSnAcq 0 }
pack $audace(base).snacq.frame2.but_go \
   -in $audace(base).snacq.frame2 -side left -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_stop \
   -text $caption(snacq,stop) -borderwidth 2 \
   -command { $audace(base).snacq.frame2.but_stop configure -relief groove ; ::stopSnAcq }
pack $audace(base).snacq.frame2.but_stop \
   -in $audace(base).snacq.frame2 -side left -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_exit \
   -text $caption(snacq,exit) -borderwidth 2 \
   -command { ::recupPositionSnAcq ; $audace(base).snacq.frame2.but_exit configure -relief groove ; ::exitSnAcq }
pack $audace(base).snacq.frame2.but_exit \
   -in $audace(base).snacq.frame2 -side left -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

button $audace(base).snacq.frame2.but_help \
   -text $caption(snacq,help) -borderwidth 2 \
   -command { ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::supernovae::getPluginType ] ] \
      [ ::supernovae::getPluginDirectory ] [ ::supernovae::getPluginHelp ] sn_acq }
pack $audace(base).snacq.frame2.but_help \
   -in $audace(base).snacq.frame2 -side right -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_gobias \
   -text $caption(snacq,gobias) -borderwidth 2 \
   -command { makeBias }
pack $audace(base).snacq.frame2.but_gobias \
   -in $audace(base).snacq.frame2 -side right -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_godark \
   -text $caption(snacq,godark) -borderwidth 2 \
   -command { makeDark }
pack $audace(base).snacq.frame2.but_godark \
   -in $audace(base).snacq.frame2 -side right -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
#--- Create a vertical scrollbar for the status listbox
#--- Cree un acsenseur vertical pour la console de retour d'etats
frame $audace(base).snacq.frame3
scrollbar $audace(base).snacq.frame3.scr1 -orient vertical \
   -command {$audace(base).snacq.frame3.lst1 yview} -takefocus 1 -borderwidth 1
pack $audace(base).snacq.frame3.scr1 \
   -in $audace(base).snacq.frame3 -side right -fill y
set zone(status_scrl) $audace(base).snacq.frame3.scr1

#--- Create a console for status returned
#--- Cree la console de retour d'etats
text $audace(base).snacq.frame3.lst1 \
   -borderwidth 1 -relief sunken \
   -yscrollcommand {global audace ; $audace(base).snacq.frame3.scr1 set} -wrap word
pack $audace(base).snacq.frame3.lst1 \
   -in $audace(base).snacq.frame3 -expand yes -fill both \
   -padx 3 -pady 3
set zone(status_list) $audace(base).snacq.frame3.lst1
pack $audace(base).snacq.frame3 -expand yes -fill both

#--- La fenetre est active
focus $audace(base).snacq

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).snacq

$zone(status_list) insert end "$caption(snacq,status)\n\n"

# =================================
# ===    Setting the binding    ===
# === Met en place les liaisons ===
# =================================

bind $audace(base).snacq.frame1.labURL_cam <ButtonPress-1> {
   ::confCam::run
   tkwait window $audace(base).confCam
   if {[::cam::list]!=""} {
      set cap1 "$caption(snacq,typecam) [lindex [cam$audace(camNo) info] 1]"
      ::keyword::onChangeConfOptic $audace(visuNo)
      set snconf(foclen) $::keyword::private(focale_resultante)
      set cap3 "$snconf(foclen)"
      set fg $color(blue)
   } else {
      set cap1 $caption(snacq,nocam)
      set cap3 "------"
      set fg $color(red)
   }
   catch { $audace(base).snacq.frame1.labURL_cam configure -text $cap1 -fg $fg }
   catch { $audace(base).snacq.frame15.labURL_foclen configure -text $cap3 -fg $fg }

   update
}

bind $audace(base).snacq.frame1.labURL_tel <ButtonPress-1> {
   ::confTel::run
   tkwait window $audace(base).confTel
   set snconf(telescope) $conf(telescope)
   if {[::tel::list]!=""} {
      set cap2 "$caption(snacq,typetel) [ tel$audace(telNo) name ]"
      set fg $color(blue)
   } else {
      set cap2 $caption(snacq,notel)
      set fg $color(red)
   }
   catch { $audace(base).snacq.frame1.labURL_tel configure -text $cap2 -fg $fg }
   update
}

bind $audace(base).snacq.frame9.labURL_chemin_rep <ButtonPress-1> {
   ::cwdWindow::run "$audace(base).cwdWindow"
   tkwait window $audace(base).cwdWindow
   set snconf(dossier) "$audace(rep_images)"
  catch { $audace(base).snacq.frame9.labURL_chemin_rep configure -text $snconf(dossier) }
   update
}

bind $audace(base).snacq.frame10.labURL_position_localite <ButtonPress-1> {
   ::confPosObs::run "$audace(base).confPosObs"
   tkwait window $audace(base).confPosObs
   set snconf(localite) $audace(posobs,observateur,gps)
   catch { $audace(base).snacq.frame10.labURL_position_localite configure -text $snconf(localite) }
   update
}

bind $audace(base).snacq.frame15.labURL_foclen <ButtonPress-1> {
   if {[::cam::list]!=""} {
      ::keyword::run $audace(visuNo) ::conf(supernovae,keywordConfigName)
      tkwait window $audace(base).keyword
      set snconf(foclen) $::keyword::private(focale_resultante)
      set cap3 "$snconf(foclen)"
      set fg $color(blue)
   } else {
      ::confCam::run
      if {[::cam::list]!=""} {
         set cap1 "$caption(snacq,typecam) [lindex [cam$audace(camNo) info] 1]"
         ::keyword::onChangeConfOptic $audace(visuNo)
         set snconf(foclen) $::keyword::private(focale_resultante)
         set cap3 "$snconf(foclen)"
         set fg $color(blue)
         catch { $audace(base).snacq.frame1.labURL_cam configure -text $cap1 -fg $fg }
      } else {
         set cap3 "------"
         set fg $color(red)
      }
   }
   catch { $audace(base).snacq.frame15.labURL_foclen configure -text $cap3 -fg $fg }
   update
}

bind $audace(base).snacq.frame15.labURL_observer <ButtonPress-1> {
   ::confPosObs::run "$audace(base).confPosObs"
   tkwait window $audace(base).confPosObs
   set snconf(fits,OBSERVER) $conf(posobs,nom_observateur)
   catch { $audace(base).snacq.frame15.labURL_observer configure -text $snconf(fits,OBSERVER) }
   update
}

# ============================== FIN DU PROGRAMME PRINCIPAL ===============================

# =========================================================================================
proc goSnAcq { {sndebug 0} } {

   global audace
   global zone
   global caption
   global snconf
   global sn
   global conf

   set testjour      "0"
   set sn(stop)      "0"
   set sn(exit_visu) "1"

   # ================================================
   # === Mise a jour des donnees de configuration ===
   # ================================================
   ::updateSnAcq

   # =====================================================
   # === Verifie que tous les composants sont presents ===
   # =====================================================
   if {$sndebug==0} {
      set snlog sn.log
      set sn2log sn2.log
      if {[::cam::list]==""} {
         bell
         snInfo "$caption(snacq,nocam)\n"
         set sn(exit_visu) "0"
         return
      }
      if {[::tel::list]==""} {
         bell
         snInfo "$caption(snacq,notel)\n"
         set sn(exit_visu) "0"
         return
      }
      set f ""
      set catchError [ catch { set f [ glob [ file join $snconf(dossier) $snconf(darkfile) ] ] } ]
      if { $catchError == "1" } {
         set f ""
      }
      if {$f==""} {
         bell
         snInfo "$caption(snacq,status_nodark)\n"
         set sn(exit_visu) "0"
         return
      }
      set f ""
      set catchError [ catch { set f [ glob [ file join $snconf(dossier) $snconf(biasfile) ] ] } ]
      if { $catchError == "1" } {
         set f ""
      }
      if {$f==""} {
         bell
         snInfo "$caption(snacq,status_nobias)\n"
         set sn(exit_visu) "0"
         return
      }
   } else {
      set snlog snsimu.log
      set sn2log snsimu2.log
   }

   set dossier_alerte [ file join $snconf(repsnaude) alert ]

   # ================================
   # === Charge des macros utiles ===
   # ================================
   snInfo "$caption(snacq,status_importemacros)..."
   source [ file join $snconf(repsnaude) snmacros.tcl ]

   # ============================================
   # === Initialisation de l'heure (TU ou HL) ===
   # ============================================
   set now [::audace::date_sys2ut now]

   # ===================================================================
   # === Calcule les heures de la prochaine nuit et du prochain jour ===
   # ===================================================================
   snInfo "$caption(snacq,status_hdebfin)"
   set jj_debutnuit [sunset  $snconf(haurore) $snconf(localite)]
   set jj_debutjour [sunrise $snconf(haurore) $snconf(localite)]
   snInfo " $caption(snacq,status_debnuit) : [mc_date2ymdhms $jj_debutnuit]"
   snInfo " $caption(snacq,status_finnuit) : [mc_date2ymdhms $jj_debutjour]"

   # ===============================================
   # === Si il fait jour alors on attend la nuit ===
   # ===============================================
   if {$sndebug==0} {
      if {$jj_debutnuit<$jj_debutjour} {
         snInfo "$caption(snacq,status_ilfaitjour)\n"
         if {$testjour==0} {
            while {[mc_date2jd $now]<=$jj_debutnuit} {
               #--- Cas d'une action sur le bouton Quitter
               set sn(exit_visu) "0"
               if { $sn(exit) == "1" } {
                  destroy $audace(base).snacq
                  if [winfo exists $audace(base).msgExitSnAcq] {
                     destroy $audace(base).msgExitSnAcq
                  }
               }
               #--- Cas d'une action sur le bouton Stop
               set sn(exit_visu) "0"
               if { $sn(stop) == "1" } {
                  if [winfo exists $audace(base).msgStopSnAcq] {
                     destroy $audace(base).msgStopSnAcq
                     $audace(base).snacq.frame2.but_stop configure -relief raised
                  }
               }
               #--- Bouclage sur l'heure TU du systeme
               set now [::audace::date_sys2ut now]
               update
            }
         }
      }
   }

   if {$jj_debutnuit>$jj_debutjour} {
      set jj_debutnuit [expr ${jj_debutnuit}-1]
   }
   set jj_finnuit $jj_debutjour
   snInfo " $caption(snacq,status_obsjusqua) : [mc_date2ymdhms $jj_finnuit]"

   # =================================================================
   # === Charge la liste des objets et supprime ceux inobservables ===
   # =================================================================
   # === Chaque ligne du fichier des objets est au format suivant :
   # === nom hh mm ss dd ''
   # =================================================================
   snInfo "$caption(snacq,status_loaddb)..."
   set objlist [readObjects [ file join $snconf(repsnaude) cata_supernovae $snconf(fichier_sn) ] ]
   snInfo " [llength $objlist] $caption(snacq,status_galadb)"
   snInfo "$caption(snacq,status_seledb)..."
   set objlist [selectObjects $objlist $snconf(decinf) $snconf(decsup) $snconf(localite) $snconf(maginf) $snconf(magsup)]
   snInfo " [llength $objlist] $caption(snacq,status_galobs)"
   snInfo ""
   set contents $objlist

   set DR [expr acos(-1)/180.]

   catch {unset name0} {}

   # =======================================================
   # === Initialise les liste d'acquisitions deja faites ===
   # =======================================================
   set dejafaits {}
   set dejafaits2 ""
   if {$sndebug==0} {
      catch {
         set input [ open [ file join $snconf(dossier) sn.log ] r]
         set dejafaits [ read $input ]
         close $input
      }
      catch {
         set input [ open [ file join $snconf(dossier) sn2.log ] r]
         set dejafaits2 [ read $input ]
         close $input
         set dejafaits2 [ string range $dejafaits2 0 [ expr [ string length $dejafaits2 ]-2 ]  ]
      }
   }

   # ===============================
   # === Boucle des acquisitions ===
   # ===============================

   set kdeb -1
   set nbgal 0
   set nbgal2 0
   set listfileeventdone ""
   set now [::audace::date_sys2ut now]
   if {$sndebug==1} {
      if {[mc_date2jd $now]<$jj_debutnuit} {
         set nownow $jj_debutnuit
      } else {
         set nownow [mc_date2jd $now]
      }
      set nownow0 $nownow
   } else {
      set nownow $now
   }

   #--- duree = temps deplacement telescope (environ 10 s) + waiting time + temps acquisition image en fonction du binning
   set duree [ expr ( 10. + $snconf(waittime) + ( 3. +$snconf(exptime) + 10. * 2. / $snconf(binning) ) ) ]

   set indice_image 0

   while {[mc_date2jd $nownow]<=$jj_finnuit} {

      #--- Sortie de la boucle si appui sur le bouton Quitter
      if { $sn(exit) == "1" } {
         break
      }

      #--- Sortie de la boucle si appui sur le bouton Stop
      if { $sn(stop) == "1" } {
         break
      }

      #--- nownow
      if {$sndebug==1} {
         set nownow [ expr ${nownow0} + $duree / 86400. * $nbgal2 ]
     } else {
         set now [::audace::date_sys2ut now]
         set nownow [mc_date2jd $now]
      }

      #--- Y-a-il un evenement a observer ?
      set listfileevent ""
      set catchError [ catch { set listfileevent [glob ${dossier_alerte}*.tcl] } ]
      if { $catchError == "1" } {
         set listfileevent ""
      }
      foreach fileevent $listfileevent {
         catch {source $fileevent} {
            snInfo "$caption(snacq,status_alerterror) $fileevent !!!"
         }
      }

      #--- Calcule le temps sideral local
      set ligne [mc_date2lst $nownow $snconf(localite)]
      set tsl [mc_angle2deg [lindex $ligne 0]h[lindex $ligne 1]m[lindex $ligne 2]s]

      #--- Calcule la valeur de kdeb
      if {$kdeb==-1} {
         set kfin [expr [llength $contents]-2]
         for {set k 0} {$k < $kfin} {incr k} {
            set ligne [lindex $contents $k]
            set ra0 [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set kk [expr $k+1]
            set ligne [lindex $contents $kk]
            set ra1 [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set h0 [expr $tsl-$ra0-$snconf(houest)]
            set h1 [expr $tsl-$ra1-$snconf(houest)]
            set h [expr $h0*$h1]
            if {$h<0} {
               break;
            }
         }
         set kdeb $k
      }

      #--- Selectionne l'objet a observer
      if {($indice_image<$snconf(nbimages))&&($indice_image!=0)} {
         set ligne $lignedavant
         incr indice_image
      } else {
         set fin [expr [llength $contents]-1]
         set kfin [expr 2*[llength $contents]-1]
         set ongarde 0
         for {set k $kdeb} {$k < $kfin} {incr k} {
            #--- Calcule l'indice kk
            if {$k>$fin} {
               set kk [expr $k-$fin-1]
            } else {
               set kk $k
            }
            #--- ra est le RA de la galaxie
            set ligne [lindex $contents $kk]
            set ra [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set dec [mc_angle2deg [lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s 90]
            #--- h est l'angle horaire de la galaxie
            set h [expr $tsl-$ra]
            if {$h<0} {
               set h [expr $h+360.]
            }
            #--- Critere pour garder l'objet
            set ongarde 0
            if {$h<$snconf(houest)} {
               set ongarde 1
            }
            if {$h>$snconf(hest)} {
               set ongarde 1
            }
            if {$h<$snconf(hest)} {
               if {$h>180} {
                  set ongarde 0
                  break
               }
            }
            set name [lindex $ligne 0]
            if {[string first $name $dejafaits2]!=-1} {
               set ongarde 0
            }
            #--- On garde l'objet
            if {$ongarde==1} {
               set indice_image 1
               set kdeb $k
               incr kdeb
               lappend dejafaits $ligne
               set lignedavant $ligne
               set dudul [format "jj= %f tsl= %.2f ra= %.2f h= %.2f dec= %.2f %s" $nownow $tsl $ra $h $dec $ligne]
               append dejafaits2 "$dudul \n"
               break
            }
         }
         #--- Fin de la boucle for
      }

      if {$ongarde==1} {
         set ra "[lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s"
         set dec "[lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s"

         set result "[ mc_date2ymdhms $nownow ]\n[ list $ligne $ra $dec ]"
         snInfo "$result"

         if {$sndebug==0} {
            #--- Pointe le telescope
            if {$indice_image==1} {
               set catchError [ catch {
                  ::telescope::goto [ list $ra $dec ] 1 "" "" [lindex $ligne 0]
               } ]
               if { $catchError != 0 } {
                  ::tkutil::displayErrorInfoTelescope "GOTO Error"
                  return
               }
            }

            #--- Delai d'attente
            after [expr 1000*$snconf(waittime)]

            #--- Lit la position du telescope
            set result "$caption(snacq,status_telpointe) [ ::telescope::afficheCoord ]"
            snInfo ""
            snInfo "$result"
            snInfo ""

            #--- Si une raquette existe, rafraichissement de l'affichage des coordonnees
            ::telescope::afficheCoord

            #--- Acquisition
            set camera "cam$audace(camNo)"
            set buffer buf[cam$audace(camNo) buf]

            #--- La commande exptime permet de fixer le temps de pose de l'image
            $camera exptime $snconf(exptime)

            #--- La commande bin permet de fixer le binning
            $camera bin [list $snconf(binning) $snconf(binning)]

            #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
            if { $snconf(exptime) == "0" } {
               avancementPose $snconf(avancementAcq) 1
            }

            #--- Declenchement de l'acquisition
            $camera acq

            #--- Alarme sonore de fin de pose
            ::camera::alarmeSonore $snconf(exptime)

            #--- Pretraitement pendant l'integration
            if { [info exist name0] == 1 } {
               set extname $conf(extension,defaut)
               ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" OPT \"dark=$snconf(dossier)/$snconf(darkfile)\" \"bias=$snconf(dossier)/$snconf(biasfile)\" unsmearing=$snconf(unsmearing)"
               ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
               ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" STAT fwhm"
            }

            #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
            gestionPose 1

            #--- Visualisation de l'image acquise
            ::audace::autovisu $audace(visuNo)

            #--- Modification du nom des images a la demande de Robin
            if { $snconf(nbimages) != "1" } {
               set name "[lindex $ligne 0]-$indice_image"
            } else {
               set name "[lindex $ligne 0]"
            }

            #--- Rajoute des mots cles dans l'en-tete FITS
            foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(supernovae,keywordConfigName) ] {
               buf$audace(bufNo) setkwd $keyword
            }

            #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
            ::confVisu::setFileName $audace(visuNo) $name

            #--- Mots cles pour compatibilite Prism
            snPrism

            #--- Sauvegarde de l'image
            $buffer save [ file join $snconf(dossier) ${name} ]
            set name0 $name

         }
         #--- Fin du debug

         incr nbgal
         snInfo " "

         catch {
            set fileId [ open [ file join $snconf(dossier) ${snlog} ] w ]
            puts $fileId $dejafaits
            close $fileId
         }

         catch {
            set fileId [ open [ file join $snconf(dossier) ${sn2log} ] w ]
            puts $fileId $dejafaits2
            close $fileId
         }

      }
      #--- Fin de la condition 'on garde' (donc on observe)

      if {$sndebug==1} {
         incr nbgal2
         if {$nbgal2>=700} {break;}
         if {$nownow>=$jj_debutjour} { break; }
      }

   }
   #-- Fin du while

   if {$sndebug==0} {
      if { [info exist name0] == 1 } {
         #--- Pretraitement de la derniere pose
         set extname $conf(extension,defaut)
         ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" OPT \"dark=$snconf(dossier)/$snconf(darkfile)\" \"bias=$snconf(dossier)/$snconf(biasfile)\" unsmearing=$snconf(unsmearing)"
         ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
         ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" STAT fwhm"
      }
   }

   set nbgal0 [expr int(ceil(($nbgal)/$snconf(nbimages)))]
   set result "$caption(snacq,status_nightend) $nbgal0 galaxies"
   snInfo "$result\n"

   set sn(exit_visu) "0"
   if { $sn(exit) == "1" } {
      destroy $audace(base).snacq
      if [winfo exists $audace(base).msgExitSnAcq] {
         destroy $audace(base).msgExitSnAcq
      }
   }
   if { $sn(stop) == "1" } {
      if [winfo exists $audace(base).msgStopSnAcq] {
         destroy $audace(base).msgStopSnAcq
         $audace(base).snacq.frame2.but_stop configure -relief raised
      }
   }
}

# ===========================================================================================
# recupPositionSnAcq
# Permet de recuperer et de sauvegarder la position de la fenetre SnAcq
#
proc recupPositionSnAcq { } {
   global audace
   global conf
   global snconf

   set snconf(geometry) [ wm geometry $audace(base).snacq ]
   set deb [ expr 1 + [ string first + $snconf(geometry) ] ]
   set fin [ string length $snconf(geometry) ]
   set snconf(position) "+[ string range $snconf(geometry) $deb $fin ]"
}

# ===========================================================================================
# msgExitSnAcq
# Affichage d'un message d'alerte lors de la fermeture de la fenetre SnAcq
#
proc msgExitSnAcq { } {
   global audace
   global caption
   global color

   #---
   if [winfo exists $audace(base).msgExitSnAcq] {
      destroy $audace(base).msgExitSnAcq
   }
   toplevel $audace(base).msgExitSnAcq
   wm resizable $audace(base).msgExitSnAcq 0 0
   wm title $audace(base).msgExitSnAcq "$caption(snacq,attention)"
   set posx_msgExitSnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 1 ]
   set posy_msgExitSnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 2 ]
   wm geometry $audace(base).msgExitSnAcq +[ expr $posx_msgExitSnAcq + 200 ]+[ expr $posy_msgExitSnAcq + 270 ]
   wm transient $audace(base).msgExitSnAcq $audace(base).snacq

   #--- Cree l'affichage du message
   label $audace(base).msgExitSnAcq.labURL1 -text "$caption(snacq,texte1)" -fg $color(red)
   pack $audace(base).msgExitSnAcq.labURL1 -padx 10 -pady 2
   label $audace(base).msgExitSnAcq.labURL2 -text "$caption(snacq,texte2)" -fg $color(red)
   pack $audace(base).msgExitSnAcq.labURL2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).msgExitSnAcq

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).msgExitSnAcq
}

# ===========================================================================================
# msgStopSnAcq
# Affichage d'un message d'alerte lors de l'arret des acquisitions
#
proc msgStopSnAcq { } {
   global audace
   global caption
   global color

   #---
   if [winfo exists $audace(base).msgStopSnAcq] {
      destroy $audace(base).msgStopSnAcq
   }
   toplevel $audace(base).msgStopSnAcq
   wm resizable $audace(base).msgStopSnAcq 0 0
   wm title $audace(base).msgStopSnAcq "$caption(snacq,attention)"
   set posx_msgStopSnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 1 ]
   set posy_msgStopSnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 2 ]
   wm geometry $audace(base).msgStopSnAcq +[ expr $posx_msgStopSnAcq + 200 ]+[ expr $posy_msgStopSnAcq + 270 ]
   wm transient $audace(base).msgStopSnAcq $audace(base).snacq

   #--- Cree l'affichage du message
   label $audace(base).msgStopSnAcq.labURL1 -text "$caption(snacq,texte3)" -fg $color(red)
   pack $audace(base).msgStopSnAcq.labURL1 -padx 10 -pady 2
   label $audace(base).msgStopSnAcq.labURL2 -text "$caption(snacq,texte4)" -fg $color(red)
   pack $audace(base).msgStopSnAcq.labURL2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).msgStopSnAcq

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).msgStopSnAcq
}

#------------------------------------------------------------
# gestionPose GO_Stop
#    Gestion de la pose : Timer, avancement, attente fin, retournement image,
#    fin anticipee et fenetre d'avancement de la pose
#------------------------------------------------------------
proc gestionPose { GO_Stop } {
   global audace

   #--- Correspond a un demarrage de la pose
   if { $GO_Stop == "1" } {

      #--- Appel du timer
      after 10 dispTime

      #--- Attente de la fin de la pose
      ::camera::waitStateStand $audace(camNo)

      #--- Effacement de la fenetre de progression
      if [ winfo exists $audace(base).progress_pose ] {
         destroy $audace(base).progress_pose
      }

   #--- Correspond a un arret anticipe de la pose
   } elseif { $GO_Stop == "0" } {

      #--- Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      avancementPose "0"

   }
}

#------------------------------------------------------------
# dispTime
#    Decompte du temps d'exposition
#------------------------------------------------------------
proc dispTime { } {
   variable private
   global audace

   #--- j'arrete le timer s'il est deja lance
   if { [ info exists variable(dispTimeAfterId) ] && $variable(dispTimeAfterId) != "" } {
      after cancel $variable(dispTimeAfterId)
      set variable(dispTimeAfterId) ""
   }

   #--- je mets a jour la fenetre de progression
   set t [ cam$audace(camNo) timer -1 ]
   avancementPose $t

   if { $t > 0 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set variable(dispTimeAfterId) [ after 1000 dispTime ]
   } else {
      #--- je ne relance pas le timer
      set variable(dispTimeAfterId) ""
   }
}

#------------------------------------------------------------
# avancementPose t
#    Affichage d'une barre de progression qui simule l'avancement de la pose dans la visu 1
#------------------------------------------------------------
proc avancementPose { t } {
   global audace caption color conf snconf

   #--- Fenetre d'avancement de la pose non demandee
   if { $snconf(avancementAcq) == "0" } {
      return
   }

   #--- Recuperation de la position de la fenetre
   recupPositionAvancementPose

   #--- Initialisation de la barre de progression
   set cpt             "100"
   set dureeExposition [ cam$audace(camNo) exptime ]

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(avancement_pose,position) ] } { set conf(avancement_pose,position) "+120+315" }

   #---
   if { [ winfo exists $audace(base).progress_pose ] != "1" } {
      #---
      toplevel $audace(base).progress_pose
      wm transient $audace(base).progress_pose $audace(base)
      wm resizable $audace(base).progress_pose 0 0
      wm title $audace(base).progress_pose "$caption(camera,en_cours)"
      wm geometry $audace(base).progress_pose $conf(avancement_pose,position)

      #--- Cree le widget et le label du temps ecoule
      label $audace(base).progress_pose.lab_status -text "" -justify center
      pack $audace(base).progress_pose.lab_status -side top -fill x -expand true -pady 5

      #--- t est un nombre entier
      if { $t < 0 } {
         destroy $audace(base).progress_pose
      } elseif { $t > 0 } {
         $audace(base).progress_pose.lab_status configure -text "$t $caption(camera,sec) / \
            [ format "%d" [ expr int( $dureeExposition ) ] ] $caption(camera,sec)"
         set cpt [ expr $t * 100 / int( $dureeExposition ) ]
         set cpt [ expr 100 - $cpt ]
      } else {
         $audace(base).progress_pose.lab_status configure -text "$caption(camera,numerisation)"
      }
      #---
      catch {
         #--- Cree le widget pour la barre de progression
         frame $audace(base).progress_pose.cadre -width 200 -height 30 -borderwidth 2 -relief groove
         pack $audace(base).progress_pose.cadre -in $audace(base).progress_pose -side top \
            -anchor center -fill x -expand true -padx 8 -pady 8

         #--- Affiche de la barre de progression
         frame $audace(base).progress_pose.cadre.barre_color_invariant -height 26 -bg $color(blue)
         place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
            -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
         update
      }
      #--- Mise a jour dynamique des couleurs
      if { [ winfo exists $audace(base).progress_pose ] } {
         ::confColor::applyColor $audace(base).progress_pose
      }
   } else {
      #--- t est un nombre entier
      if { $t > 0 } {
         $audace(base).progress_pose.lab_status configure -text "$t $caption(camera,sec) / \
            [ format "%d" [ expr int( $dureeExposition ) ] ] $caption(camera,sec)"
         set cpt [ expr $t * 100 / int( $dureeExposition ) ]
         set cpt [ expr 100 - $cpt ]
      } else {
         $audace(base).progress_pose.lab_status configure -text "$caption(camera,numerisation)"
      }
      catch {
         #--- Affiche de la barre de progression
         place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
            -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
         update
      }
   }
}

#------------------------------------------------------------
# recupPositionAvancementPose
#    Recuperation de la position de la fenetre de progression de la pose
#------------------------------------------------------------
proc recupPositionAvancementPose { } {
   global audace conf

   if [ winfo exists $audace(base).progress_pose ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).progress_pose ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(avancement_pose,position) "+[ string range $geometry $deb $fin ]"
   }
}

# ===========================================================================================
# exitSnAcq
# Fermeture de la fenetre SnAcq
#
proc exitSnAcq { } {
   global audace
   global sn

   if { $sn(exit_visu) == "0" } {
      update ; snconfacqSave ; cd $sn(inidir) ; destroy $audace(base).snacq
   } else {
      set sn(exit) "1"
      ::msgExitSnAcq
      update ; snconfacqSave ; cd $sn(inidir)
   }
}

# ===========================================================================================
# stopSnAcq
# Arret des acquisitions de SnAcq
#
proc stopSnAcq { } {
   global audace
   global sn

   if { $sn(exit_visu) == "0" } {
      $audace(base).snacq.frame2.but_stop configure -relief raised
   } else {
      set sn(stop) "1"
      ::msgStopSnAcq
   }
}

# ===========================================================================================
# updateSnAcq
# Mise a jour des variables snconf
#
proc updateSnAcq { } {
   global audace conf snconf

   #--- Sauvegarde des parametres
   snconfacqSave
   #--- Chargement de la configuration
   catch { snconfacqLoad }
   snconfacqVerif
   #--- Rafraichissement des variables et des entry
   set extname $conf(extension,defaut)
   set snconf(darkfile) "d$snconf(exptime)b$snconf(binning)$extname"
   set snconf(biasfile) "d0b$snconf(binning)$extname"
   $audace(base).snacq.frame10.entry_haurore configure -textvariable snconf(haurore)
   $audace(base).snacq.frame11.entry_houest configure -textvariable snconf(houest)
   $audace(base).snacq.frame11.entry_hest configure -textvariable snconf(hest)
   $audace(base).snacq.frame12.entry_decinf configure -textvariable snconf(decinf)
   $audace(base).snacq.frame12.entry_decsup configure -textvariable snconf(decsup)
   $audace(base).snacq.frame12.entry_waittime configure -textvariable snconf(waittime)
   $audace(base).snacq.frame13.entry_exptime configure -textvariable snconf(exptime)
   $audace(base).snacq.frame13.entry_binning configure -textvariable snconf(binning)
   $audace(base).snacq.frame13.entry_nbimages configure -textvariable snconf(nbimages)
   $audace(base).snacq.frame13.entry_unsmearing configure -textvariable snconf(unsmearing)
   $audace(base).snacq.frame14.combobox_fichier_sn configure -textvariable snconf(fichier_sn)
   $audace(base).snacq.frame14.entry_magsup configure -textvariable snconf(magsup)
   $audace(base).snacq.frame14.entry_maginf configure -textvariable snconf(maginf)
   update
}

