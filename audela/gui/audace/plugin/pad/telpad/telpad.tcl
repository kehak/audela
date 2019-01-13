#
# Fichier : telpad.tcl
# Description : Raquette simplifiee a l'usage des montures et des telescopes
# Auteur : Robert DELMAS
# Mise à jour $Id: telpad.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::telpad {
   package provide telpad 1.0
   source [ file join [file dirname [info script]] telpad.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
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
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         display { return "window" }
      }
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le label du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(telpad,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "telpad.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "pad"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le repertoire du plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "telpad"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(telpad,geometry) ] }     { set conf(telpad,geometry)     "157x254+657+252" }
      if { ! [ info exists conf(telpad,focuserLabel) ] } { set conf(telpad,focuserLabel) "focuserlx200" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #
   #  return rien
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(focuserLabel) $conf(telpad,focuserLabel)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(telpad,focuserLabel) $widget(focuserLabel)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Frame pour le choix du focuser
      frame $frm.frame1 -borderwidth 0 -relief raised

         ::confEqt::createFrameFocuser $frm.frame1.focuser ::telpad::widget(focuserLabel)
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
   proc createPluginInstance { } {
      global conf

      #--- Creation du focuser
      if { $conf(telpad,focuserLabel) != "" } {
         ::$conf(telpad,focuserLabel)::createPlugin
      }

      #--- Affiche la raquette
      telpad::run

      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      variable This
      global conf

      #--- Ferme la raquette
      if { [ info exists This ] == 1 } {
         if { [ winfo exists $This ] == 1 } {
            set conf(telpad,geometry) [ wm geometry $This ]
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
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du plugin
   #==============================================================

   #------------------------------------------------------------
   #  run
   #     cree la fenetre de la raquette
   #------------------------------------------------------------
   proc run { } {
      variable This

      #--- Je cree la fenetre de la raquette
      set This ".telpad"
      createDialog

      #--- Je refraichis l'affichage des coordonnees
      ::telescope::afficheCoord
   }

   #------------------------------------------------------------
   #  moveRadec
   #     demarre un mouvement de la monture dans une direction
   #
   #  direction : direction du deplacement e w n s
   #------------------------------------------------------------
   proc moveRadec { direction } {
      variable This
      variable private
      global color

      set catchError [ catch {
         #--- Gestion des boutons
         if { $private(active) == 1 } {
            if { $direction == "n" } {
               $This.frame2.n.canv1 configure -bg $color(white) -fg $color(black)
            } elseif { $direction == "s" } {
               $This.frame2.s.canv1 configure -bg $color(white) -fg $color(black)
            } elseif { $direction == "w" } {
               $This.frame2.we.canv2 configure -bg $color(white) -fg $color(black)
            } elseif { $direction == "e" } {
               $This.frame2.we.canv1 configure -bg $color(white) -fg $color(black)
            }
         }
         #--- Debut du mouvement
         ::telescope::move $direction
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(telpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  stopRadec
   #     arrete le mouvement de la monture dans une direction
   #
   #  direction : direction du deplacement e w n s
   #------------------------------------------------------------
   proc stopRadec { direction } {
      variable This
      variable private
      global color

      #--- Fin de mouvement
      ::telescope::stop $direction
      #--- Gestion des boutons
      if { $private(active) == 1 } {
         if { $direction == "n" } {
            $This.frame2.n.canv1 configure -bg $color(gray_pad) -fg $color(white)
         } elseif { $direction == "s" } {
            $This.frame2.s.canv1 configure -bg $color(gray_pad) -fg $color(white)
         } elseif { $direction == "w" } {
            $This.frame2.we.canv2 configure -bg $color(gray_pad) -fg $color(white)
         } elseif { $direction == "e" } {
            $This.frame2.we.canv1 configure -bg $color(gray_pad) -fg $color(white)
         }
      }
   }

   #------------------------------------------------------------
   #  controleSuiviRadec
   #     met en marche ou arrete l'axe d'AD de la monture
   #------------------------------------------------------------
   proc controleSuiviRadec { } {
      set catchError [ catch {
         #--- Marche/Arret du moteur d'AD
         ::telescope::controleSuivi
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(telpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  incrementSpeedRadec
   #     gere les vitesses disponibles pour la monture
   #------------------------------------------------------------
   proc incrementSpeedRadec { } {
      set catchError [ catch {
         #--- Gestion des vitesses
         ::telescope::incrementSpeed
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(telpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  moveFocus
   #     demarre le mouvement du focuser
   #
   #  direction : direction du deplacement - +
   #------------------------------------------------------------
   proc moveFocus { direction } {
      set catchError [ catch {
         #--- Debut du mouvement
         ::focus::move $::conf(telpad,focuserLabel) $direction
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(telpad,titre)
      }
   }

   #------------------------------------------------------------
   #  stopFocus
   #     arrete le mouvement du focuser
   #------------------------------------------------------------
   proc stopFocus { } {
      #--- Fin de mouvement
      ::focus::move $::conf(telpad,focuserLabel) stop
   }

   #------------------------------------------------------------
   #  incrementSpeedFocus
   #     gere les vitesses disponibles du focuser
   #------------------------------------------------------------
   proc incrementSpeedFocus { } {
      set catchError [ catch {
         #--- Gestion des vitesses
         ::focus::incrementSpeed $::conf(telpad,focuserLabel) pad
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(telpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  setSpeedFocus
   #     envoie le numero de la vitesse selectionnee
   #
   #  rate : le numero de la vitesse selectionnee
   #------------------------------------------------------------
   proc setSpeedFocus { rate } {
      set catchError [ catch {
         #--- Envoie le numero de la vitesse selectionnee
         ::focus::setSpeed $::conf(telpad,focuserLabel) $rate
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(telpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  createDialog
   #     creation de l'interface graphique
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable private
      global audace caption color conf

      set private(active) 0

      if { [ winfo exists $This ] } {
         destroy $This
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class toplevel -bg $color(blue_pad)
      wm title $This $caption(telpad,titre)
      if { [ info exists conf(telpad,geometry) ] == "1" } {
         wm geometry $This $conf(telpad,geometry)
      } else {
         wm geometry $This 170x320+647+240
      }
      wm resizable $This 1 1
      wm protocol $This WM_DELETE_WINDOW ::telpad::deletePluginInstance

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame2 -side top -fill both -expand 1

      frame $This.frame3 -borderwidth 1 -relief groove -bg $color(blue_pad)
      pack $This.frame3 -side top -fill both -expand 1

      #--- Label pour RA
      label $This.frame1.ent1 -textvariable audace(telescope,getra) \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame1.ent1 -anchor center -fill none -pady 1

      #--- Label pour DEC
      label $This.frame1.ent2 -textvariable audace(telescope,getdec) \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame1.ent2 -anchor center -fill none -pady 1

      set zone(radec) $This.frame1
      bind $zone(radec) <ButtonPress-1>      { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      #--- Create the button 'N'
      frame $This.frame2.n -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame2.n -side top -fill x

      #--- Button-design 'N'
      button $This.frame2.n.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(telpad,nord)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.frame2.n.canv1 -expand 0 -side top -padx 10 -pady 4

      #--- Create the buttons 'E W'
      frame $This.frame2.we -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame2.we -side top -fill x

      #--- Button-design 'E'
      button $This.frame2.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(telpad,est)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.frame2.we.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed
      label $This.frame2.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
         -bg $color(blue_pad) -fg $color(white) -borderwidth 0 -relief flat
      pack $This.frame2.we.lab -expand 1 -side left

      #--- Button-design 'W'
      button $This.frame2.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(telpad,ouest)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.frame2.we.canv2 -expand 0 -side right -padx 10 -pady 4

      #--- Create the button 'S'
      frame $This.frame2.s -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame2.s -side top -fill x

      #--- Button-design 'S'
      button $This.frame2.s.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "$caption(telpad,sud)" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.frame2.s.canv1 -expand 0 -side top -padx 10 -pady 4

      set zone(n) $This.frame2.n.canv1
      set zone(e) $This.frame2.we.canv1
      set zone(w) $This.frame2.we.canv2
      set zone(s) $This.frame2.s.canv1

      #--- Frame du checkbutton pour activer / desactiver les fleches du clavier
      frame $This.frame2.frameCheck -borderwidth 0 -relief raise -bg $color(blue_pad)
      pack $This.frame2.frameCheck -expand 0 -side bottom -padx 10 -pady 4

      checkbutton $This.frame2.frameCheck.active -borderwidth 1 \
         -variable ::telpad::private(active) \
         -bg $color(blue_pad) -fg $color(white) \
         -activebackground $color(blue_pad) -activeforeground $color(white) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -font [ list {Arial} 10 bold ] \
         -text $caption(telpad,activeFleches) \
         -command "::telpad::activeFlechesClavier"
      pack $This.frame2.frameCheck.active -anchor center -fill none -pady 2

      #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
      if { [ ::confTel::getPluginProperty hasControlSuivi ] == "1" } {
         label $This.frame2.s.lab1 -textvariable audace(telescope,controle) -borderwidth 0 -relief flat \
            -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
         pack $This.frame2.s.lab1 -expand 1 -side left
         bind $This.frame2.s.lab1 <ButtonPress-1> { ::telpad::controleSuiviRadec }
      }

      #--- Binding de la vitesse de la monture
      bind $This.frame2.we.lab <ButtonPress-1> { ::telpad::incrementSpeedRadec }

      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1>   { ::telpad::moveRadec e }
      bind $zone(e) <ButtonRelease-1> { ::telpad::stopRadec e }
      bind $zone(w) <ButtonPress-1>   { ::telpad::moveRadec w }
      bind $zone(w) <ButtonRelease-1> { ::telpad::stopRadec w }
      bind $zone(s) <ButtonPress-1>   { ::telpad::moveRadec s }
      bind $zone(s) <ButtonRelease-1> { ::telpad::stopRadec s }
      bind $zone(n) <ButtonPress-1>   { ::telpad::moveRadec n }
      bind $zone(n) <ButtonRelease-1> { ::telpad::stopRadec n }

      #--- Label pour moteur focus
      label $This.frame3.lab1 -text $caption(telpad,moteur_foc) -relief flat \
         -fg $color(white) -bg $color(blue_pad) -font [ list {Arial} 10 bold ]
      pack $This.frame3.lab1 -anchor center -fill none -padx 4 -pady 1

      #--- Create the buttons '- +'
      frame $This.frame3.we -width 27 -borderwidth 0 -relief flat -bg $color(blue_pad)
      pack $This.frame3.we -side top -fill x

      #--- Button '-'
      button $This.frame3.we.canv1 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "-" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv1 -expand 0 -side left -padx 10 -pady 4

      #--- Write the label of speed for LX200 and compatibles
      label $This.frame3.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(focus,labelspeed) \
         -bg $color(blue_pad) -fg $color(white) -width 2 -borderwidth 0 -relief flat
      pack $This.frame3.we.lab -expand 1 -side left

      #--- Button '+'
      button $This.frame3.we.canv2 -borderwidth 2 \
         -font [ list {Arial} 12 bold ] \
         -fg $color(white) \
         -bg $color(gray_pad) \
         -text "+" \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $This.frame3.we.canv2 -expand 0 -side right -padx 10 -pady 4

      set zone(moins) $This.frame3.we.canv1
      set zone(plus)  $This.frame3.we.canv2

      #--- Binding de la vitesse du moteur de focalisation
      bind $This.frame3.we.lab <ButtonPress-1> { ::telpad::incrementSpeedFocus }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { ::telpad::moveFocus - }
      bind $zone(moins) <ButtonRelease-1> { ::telpad::stopFocus }
      bind $zone(plus)  <ButtonPress-1>   { ::telpad::moveFocus + }
      bind $zone(plus)  <ButtonRelease-1> { ::telpad::stopFocus }

      #--- Initialise et affiche la vitesse du focuser
      ::telpad::setSpeedFocus 0

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
   }

   #------------------------------------------------------------
   #  activeFlechesClavier
   #     active les fleches du clavier
   #------------------------------------------------------------
   proc activeFlechesClavier { } {
      variable private

      if { $private(active) == 1 } {
         #--- bind Cardinal sur les 4 fleches du clavier
         #--- ne fonctionne que si la raquette TelPad a le focus
         bind .telpad <KeyPress-Left>    { ::telpad::moveRadec e }
         bind .telpad <KeyRelease-Left>  { ::telpad::stopRadec e }
         bind .telpad <KeyPress-Right>   { ::telpad::moveRadec w }
         bind .telpad <KeyRelease-Right> { ::telpad::stopRadec w }
         bind .telpad <KeyPress-Down>    { ::telpad::moveRadec s }
         bind .telpad <KeyRelease-Down>  { ::telpad::stopRadec s }
         bind .telpad <KeyPress-Up>      { ::telpad::moveRadec n }
         bind .telpad <KeyRelease-Up>    { ::telpad::stopRadec n }
      } else {
         bind .telpad <KeyPress-Left>    { }
         bind .telpad <KeyRelease-Left>  { }
         bind .telpad <KeyPress-Right>   { }
         bind .telpad <KeyRelease-Right> { }
         bind .telpad <KeyPress-Down>    { }
         bind .telpad <KeyRelease-Down>  { }
         bind .telpad <KeyPress-Up>      { }
         bind .telpad <KeyRelease-Up>    { }
      }
   }
}

