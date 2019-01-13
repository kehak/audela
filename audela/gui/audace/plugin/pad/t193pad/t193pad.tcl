#
# Fichier : t193pad.tcl
# Description : Raquette specifique au T193 de l'OHP
# Auteur : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: t193pad.tcl 12358 2015-12-13 07:42:19Z robertdelmas $
#

namespace eval ::t193pad {
   package provide t193pad 1.0
   source [ file join [file dirname [info script]] t193pad.cap ]
}

#------------------------------------------------------------
#  initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::t193pad::initPlugin { } {
   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf
   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete, ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::t193pad::getPluginProperty { propertyName } {
   switch $propertyName {
      display { return "window" }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::t193pad::getPluginTitle { } {
   global caption

   return "$caption(t193pad,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::t193pad::getPluginHelp { } {
   return "t193pad.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::t193pad::getPluginType { } {
   return "pad"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le repertoire du plugin
#------------------------------------------------------------
proc ::t193pad::getPluginDirectory { } {
   return "t193pad"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::t193pad::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::initConf { } {
   global conf

   if { ! [ info exists conf(t193pad,wmgeometry) ] }         { set conf(t193pad,wmgeometry)         "240x520+643+180" }
   if { ! [ info exists conf(t193pad,focuserLabel) ] }       { set conf(t193pad,focuserLabel)       "" }
   if { ! [ info exists conf(t193pad,radecPulse,enabled) ] } { set conf(t193pad,radecPulse,enabled) 0 }
   if { ! [ info exists conf(t193pad,radecPulse,value) ] }   { set conf(t193pad,radecPulse,value)   1 }

   set private(targetRa)     "00h00m00.00s"
   set private(targetDec)    "+00d00m00.00s"
   set private(positionDome) "0"
   set private(synchro)      "1"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::confToWidget { } {
   variable widget
   global conf

   set widget(focuserLabel) $conf(t193pad,focuserLabel)
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::widgetToConf { } {
   variable widget
   global conf

   set conf(t193pad,focuserLabel) $widget(focuserLabel)
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::t193pad::fillConfigPage { frm } {
   variable widget

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame pour le choix du focuser
   frame $frm.frame1 -borderwidth 0 -relief raised

      ::confEqt::createFrameFocuser $frm.frame1.focuser ::t193pad::widget(focuserLabel)
      pack $frm.frame1.focuser -anchor nw -side left -padx 10 -pady 10

   pack $frm.frame1 -side top -fill both -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  createPluginInstance
#     cree une instance du plugin
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::createPluginInstance { } {
   global conf

   #--- Creation du focuser
   if { $conf(t193pad,focuserLabel) != "" } {
      ::$conf(t193pad,focuserLabel)::createPlugin
   }

   #--- Affiche la raquette
   t193pad::run

   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#
#  return rien
#------------------------------------------------------------
proc ::t193pad::deletePluginInstance { } {
   variable This
   global conf

   #--- Ferme la raquette
   if { [ info exists This ] == 1 } {
      if { [ winfo exists $This ] == 1 } {
         set conf(t193pad,wmgeometry) [ wm geometry $This ]
         destroy $This
      }
   }
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::t193pad::isReady { } {
   return 0
}

#==============================================================
# Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  run
#     cree la fenetre de la raquette
#------------------------------------------------------------
proc ::t193pad::run { } {
   variable This

   #--- Je cree la fenetre de la raquette
   set This ".t193pad"
   createDialog

   #--- Je refraichis l'affichage des coordonnees
   ::telescope::afficheCoord
}

#------------------------------------------------------------
#  createDialog
#     creation de l'interface graphique
#------------------------------------------------------------
proc ::t193pad::createDialog { } {
   variable This
   variable private
   global audace caption color conf

   if { [ winfo exists $This ] } {
      destroy $This
   }

   #--- Cree la fenetre This de niveau le plus haut
   toplevel $This -class toplevel -bg $color(blue_pad)
   wm title $This $caption(t193pad,titre)
   if { [ info exists conf(t193pad,wmgeometry) ] == "1" } {
      wm geometry $This $conf(t193pad,wmgeometry)
   } else {
      wm geometry $This 240x520+643+180
   }
   wm resizable $This 1 1
   wm minsize $This 235 310
   wm protocol $This WM_DELETE_WINDOW ::t193pad::deletePluginInstance

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief groove -bg $color(blue_pad)
   pack $This.frame1 -side top -fill x -expand 0

   frame $This.frame2 -borderwidth 1 -relief groove -bg $color(blue_pad)
   pack $This.frame2 -side top -fill x -expand 0

   frame $This.frame3 -borderwidth 1 -relief groove -bg $color(blue_pad)
   pack $This.frame3 -side top -fill x -expand 0

   #--- Label pour AD
   label $This.frame1.ent1 -textvariable audace(telescope,getra) \
      -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
   pack $This.frame1.ent1 -anchor center -fill none -pady 1

   #--- Label pour DEC
   label $This.frame1.ent2 -textvariable audace(telescope,getdec) \
      -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
   pack $This.frame1.ent2 -anchor center -fill none -pady 1

   #--- Bind de l'affichage des coordonnees
   bind $This.frame1      <ButtonPress-1> { ::telescope::afficheCoord }
   bind $This.frame1.ent1 <ButtonPress-1> { ::telescope::afficheCoord }
   bind $This.frame1.ent2 <ButtonPress-1> { ::telescope::afficheCoord }

   #         0     1      2
   #    0          N     monocoup
   #    1    E   speed    W
   #    2          S

   #--- Bouton 'NE'
   button $This.frame2.nordest -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) \
      -bg $color(gray_pad) \
      -text "$caption(t193pad,nord)$caption(t193pad,est)" \
      -anchor center \
      -relief ridge
   grid $This.frame2.nordest  -row 0 -column 0 -padx 10 -pady 10

   #--- Bouton 'N'
   button $This.frame2.nord -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) \
      -bg $color(gray_pad) \
      -text $caption(t193pad,nord) \
      -anchor center \
      -relief ridge
   grid $This.frame2.nord  -row 0 -column 1 -padx 10 -pady 10

   #--- Bouton 'NO'
   button $This.frame2.nordouest -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) \
      -bg $color(gray_pad) \
      -text "$caption(t193pad,nord)$caption(t193pad,ouest)" \
      -anchor center \
      -relief ridge
   grid $This.frame2.nordouest  -row 0 -column 2 -padx 10 -pady 10

   #--- Bouton 'E'
   button $This.frame2.est -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) -bg $color(gray_pad) \
      -text "$caption(t193pad,est)" \
      -anchor center \
      -relief ridge
   grid $This.frame2.est  -row 1 -column 0 -padx 10 -pady 0

   #--- Label de la vitesse de la monture
   label $This.frame2.vitesseMonture -font [ list {Arial} 12 bold ] \
      -bg $color(gray_pad) -fg $color(white) \
      -font [ list {Arial} 12 bold ] \
      -borderwidth 2 -width 3 -relief ridge \
      -textvariable audace(telescope,labelspeed)
   grid $This.frame2.vitesseMonture  -row 1 -column 1 -padx 10 -pady 0

   #--- Bouton 'O'
   button $This.frame2.ouest -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) -bg $color(gray_pad) \
      -text $caption(t193pad,ouest) \
      -anchor center \
      -relief ridge
   grid $This.frame2.ouest  -row 1 -column 2 -padx 10 -pady 0

   #--- Bouton 'SE'
   button $This.frame2.sudest -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) -bg $color(gray_pad) \
      -text "$caption(t193pad,sud)$caption(t193pad,est)" \
      -anchor center \
      -relief ridge
   grid $This.frame2.sudest -row 2 -column 0 -padx 10 -pady 10

   #--- Bouton 'S'
   button $This.frame2.sud -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) -bg $color(gray_pad) \
      -text $caption(t193pad,sud) \
      -anchor center \
      -relief ridge
   grid $This.frame2.sud -row 2 -column 1 -padx 10 -pady 10

   #--- Bouton 'SO'
   button $This.frame2.sudouest -borderwidth 2 \
      -font [ list {Arial} 16 bold ] -width 4 \
      -fg $color(white) -bg $color(gray_pad) \
      -text "$caption(t193pad,sud)$caption(t193pad,ouest)" \
      -anchor center \
      -relief ridge
   grid $This.frame2.sudouest -row 2 -column 2 -padx 10 -pady 10

   #--- activation / desactivation mode impulsion des deplacements radec (monocoup)
   frame $This.frame2.pulseMode  -borderwidth 0 -bg $color(blue_pad)
      checkbutton $This.frame2.pulseMode.enabled \
         -font [ list {Arial} 12 bold ] \
         -bg $color(blue_pad) -fg $color(white) \
         -activebackground $color(blue_pad) -activeforeground $color(white) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -text $caption(t193pad,radecPulse) \
         -variable ::conf(t193pad,radecPulse,enabled) \
         -command ::t193pad::setRadecPulseEnabled
      pack $This.frame2.pulseMode.enabled -side left
      label $This.frame2.pulseMode.value  -bg $color(gray_pad)  -fg $color(white) \
         -font [ list {Arial} 12 bold ] \
         -borderwidth 2 -width 3 -relief ridge \
         -textvariable ::conf(t193pad,radecPulse,value)
      pack $This.frame2.pulseMode.value -side left -padx 4
      label $This.frame2.pulseMode.unit  -bg $color(blue_pad)   -fg $color(white)\
         -font [ list {Arial} 12 bold ] \
         -text "arcsec"
      pack $This.frame2.pulseMode.unit -side left -padx 2
   grid $This.frame2.pulseMode  -row 3 -column 0 -columnspan 3 -padx 10 -pady 4

   grid columnconfigure $This.frame2 0 -weight 1
   grid columnconfigure $This.frame2 1 -weight 1
   grid columnconfigure $This.frame2 2 -weight 1

   #--- Bind de la vitesse de la monture
   #bind $This.frame2.vitesseMonture <ButtonPress-1> { ::telescope::incrementSpeed } avant Robert Delmas
   bind $This.frame2.vitesseMonture <ButtonPress-1> { ::t193pad::incrementSpeedRadec }
   #--- Bind valeur impulsion monocoup
   bind $This.frame2.pulseMode.value <ButtonPress-1> { ::t193pad::incrementRadecPulse }

   #--- LabelEntry pour AD
   LabelEntry $This.frame3.ad -label $caption(t193pad,RA) \
      -textvariable ::t193pad::private(targetRa) -width 14 -fg $color(white) \
      -bg $color(blue_pad) -entrybg $color(gray_pad) -justify center \
      -labelwidth 5 \
      -labelfont [ list {Arial} 10 bold ] -font [ list {Arial} 12 bold ]
   pack $This.frame3.ad -anchor center -fill none -pady 2

   #--- LabelEntry pour DEC
   LabelEntry $This.frame3.dec -label $caption(t193pad,DEC) \
      -textvariable ::t193pad::private(targetDec) -width 14 -fg $color(white) \
      -bg $color(blue_pad) -entrybg $color(gray_pad) -justify center \
      -labelwidth 5 \
      -labelfont [ list {Arial} 10 bold ] -font [ list {Arial} 12 bold ]
   pack $This.frame3.dec -anchor center -fill none -pady 2

   #--- Bouton GOTO start
   button $This.frame3.buttonGoto -borderwidth 1 -width 8 \
      -font [ list {Arial} 12 bold ] -text $caption(t193pad,goto) -relief ridge \
      -fg $color(white) -bg $color(gray_pad) -command "::t193pad::cmdStartGoto"
   pack $This.frame3.buttonGoto -anchor center -fill x -expand 1 -side left -padx 4 -pady 2

   #--- Bouton GOTO stop
   button $This.frame3.buttonStopGoto -borderwidth 1 -width 8 \
      -font [ list {Arial} 12 bold ] -text $caption(t193pad,stopGoto) -relief ridge \
      -fg $color(white) -bg $color(gray_pad) -command "::telescope::stopGoto"
   pack $This.frame3.buttonStopGoto -anchor center -fill x -expand 1  -side left -padx 4 -pady 2

   #--- Frame du FOCUS
   frame $This.focus -borderwidth 1 -relief groove -bg $color(blue_pad)
      #--- Titre pour le moteur de focalisation
      label $This.focus.titre -text $caption(t193pad,moteur_foc) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
      pack $This.focus.titre -anchor center -fill none -padx 4 -pady 1

      #--- Frame pour les boutons '-' et '+' du FOCUS
      frame $This.focus.pm -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
         #--- Bouton '-'
         button $This.focus.pm.buttonMoins -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -fg $color(white) \
            -bg $color(gray_pad) \
            -text "-" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.focus.pm.buttonMoins -expand 0 -side left -padx 10 -pady 4

         #--- Label pour la position de la focalisation courante
         label $This.focus.pm.positionFoc -textvariable ::audace(focus,currentFocus) \
            -bg $color(blue_pad) -fg $color(white) -font [ list {Arial} 12 bold ] -width 10 \
            -borderwidth 0 -relief flat
         pack $This.focus.pm.positionFoc -expand 1 -side left

         #--- Bouton '+'
         button $This.focus.pm.buttonPlus -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -fg $color(white) \
            -bg $color(gray_pad) \
            -text "+" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.focus.pm.buttonPlus -expand 0 -side right -padx 10 -pady 4

         #--- Bind des boutons '+' et '-'
         bind $This.focus.pm.buttonMoins <ButtonPress-1>   { ::t193pad::moveFocus "-" }
         bind $This.focus.pm.buttonMoins <ButtonRelease-1> { ::t193pad::stopFocus }
         bind $This.focus.pm.buttonPlus  <ButtonPress-1>   { ::t193pad::moveFocus "+" }
         bind $This.focus.pm.buttonPlus  <ButtonRelease-1> { ::t193pad::stopFocus }

         #--- Label de la vitesse du moteur de focalisation
         ### label $This.focus.vitesseFocus -font [ list {Arial} 12 bold ] \
         ###    -textvariable audace(focus,labelspeed) -bg $color(blue_pad) -fg $color(white) \
         ###    -width 2 -borderwidth 0 -relief flat
         ### pack $This.focus.vitesseFocus -anchor center -fill none -pady 2

         #--- Bind de la vitesse du moteur de focalisation
         ### bind $This.focus.vitesseFocus <ButtonPress-1> { ::focus::incrementSpeed $::conf(t193pad,focuserLabel) pad }

      pack $This.focus.pm -side top -fill x

      #--- Frame pour le GOTO du focuser
      frame $This.focus.goto -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)

         #--- Bouton du GOTO du focuser
         button $This.focus.goto.buttonGotoFoc -borderwidth 1 -width 8 \
            -font [ list {Arial} 12 bold ] -text $caption(t193pad,gotoFoc) -relief ridge \
            -fg $color(white) -bg $color(gray_pad) -command "::t193pad::gotoFocus"
         pack $This.focus.goto.buttonGotoFoc -anchor center -fill x -side left -padx 4 -pady 2 -expand 1

         #--- Entry pour la position du GOTO du focuser
         Entry $This.focus.goto.positionGotoFoc -textvariable ::audace(focus,targetFocus) \
            -width 6 -bg $color(gray_pad) -justify center -font [ list {Arial} 12 bold ]
         pack $This.focus.goto.positionGotoFoc -anchor center -fill x -side left -padx 4 -pady 2 -expand 1

         #--- Bouton du STOP GOTO du focuser
         button $This.focus.goto.buttonStopFoc -borderwidth 1 -width 8 \
         -font [ list {Arial} 12 bold ] -text $caption(t193pad,stopFoc) -relief ridge \
         -fg $color(white) -bg $color(gray_pad) -command ::t193pad::stopFocus
         pack $This.focus.goto.buttonStopFoc -anchor center -fill x -side left -padx 4 -pady 2 -expand 1

      pack $This.focus.goto -side top -fill x -expand 1

   pack $This.focus -side top -fill x -expand 0 -pady 4

   #--- Recuperation de la position courante du focuser
   set catchError [catch {
      ::focus::displayCurrentPosition $conf(t193pad,focuserLabel)
   }]
   if { $catchError != 0 } {
      ::console::affiche_erreur "$caption(t193pad,msg)\n"
   }

   #--- Frame du DOME
   frame $This.dome -borderwidth 1 -relief groove -bg $color(blue_pad)
      #--- titre pour le dome
      label $This.dome.titre -text $caption(t193pad,dome) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 12 bold ]
      pack $This.dome.titre -anchor center -fill none -padx 4 -pady 1

      #--- Frame pour les boutons '-' et '+'
      frame $This.dome.pm -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.dome.pm -side top -fill x

      #--- Bouton '-'
      button $This.dome.pm.buttonMoins -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "-" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.dome.pm.buttonMoins -expand 0 -side left -padx 10 -pady 4

      #--- Label pour la position du dome
      label $This.dome.pm.positionDome -textvariable ::t193pad::private(positionDome) \
         -bg $color(blue_pad) -fg $color(white) -font [ list {Arial} 12 bold ] -width 10 \
         -borderwidth 0 -relief flat
      pack $This.dome.pm.positionDome -expand 1 -side left

      #--- Bouton '+'
      button $This.dome.pm.buttonPlus -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "+" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.dome.pm.buttonPlus -expand 0 -side right -padx 10 -pady 4

      #--- Checkbutton pour la synchronisation du dome sur la monture
      checkbutton $This.dome.check -text "$caption(t193pad,synchroMonture)" \
         -variable ::t193pad::private(synchro) -bg $color(blue_pad) -fg $color(white) \
         -activebackground $color(blue_pad) -activeforeground $color(white) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -font [ list {Arial} 12 bold ] -command "  "
      pack $This.dome.check -anchor center -fill none -pady 2

   pack $This.dome -side top -fill x -expand 0

   #--- Initialise et affiche la vitesse du focuser
   ::focus::setSpeed $conf(t193pad,focuserLabel) "0"

   #--- active ou descative le choix de l'impulsion
   setRadecPulseEnabled

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- je recupere la position du focuser
   set ::audace(focus,currentFocus) [::focus::getPosition $conf(t193pad,focuserLabel)]
   set ::audace(focus,targetFocus)  $::audace(focus,currentFocus)
}

#------------------------------------------------------------
# moveRadec
#   demarre un mouvement
# @param direction  direction du deplacement e w n s
# @return void
#------------------------------------------------------------
proc ::t193pad::moveRadec { direction } {
   set catchError [catch {
      #--- debut de mouvement
      ::telescope::move $direction
   }]

   if { $catchError != 0 } {
      #--- je fais un beep sonore pour signaler que la commande n'est pas prise en compte
      bell
   }

}

#------------------------------------------------------------
# stopRadec
#   arrete le mouvement dans une direction
#
# @param direction  direction du deplacement e w n s
# @return void
#------------------------------------------------------------
proc ::t193pad::stopRadec { direction } {
   #--- fin de mouvement
   ::telescope::stop $direction
}

#------------------------------------------------------------
# moveRadecPulse
#
# @param direction  direction du deplacement e w n s
# @return void
#------------------------------------------------------------
proc ::t193pad::moveRadecPulse { direction } {
   set catchError [catch {
      #--- mouvement d'amplitude limite
      switch  $direction {
         "e" -
         "w" {
            #--- en alpha
            tel$::audace(telNo) radec correct $direction $::conf(t193pad,radecPulse,value) "n" 0 $::audace(telescope,rate)
         }
         "n" -
         "s" {
            #--- en delta
            tel$::audace(telNo) radec correct "e" 0 $direction $::conf(t193pad,radecPulse,value) $::audace(telescope,rate)
         }
      }
   }]

   if { $catchError != 0 } {
      #--- je fais un beep sonore pour signaler que la commande n'est pas prise en compte
      #--- quand le telescope est deja en mouvement
      bell
   }
}

#------------------------------------------------------------
#  setRadecPulseEnabled
#     active le choix de la valeur de l'impulsion
#------------------------------------------------------------
proc ::t193pad::setRadecPulseEnabled { } {
   variable This

   if { $::conf(t193pad,radecPulse,enabled) == 0 } {
      #--- je descative acces au choix de la duree de l'impulsion
      $This.frame2.pulseMode.value configure -state disabled
      $This.frame2.pulseMode.unit  configure -state disabled

      #--- Bind des boutons 'N', 'E', 'O' et 'S'
      bind $This.frame2.est <ButtonPress-1>     { ::t193pad::moveRadec e }
      bind $This.frame2.est <ButtonRelease-1>   { ::t193pad::stopRadec e }
      bind $This.frame2.ouest <ButtonPress-1>   { ::t193pad::moveRadec w }
      bind $This.frame2.ouest <ButtonRelease-1> { ::t193pad::stopRadec w }
      bind $This.frame2.sud <ButtonPress-1>         { ::t193pad::moveRadec s }
      bind $This.frame2.sud <ButtonRelease-1>       { ::t193pad::stopRadec s }
      bind $This.frame2.sudest <ButtonPress-1>      { ::t193pad::moveRadec s ; ::t193pad::moveRadec e }
      bind $This.frame2.sudest <ButtonRelease-1>    { ::t193pad::stopRadec s ; ::t193pad::stopRadec e }
      bind $This.frame2.sudouest <ButtonPress-1>    { ::t193pad::moveRadec s ; ::t193pad::moveRadec w }
      bind $This.frame2.sudouest <ButtonRelease-1>  { ::t193pad::stopRadec s ; ::t193pad::stopRadec w }
      bind $This.frame2.nord <ButtonPress-1>        { ::t193pad::moveRadec n }
      bind $This.frame2.nord <ButtonRelease-1>      { ::t193pad::stopRadec n }
      bind $This.frame2.nordest <ButtonPress-1>     { ::t193pad::moveRadec n ; ::t193pad::moveRadec e }
      bind $This.frame2.nordest <ButtonRelease-1>   { ::t193pad::stopRadec n ; ::t193pad::stopRadec e }
      bind $This.frame2.nordouest <ButtonPress-1>   { ::t193pad::moveRadec n ; ::t193pad::moveRadec w }
      bind $This.frame2.nordouest <ButtonRelease-1> { ::t193pad::stopRadec n ; ::t193pad::stopRadec w }

      $This.frame2.est   configure -command ""
      $This.frame2.ouest configure -command ""
      $This.frame2.sud   configure -command ""
      $This.frame2.sudest   configure -command ""
      $This.frame2.sudouest   configure -command ""
      $This.frame2.nord  configure -command ""
      $This.frame2.nordest  configure -command ""
      $This.frame2.nordouest  configure -command ""

   } else {
      #--- je donne acces au choix de la duree de l'impulsion
      $This.frame2.pulseMode.value configure -state normal
      $This.frame2.pulseMode.unit  configure -state normal

      #--- Bind des boutons 'N', 'E', 'O' et 'S'
      #--- Il ne faut pas utiliser les evenements ButtonPress-1 et ButtonRelease-1
      #--- car la couleur des boutons n'est pas correctement gérée quand on
      #--- relache le bouton après très courte commande.
      #--- Il vaut mieux utiliser l'option "-command" qui gère bien la restauration
      #--- de la couleur du bouton.
      bind $This.frame2.est <ButtonPress-1>     ""
      bind $This.frame2.est <ButtonRelease-1>   ""
      bind $This.frame2.ouest <ButtonPress-1>   ""
      bind $This.frame2.ouest <ButtonRelease-1> ""
      bind $This.frame2.sud <ButtonPress-1>     ""
      bind $This.frame2.sud <ButtonRelease-1>   ""
      bind $This.frame2.sudest <ButtonPress-1>     ""
      bind $This.frame2.sudest <ButtonRelease-1>   ""
      bind $This.frame2.sudouest <ButtonPress-1>     ""
      bind $This.frame2.sudouest <ButtonRelease-1>   ""
      bind $This.frame2.nord <ButtonPress-1>    ""
      bind $This.frame2.nord <ButtonRelease-1>  ""
      bind $This.frame2.nordest <ButtonPress-1>    ""
      bind $This.frame2.nordest <ButtonRelease-1>  ""
      bind $This.frame2.nordouest <ButtonPress-1>    ""
      bind $This.frame2.nordouest <ButtonRelease-1>  ""

      $This.frame2.est   configure -command "::t193pad::moveRadecPulse e"
      $This.frame2.ouest configure -command "::t193pad::moveRadecPulse w"
      $This.frame2.sud        configure -command "::t193pad::moveRadecPulse s"
      $This.frame2.sudest     configure -command "::t193pad::moveRadecPulse s ; ::t193pad::moveRadecPulse e"
      $This.frame2.sudouest   configure -command "::t193pad::moveRadecPulse s ; ::t193pad::moveRadecPulse w"
      $This.frame2.nord       configure -command "::t193pad::moveRadecPulse n"
      $This.frame2.nordest    configure -command "::t193pad::moveRadecPulse n ; ::t193pad::moveRadecPulse e"
      $This.frame2.nordouest  configure -command "::t193pad::moveRadecPulse n ; ::t193pad::moveRadecPulse w"
   }
}

#------------------------------------------------------------
#  incrementSpeedRadec
#     gere les vitesses disponibles pour la monture
#------------------------------------------------------------
proc ::t193pad::incrementSpeedRadec { } {
   set catchError [ catch {
      #--- Gestion des vitesses
      ::telescope::incrementSpeed
   } ]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
      #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
      bell
   }
}

