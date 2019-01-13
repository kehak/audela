#
# Fichier : alaudine_nt.tcl
# Description : Permet de controler l'alimentation AlAudine NT avec port I2C
# Auteur : Robert DELMAS
# Mise à jour $Id: alaudine_nt.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::AlAudineNT {
}

#
# run
# Cree la fenetre de tests
# this = chemin de la fenetre
#
proc ::AlAudineNT::run { this } {
   variable This

   set This $this
   createDialog
}

#
# ok
# Fonction appellee lors de l'appui sur le bouton 'OK'
#
proc ::AlAudineNT::ok { } {
   variable This

   ::AlAudineNT::appliquer
   ::AlAudineNT::recupPosition
   destroy $This
}

#
# appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer'
#
proc ::AlAudineNT::appliquer { } {
   ::AlAudineNT::widgetToConf
   ::AlAudineNT::configureAlAudineNT
}

#
# afficherAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#
proc ::AlAudineNT::afficherAide { } {
   ::audace::showHelpPlugin link ethernaude "alaudine.htm"
}

#
# fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::AlAudineNT::fermer { } {
   variable This

   ::AlAudineNT::recupPosition
   destroy $This
}

#
# initConf
# Initialisation de variables de configuration
#
proc ::AlAudineNT::initConf { } {
   global conf

   #--- Initialisation de variables de configuration
   if { ! [ info exists conf(alaudine_nt,evaluation) ] }        { set conf(alaudine_nt,evaluation)        "25.0" }
   if { ! [ info exists conf(alaudine_nt,delta_t_max) ] }       { set conf(alaudine_nt,delta_t_max)       "30.0" }
   set t_ccd [ expr $conf(alaudine_nt,evaluation) - $conf(alaudine_nt,delta_t_max) / 2. ]
   if { ! [ info exists conf(alaudine_nt,temp_ccd_souhaite) ] } { set conf(alaudine_nt,temp_ccd_souhaite) "$t_ccd" }
}

#
# recupPosition
# Permet de recuperer et de sauvegarder la position de la fenetre de configuration de l'alimentation
#
proc ::AlAudineNT::recupPosition { } {
   variable This
   variable private
   global conf

   set private(geometry) [ wm geometry $This ]
   set deb [ expr 1 + [ string first + $private(geometry) ] ]
   set fin [ string length $private(geometry) ]
   set private(position) "+[ string range $private(geometry) $deb $fin ]"
   #---
   set conf(alaudine_nt,position) $private(position)
}