#------------------------------------------------------------
#  incrementRadecPulse
#     change la velur de l'impulsion radec
#------------------------------------------------------------
proc ::t193pad::incrementRadecPulse { } {
   if { $::conf(t193pad,radecPulse,enabled) == 1 } {
      switch $::conf(t193pad,radecPulse,value) {
         "0.1" {
            set ::conf(t193pad,radecPulse,value) "0.5"
         }
         "0.5" {
            set ::conf(t193pad,radecPulse,value) "1"
         }
         default {
            set ::conf(t193pad,radecPulse,value) "0.1"
         }
      }
   }
}

#------------------------------------------------------------
#  cmdStartGoto
#     pointe l'objet cible
#------------------------------------------------------------
proc ::t193pad::cmdStartGoto { } {
   variable This
   variable private

   set catchError [catch {
      ::telescope::goto [ list $private(targetRa) $private(targetDec) ] 0 $This.frame3.buttonGoto
   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
      #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
      bell
   }
}

#------------------------------------------------------------
#  moveFocus
#     demarre le mouvement du focus du T193
#------------------------------------------------------------
proc ::t193pad::moveFocus { direction } {
   set catchError [catch {
      ::focus::move $::conf(t193pad,focuserLabel) $direction

   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

#------------------------------------------------------------
#  stopFocus
#     arrete le mouvement du focus du T193
#------------------------------------------------------------
proc ::t193pad::stopFocus { } {
   set catchError [catch {
      ::focus::move $::conf(t193pad,focuserLabel) stop
   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

#------------------------------------------------------------
#  gotoFocus
#     lance un goto du focus
#------------------------------------------------------------
proc ::t193pad::gotoFocus { } {
   variable This
   set catchError [catch {
      set blocking 0
      ::focus::goto $::conf(t193pad,focuserLabel) $blocking $This.focus.goto.buttonGotoFoc
   }]

   if { $catchError != 0 } {
      ::tkutil::displayErrorInfo $::caption(t193pad,titre)
   }
}