#
# createDialog
# Creation de l'interface graphique
#
proc ::AlAudineNT::createDialog { } {
   variable This
   variable private
   global audace caption color conf

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) link ethernaude alaudine_nt.cap ]

   #--- Initialisation de variables de configuration
   if { ! [ info exists conf(alaudine_nt,position) ] } { set conf(alaudine_nt,position) "+600+490" }
   ::AlAudineNT::initConf

   #--- confToWidget
   set private(evaluation)        $conf(alaudine_nt,evaluation)
   set private(delta_t_max)       $conf(alaudine_nt,delta_t_max)
   set private(temp_ccd_souhaite) $conf(alaudine_nt,temp_ccd_souhaite)

   #--- Initialisation
   set private(temp_ccd_mesure)   $caption(alaudine_nt,temp_ccd_mesure)

   #--- Recupere le camNo de la camera
   set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]

   #--- Verifie si le controle de la regulation existe
   if { [ cam$camNo hasRegulation ] != "1" } {
      tk_messageBox -title "$caption(alaudine_nt,attention)" -icon error \
         -message "$caption(alaudine_nt,message)"
      return
   }

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #---
   set private(position) $conf(alaudine_nt,position)
   #---
   if { [ info exists private(geometry) ] } {
      set deb [ expr 1 + [ string first + $private(geometry) ] ]
      set fin [ string length $private(geometry) ]
      set private(position) "+[ string range $private(geometry) $deb $fin ]"
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(alaudine_nt,titre)
   wm geometry $This $private(position)
   wm resizable $This 0 0
   wm protocol $This WM_DELETE_WINDOW ::AlAudineNT::fermer

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side top -fill x

   frame $This.frame3 -borderwidth 0 -relief raised
   pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame4 -borderwidth 0 -relief raised
   pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame5 -borderwidth 0 -relief raised
   pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame6 -borderwidth 0 -relief raised
   pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame7 -borderwidth 0 -relief raised
   pack $This.frame7 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame1 -side top -fill both -expand 1

   #--- Evaluation de la temperature ambiante de la camera CCD
   label $This.lab1 -text "$caption(alaudine_nt,evaluation)"
   pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

   entry $This.temp_amb -textvariable ::AlAudineNT::private(evaluation) -width 5 -justify center
   pack $This.temp_amb -in $This.frame3 -anchor center -side left -padx 0 -pady 5

   label $This.lab2 -text "$caption(alaudine_nt,degres)"
   pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

   #--- Delta t maximum possible
   label $This.lab3 -text "$caption(alaudine_nt,delta_t)"
   pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

   entry $This.delta_t_max -textvariable ::AlAudineNT::private(delta_t_max) -width 5 -justify center
   pack $This.delta_t_max -in $This.frame4 -anchor center -side left -padx 0 -pady 5

   label $This.lab4 -text "$caption(alaudine_nt,degres)"
   pack $This.lab4 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Temperatures minimale et maximale possibles
   set tmp_ccd_max $private(evaluation)
   set tmp_ccd_min [ expr $private(evaluation) - $private(delta_t_max) ]

   #--- Temperature du CCD souhaitee avec la glissiere de reglage
   label $This.lab5 -text "$caption(alaudine_nt,temp_ccd_souhaite)"
   pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

   scale $This.temp_ccd_souhaite_variant -from $tmp_ccd_min -to $tmp_ccd_max -length 300 \
      -orient horizontal -showvalue true -tickinterval 5 -resolution 0.1 \
      -borderwidth 2 -relief groove -variable ::AlAudineNT::private(temp_ccd_souhaite) -width 10 \
      -command "::AlAudineNT::reglageTemp"
   pack $This.temp_ccd_souhaite_variant -in $This.frame6 -anchor center -side left -padx 5 -pady 0

   entry $This.temp_ccd_souhaite -textvariable ::AlAudineNT::private(temp_ccd_souhaite) \
      -width 5 -justify center
   pack $This.temp_ccd_souhaite -in $This.frame6 -anchor center -side left -padx 0 -pady 0

   label $This.lab6 -text "$caption(alaudine_nt,degres)"
   pack $This.lab6 -in $This.frame6 -anchor center -side left -padx 5 -pady 0

   #--- Temperature du CCD mesuree
   label $This.lab7 -textvariable ::AlAudineNT::private(temp_ccd_mesure)
   pack $This.lab7 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

   #--- Site web officiel de l'AlAudine
   label $This.lab103 -text "$caption(alaudine_nt,site_web_ref)"
   pack $This.lab103 -in $This.frame8 -side top -fill x -pady 2

   label $This.labURL -text "$caption(alaudine_nt,site_alaudine_nt)" -fg $color(blue)
   pack $This.labURL -in $This.frame8 -side top -fill x -pady 2

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $This.labURL <ButtonPress-1> {
      set filename "$caption(alaudine_nt,site_alaudine_nt)"
      ::audace::Lance_Site_htm $filename
   }
   bind $This.labURL <Enter> {
      $::AlAudineNT::This.labURL configure -fg $color(purple)
   }
   bind $This.labURL <Leave> {
      $::AlAudineNT::This.labURL configure -fg $color(blue)
   }

   #--- Cree le bouton 'OK'
   button $This.frame2.ok -text "$caption(alaudine_nt,ok)" -width 7 \
      -command "::AlAudineNT::ok"
   if { $conf(ok+appliquer) == "1" } {
      pack $This.frame2.ok -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x
   }

   #--- Cree le bouton 'Appliquer'
   button $This.frame2.appliquer -text "$caption(alaudine_nt,appliquer)" -width 8 \
      -command "::AlAudineNT::appliquer"
   pack $This.frame2.appliquer -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x

   #--- Cree le bouton 'Fermer'
   button $This.frame2.fermer -text "$caption(alaudine_nt,fermer)" -width 7 \
      -command "::AlAudineNT::fermer"
   pack $This.frame2.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

   #--- Cree le bouton 'Aide'
   button $This.frame2.aide -text "$caption(alaudine_nt,aide)" -width 7 \
      -command "::AlAudineNT::afficherAide"
   pack $This.frame2.aide -in $This.frame2 -side right -padx 3 -pady 3 -ipady 5 -fill x

   #--- La fenetre est active
   focus $This

   #---
   if { [ info exists private(aftertemp) ] == "0" } {
      ::AlAudineNT::dispTempAlAudineNT
   }

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# widgetToConf
# Acquisition de la configuration, c'est a dire isolation des
# differentes variables dans le tableau conf(...)
#
proc ::AlAudineNT::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de l'AlAudine NT dans le tableau conf(alaudine_nt,...)
   set conf(alaudine_nt,evaluation)        $private(evaluation)
   set conf(alaudine_nt,delta_t_max)       $private(delta_t_max)
   set conf(alaudine_nt,temp_ccd_souhaite) $private(temp_ccd_souhaite)
}

#
# configureAlAudineNT
# Configure l'alimentation en fonction des donnees contenues dans le tableau conf :
# conf(alaudine_nt,...) -> proprietes de ce type de l'alimentation
#
proc ::AlAudineNT::configureAlAudineNT { } {
   variable This
   global conf

   #--- Temperatures minimale et maximale possibles
   set tmp_ccd_max $conf(alaudine_nt,evaluation)
   set tmp_ccd_min [ expr $conf(alaudine_nt,evaluation) - $conf(alaudine_nt,delta_t_max) ]
   #--- Configuration de la glissiere de reglage de la temperature
   $This.temp_ccd_souhaite_variant configure -from $tmp_ccd_min -to $tmp_ccd_max
}

#
# reglageTemp
# Fonction pour regler la temperature du CCD via l'AlAudine NT
#
proc ::AlAudineNT::reglageTemp { temp_ccd_souhaite } {
   set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]
   if { $camNo != "0" } {
      cam$camNo cooler check $temp_ccd_souhaite
   } else {
      return
   }
}

#
# dispTempAlAudineNT
# Fonction de mesure de la temperature reelle du CCD via l'AlAudine NT
#
proc ::AlAudineNT::dispTempAlAudineNT { } {
   variable private
   global caption

   #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
   set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]
   if { $camNo == "0" } {
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   } else {
      if { [ catch { set temp_ccd_mesure [ cam$camNo temperature ] } ] == "0" } {
         set temp_ccd_mesure [ format "%+5.1f" $temp_ccd_mesure ]
         set private(temp_ccd_mesure) "$caption(alaudine_nt,temp_ccd_mesure) $temp_ccd_mesure $caption(alaudine_nt,degres)"
         set private(aftertemp) [ after 5000 ::AlAudineNT::dispTempAlAudineNT ]
      } else {
         set private(temp_ccd_mesure) "$caption(alaudine_nt,temp_ccd_mesure)"
         if { [ info exists private(aftertemp) ] == "1" } {
            unset private(aftertemp)
         }
      }
   }
}

