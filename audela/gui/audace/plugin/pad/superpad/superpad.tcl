#
# Fichier : superpad.tcl
# Description : Super raquette virtuelle
# Auteur : Michel PUJOL
# Mise à jour $Id: superpad.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

package provide superpad 1.0

namespace eval ::superpad {
   source [ file join [file dirname [info script]] superpad.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
      #--- cree les variables dans conf(..) si elles n'existent pas
      initConf
      #--- j'initialise les variables widget(..)
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

      return "$caption(superpad,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "superpad.htm"
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
      return "superpad"
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

      if { ! [ info exists conf(superpad,padsize) ] }      { set conf(superpad,padsize)      "0.5" }
      if { ! [ info exists conf(superpad,centerspeed) ] }  { set conf(superpad,centerspeed)  "140" }
      if { ! [ info exists conf(superpad,focuserLabel) ] } { set conf(superpad,focuserLabel) "focuserlx200" }
      if { ! [ info exists conf(superpad,position) ] }     { set conf(superpad,position)     "+100+100" }

      #--- Verifie que le caractere "+" existe bien au debut
      if { [ info exists conf(superpad,position) ] } {
         set first [ string range $conf(superpad,position) 0 0 ]
         if { $first != "+" } {
            set conf(superpad,position) "+$conf(superpad,position)"
         }
      }

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

      set widget(padsize)      $conf(superpad,padsize)
      set widget(centerspeed)  $conf(superpad,centerspeed)
      set widget(focuserLabel) $conf(superpad,focuserLabel)
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

      set conf(superpad,padsize)      $widget(padsize)
      set conf(superpad,centerspeed)  $widget(centerspeed)
      set conf(superpad,focuserLabel) $widget(focuserLabel)
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

      #--- Frame de la taille de la raquette
      frame $frm.frame1 -borderwidth 0 -relief raised

         #--- Label de la taille de la raquette
         label $frm.frame1.labSize -text "$caption(superpad,pad_size)"
         pack $frm.frame1.labSize -anchor center -side left -padx 10 -pady 10

         #--- Definition de la taille de la raquette
         set list_combobox [ list 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
         ComboBox $frm.frame1.taille \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [llength $list_combobox ] \
            -relief sunken           \
            -borderwidth 1           \
            -editable 0              \
            -textvariable ::superpad::widget(padsize) \
            -values $list_combobox
         pack $frm.frame1.taille -anchor nw -side left -padx 10 -pady 10

      pack $frm.frame1 -side top -fill both -expand 0

      #--- Frame pour centerspeed
      frame $frm.frame2 -borderwidth 0 -relief raised

         #--- Definition centerspeed
         label $frm.frame2.labcenterspeed -text "$caption(superpad,center_speed)"
         pack $frm.frame2.labcenterspeed -anchor nw -side left -padx 10 -pady 10

         #--- Entry centerspeed
         entry $frm.frame2.entrycenterspeed -relief groove -width 5 -textvariable ::superpad::widget(centerspeed) -justify center
         pack $frm.frame2.entrycenterspeed -anchor nw -side left -padx 10 -pady 10

      pack $frm.frame2 -side top -fill both -expand 0

      #--- Frame pour le choix du focuser
      frame $frm.frame3 -borderwidth 0 -relief raised

         ::confEqt::createFrameFocuser $frm.frame3.focuser ::superpad::widget(focuserLabel)
         pack $frm.frame3.focuser -anchor nw -side left -padx 10 -pady 10

      pack $frm.frame3 -side top -fill both -expand 0

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

      #--- creation du focuser
      if { $conf(superpad,focuserLabel) != "" } {
         ::$conf(superpad,focuserLabel)::createPlugin
      }

      #--- affiche la raquette
      run $conf(superpad,padsize) $conf(superpad,position)

      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      global conf

      if { [ winfo exists .superpad ] } {
         #--- enregistre la position de la raquette
         set geom [wm geometry .superpad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(superpad,position) "+[string range $geom $deb $fin]"
         #--- supprime la raquette
         destroy .superpad
      }

      return
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
   proc run { {zoom .4} {positionxy +0+0} } {
      global caption color colorpad geompad

      if { [ string length [ info commands .superpad.display* ] ] != "0" } {
         destroy .superpad
      }

      if { $zoom <= "0" } {
         destroy .superpad
         return
      }

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      #--- Definition of colorpads
      #--- Definition des couleurs
      set colorpad(backkey)  $color(gray_pad)
      set colorpad(backpad)  $color(blue_pad)
      set colorpad(backdisp) $color(red_pad)
      set colorpad(textkey)  $color(white)
      set colorpad(green)    $color(green)
      set colorpad(black)    $color(black)

      #--- Definition des geompadetries
      #--- Definition of geometry
      set geompad(larg)       [ expr int(370*$zoom+10) ]
      set geompad(long)       [ expr int(600*$zoom+40) ]
      set geompad(fontsize50) [ expr int(36*$zoom) ]
      set geompad(fontsize25) [ expr int(25*$zoom) ]
      set geompad(fontsize20) [ expr int(20*$zoom) ]
      set geompad(fontsize16) [ expr int(16*$zoom) ]
      set geompad(fontsize14) [ expr int(14*$zoom) ]
      set geompad(fontsize10) [ expr int(10*$zoom) ]
      set geompad(10pixels)   [ expr int(10*$zoom) ]
      set geompad(20pixels)   [ expr int(20*$zoom) ]
      set geompad(larg2)      [ expr int(85*$zoom) ]
      set geompad(haut2)      [ expr int(65*$zoom) ]
      set geompad(haut)       [ expr int(70*$zoom) ]
      set geompad(linewidth0) [ expr int(3*$zoom) ]
      set geompad(linewidth)  [ expr int($geompad(linewidth0)+1) ]
      set geompad(lightx1)    [ expr int(10*$zoom) ]
      set geompad(lighty1)    [ expr int(30*$zoom) ]
      set geompad(lightx2)    [ expr int(20*$zoom) ]
      set geompad(lighty2)    [ expr int(40*$zoom) ]
      if { $geompad(linewidth0) <= "1" } { set geompad(textthick) "" } else { set geompad(textthick) "bold" }

      # =========================================
      # === Setting main window
      # =========================================

      #--- Create the toplevel window .superpad
      #--- Cree la fenetre .superpad de niveau le plus haut
      if { [ winfo exists .superpad ] } {
         destroy .superpad
      }
      toplevel .superpad -class toplevel -bg $colorpad(backpad)
      wm geometry .superpad $geompad(larg)x$geompad(long)$positionxy
      wm resizable .superpad 0 0
      wm title .superpad $caption(superpad,titre)
      wm protocol .superpad WM_DELETE_WINDOW ::superpad::deletePluginInstance

      # =========================================
      # === Setting subwindows
      # =========================================

      #--- add frame with manual motion buttons
      ::telescopePad::addFrame .superpad $zoom

      #--- add frame with alignment buttons (goto, center, ...)
      ::AlignManager::addFrame .superpad

      #--- add frame to manage focus
      ::FrameFocusManager::addFrame .superpad $zoom

      #--- Initialisation de la position du telescope
      ::telescopePad::init

      #--- La fenetre est active
      focus .superpad

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .superpad <Key-F1> { ::console::GiveFocus }

   }

}

###################################################################
#      MovePad                                                    #
###################################################################

namespace eval ::telescopePad {

   array set private {
      telescopeRa    ""
      telescopeDec   ""
   }

   #------------------------------------------------------------
   #  init
   #     initialisation
   #------------------------------------------------------------
   proc init { } {
      displayCoord
      update
   }

   #------------------------------------------------------------
   #  displayCoord
   #     affiche les coordonnees fournies par SkySensor
   #------------------------------------------------------------
   proc displayCoord { } {
      variable private
      global audace caption

      if { $audace(telNo) == "0" } {
         return
      }

      if {[::tel::list]!=""} {
         set radec [ tel$audace(telNo) radec coord -equinox J2000.0 ]
         #--- affiche les coordonnees
         set private(telescopeRa)  [lindex $radec 0]
         set private(telescopeDec) [lindex $radec 1]
     } else {
         #--- display error
         set private(telescopeRa)  "$caption(superpad,telescope)"
         set private(telescopeDec) "$caption(superpad,non_connecte)"
      }
      update
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
      global colorpad

      set catchError [ catch {
         #--- Gestion des boutons
         if { $private(active) == 1 } {
            if { $direction == "n" } {
               $This.card.ns.n configure -bg $colorpad(textkey) -fg $colorpad(black)
            } elseif { $direction == "s" } {
               $This.card.ns.s configure -bg $colorpad(textkey) -fg $colorpad(black)
            } elseif { $direction == "w" } {
               $This.card.w configure -bg $colorpad(textkey) -fg $colorpad(black)
            } elseif { $direction == "e" } {
               $This.card.e configure -bg $colorpad(textkey) -fg $colorpad(black)
            }
         }
         #--- Debut du mouvement
         ::telescope::move $direction
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(superpad,titre)
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
      global colorpad

      #--- Fin de mouvement
      ::telescope::stop $direction
      #--- Gestion des boutons
      if { $private(active) == 1 } {
         if { $direction == "n" } {
            $This.card.ns.n configure -bg $colorpad(backkey) -fg $colorpad(textkey)
         } elseif { $direction == "s" } {
            $This.card.ns.s configure -bg $colorpad(backkey) -fg $colorpad(textkey)
         } elseif { $direction == "w" } {
            $This.card.w configure -bg $colorpad(backkey) -fg $colorpad(textkey)
         } elseif { $direction == "e" } {
            $This.card.e configure -bg $colorpad(backkey) -fg $colorpad(textkey)
         }
      }
   }

   #------------------------------------------------------------
   #  setSpeedRadec
   #     gere les vitesses disponibles pour la monture
   #------------------------------------------------------------
   proc setSpeedRadec { rate } {
      set catchError [ catch {
         #--- Gestion des vitesses
         ::telescope::setSpeed $rate
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(superpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  addFrame
   #     add a frame with move button
   #------------------------------------------------------------
   proc addFrame { parentFrame zoom } {
      variable This
      global audace caption colorpad geompad

      set This $parentFrame.movepad

      set private(active) 0

      frame $This -borderwidth 0 -bg $colorpad(backpad) -borderwidth 2 -relief groove

      #--- Frame des boutons de deplacement manuel

      #--- Create a frame for the cardinal buttons
      #--- Cree un espace pour les boutons cardinaux
      frame $This.card -height 150 -borderwidth 0 -relief flat -bg $colorpad(backpad)
      pack $This.card -in $This -side top -fill x -padx 2

      #--- Frame for speed choice
      frame $This.card.speed -width $geompad(20pixels) \
         -bg $colorpad(backpad)
      pack $This.card.speed -in $This.card -side left -fill y -expand 1

      radiobutton $This.card.speed.4 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -text "4" -value 4 -variable audace(telescope,speed) \
         -command { ::telescopePad::setSpeedRadec 4 }

      radiobutton $This.card.speed.3 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -highlightcolor $colorpad(green) \
         -text "3" -value 3 -variable audace(telescope,speed) \
         -command { ::telescopePad::setSpeedRadec 3 }

      radiobutton $This.card.speed.2 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -text "2" -value 2 -variable audace(telescope,speed) \
         -command { ::telescopePad::setSpeedRadec 2 }

      radiobutton $This.card.speed.1 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -text "1" -value 1 -variable audace(telescope,speed) \
         -command { ::telescopePad::setSpeedRadec 1 }

      pack $This.card.speed.4 -in $This.card.speed -fill y -expand 1
      pack $This.card.speed.3 -in $This.card.speed -fill y -expand 1
      pack $This.card.speed.2 -in $This.card.speed -fill y -expand 1
      pack $This.card.speed.1 -in $This.card.speed -fill y -expand 1

      button $This.card.w -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "W" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      frame $This.card.ns \
         -width $geompad(larg2) \
         -borderwidth 0 -relief flat -bg $colorpad(backpad)

      button $This.card.ns.n -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "N" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      button $This.card.ns.s -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "S" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      button $This.card.e -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "E" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      pack $This.card.e -in $This.card -side left -expand 1 -padx 2 -pady 2
      pack $This.card.ns -in $This.card -side left -expand 1 -fill x
      pack $This.card.ns.n -in $This.card.ns -side top  -padx 2 -pady 2
      pack $This.card.ns.s -in $This.card.ns -side bottom  -padx 2 -pady 2
      pack $This.card.w -in $This.card -side right -expand 1 -padx 2 -pady 2

      pack $This.card -in $This -fill both -expand 1

      #--- Frame du checkbutton pour activer / desactiver les fleches du clavier
      frame $This.frameCheck -borderwidth 0 -relief raise -bg $colorpad(backpad)

      checkbutton $This.frameCheck.active -borderwidth 1 \
         -variable ::telescopePad::private(active) \
         -bg $colorpad(backpad) -fg $colorpad(textkey) \
         -activebackground $colorpad(backpad) -activeforeground $colorpad(textkey) \
         -selectcolor $colorpad(backpad) -highlightbackground $colorpad(backpad) \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,activeFleches) \
         -command "::telescopePad::activeFlechesClavier"
      pack $This.frameCheck.active -anchor center -fill none -pady 2

      pack $This.frameCheck -in $This -fill x

      #--- Frame des coordonnees
      frame $This.frameCoord -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Label pour RA
      label  $This.frameCoord.labelRa \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable audace(telescope,getra) -bg $colorpad(backpad) -fg $colorpad(textkey) -relief groove -width 11
      pack   $This.frameCoord.labelRa -in $This.frameCoord -anchor center -fill x  -side left

      #--- Label pour DEC
      label  $This.frameCoord.labelDec \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable audace(telescope,getdec) -bg $colorpad(backpad) -fg $colorpad(textkey) -relief groove -width 11
      pack   $This.frameCoord.labelDec -in $This.frameCoord -anchor center -fill x

      pack $This.frameCoord -in $This -fill x

      pack $This -in $parentFrame -fill both -expand 1

      #--- bind Cardinal move button
      bind $This.card.e <ButtonPress-1>      { ::telescopePad::moveRadec e }
      bind $This.card.e <ButtonRelease-1>    { ::telescopePad::stopRadec e }
      bind $This.card.w <ButtonPress-1>      { ::telescopePad::moveRadec w }
      bind $This.card.w <ButtonRelease-1>    { ::telescopePad::stopRadec w }
      bind $This.card.ns.s <ButtonPress-1>   { ::telescopePad::moveRadec s }
      bind $This.card.ns.s <ButtonRelease-1> { ::telescopePad::stopRadec s }
      bind $This.card.ns.n <ButtonPress-1>   { ::telescopePad::moveRadec n }
      bind $This.card.ns.n <ButtonRelease-1> { ::telescopePad::stopRadec n }

      #--- bind display zone
      bind $This.frameCoord <ButtonPress-1>          { ::telescope::afficheCoord }
      bind $This.frameCoord.labelRa <ButtonPress-1>  { ::telescope::afficheCoord }
      bind $This.frameCoord.labelDec <ButtonPress-1> { ::telescope::afficheCoord }
   }

   #------------------------------------------------------------
   #  activeFlechesClavier
   #     active les fleches du clavier
   #------------------------------------------------------------
   proc activeFlechesClavier { } {
      variable private

      if { $private(active) == 1 } {
         #--- bind Cardinal sur les 4 fleches du clavier
         #--- ne fonctionne que si la raquette SuperPad a le focus
         bind .superpad <KeyPress-Left>    { ::telescopePad::moveRadec e }
         bind .superpad <KeyRelease-Left>  { ::telescopePad::stopRadec e }
         bind .superpad <KeyPress-Right>   { ::telescopePad::moveRadec w }
         bind .superpad <KeyRelease-Right> { ::telescopePad::stopRadec w }
         bind .superpad <KeyPress-Down>    { ::telescopePad::moveRadec s }
         bind .superpad <KeyRelease-Down>  { ::telescopePad::stopRadec s }
         bind .superpad <KeyPress-Up>      { ::telescopePad::moveRadec n }
         bind .superpad <KeyRelease-Up>    { ::telescopePad::stopRadec n }
      } else {
         bind .superpad <KeyPress-Left>    { }
         bind .superpad <KeyRelease-Left>  { }
         bind .superpad <KeyPress-Right>   { }
         bind .superpad <KeyRelease-Right> { }
         bind .superpad <KeyPress-Down>    { }
         bind .superpad <KeyRelease-Down>  { }
         bind .superpad <KeyPress-Up>      { }
         bind .superpad <KeyRelease-Up>    { }
      }
   }

}

###################################################################
#      AlignManager                                               #
###################################################################

namespace eval ::AlignManager {
   array set private {
      This         ""
      targetRa     ""
      targetDec    ""
      equinox      "J2000.0"
      targetName   ""
      mountSide    "e"
      nameResolver ""
   }

   #------------------------------------------------------------
   #  cmdAlign
   #     aligne le telescope sur les coordonnees l'objet cible
   #------------------------------------------------------------
   proc cmdAlign { } {
      variable private

      set catchError [ catch {
         ::telescope::match [list $private(targetRa) $private(targetDec)] $private(equinox) $private(mountSide)
      } ]
      if { $catchError != 0 } {
         ::tkutil::displayErrorInfoTelescope "MATCH Error"
      }
   }

   #------------------------------------------------------------
   #  cmdChangeMountSide
   #
   #------------------------------------------------------------
   proc cmdChangeMountSide { } {
      variable private

      if { $private(mountSide) == "w" } {
         set private(mountSide) "e"
      } else {
         set private(mountSide) "w"
      }

      update
   }

   #------------------------------------------------------------
   #  cmdStartGoto
   #     pointe l'objet cible
   #------------------------------------------------------------
   proc cmdStartGoto { } {
      variable This
      variable private

      set catchError [ catch {
         ::telescope::goto [list $private(targetRa) $private(targetDec)] 0 $This.frameGoto.buttonStartGoto "" $::AlignManager::private(targetName) $private(equinox)
      } ]
      if { $catchError != 0 } {
         ::tkutil::displayErrorInfoTelescope "GOTO Error"
      }
   }

   #------------------------------------------------------------
   #  cmdSelectStar
   #     show dialog window DlgSelectStar
   #     display name, ra, dec of selected star in the frame
   #------------------------------------------------------------
   proc cmdSelectStar { } {
      variable private

      set coord [::DlgSelectStar::run]
      if { [string compare $coord ""]==0 } {
         #--- if no star selected, do nothing
         return
      }
      set private(targetRa)   "[lindex $coord 0]"
      set private(targetDec)  "[lindex $coord 1]"
      set private(equinox)    "J2000.0"
      set private(targetName) "[lindex $coord 3]"
      update
   }

   #------------------------------------------------------------
   #  cmdSkyMap
   #     recupere et affiche les coordonnees dans une carte
   #     si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   #------------------------------------------------------------
   proc cmdSkyMap { } {
      variable private

      #--- Je nettoye le nom du resolveur
      set ::AlignManager::private(nameResolver) ""

      set result [::carte::getSelectedObject]
      if { [llength $result] == 5 } {
         set ra        [mc_angle2hms [lindex $result 0] 360 nozero 0 auto string]
         set dec       [mc_angle2dms [lindex $result 1] 90 nozero 0 + string]
         set equinox   [lindex $result 2]
         set name      [lindex $result 3]
         set magnitude [lindex $result 4]

         set private(targetRa)   $ra
         set private(targetDec)  $dec
         set private(equinox)    $equinox
         set private(targetName) $name
         update
         #--- Je recherche la visu dans laquelle l'outil Telescope est actif
         foreach visuNo [ ::visu::list ] {
            if { [ ::confVisu::getTool $visuNo ] == "tlscp" } {
               set visu $visuNo
               #--- Je mets a jour le nom, les coordonnees et l'equinoxe dans l'outil Telescope
               ::tlscp::cmdSkyMap $visuNo
            }
         }
      }
   }

   #------------------------------------------------------------
   #  cmdResolver
   #     resolveur de noms et retourne les coordonnees J2000.0
   #------------------------------------------------------------
   proc cmdResolver { name } {
      variable private

      set erreur [ catch { name2coord $name } radec ]
      if { $erreur == 0 } {
         if { $name == "" } {
            bell
            set ::AlignManager::private(nameResolver) ""
            set private(targetName)                   $::AlignManager::private(nameResolver)
            set private(targetRa)                     ""
            set private(targetDec)                    ""
            set private(equinox)                      "J2000.0"
         } else {
            set private(targetName) $::AlignManager::private(nameResolver)
            set private(targetRa)   [ mc_angle2hms [ lindex $radec 0 ] 360 zero 0 auto string ]
            set private(targetDec)  [ mc_angle2dms [ lindex $radec 1 ] 90 zero 0 + string ]
            set private(equinox)    "J2000.0"
         }
      } else {
         bell
         set ::AlignManager::private(nameResolver) ""
         set private(targetName)                   $::AlignManager::private(nameResolver)
         set private(targetRa)                     ""
         set private(targetDec)                    ""
         set private(equinox)    "J2000.0"
      }
   }

   #------------------------------------------------------------
   #  modpoi_catalogmean2apparent
   #     Input :
   #       rae,dece : coordinates J2000.0 (degrees)
   #       equinox  : equinox (exemple : J2000.0)
   #       date     : date en TU
   #     Output :
   #       rav,decv : true coordinates (degrees)
   #         Hv  : true hour angle (degrees)
   #         hv  : true altitude altaz coordinate (degrees)
   #         azv : true azimut altaz coodinate (degrees)
   #------------------------------------------------------------
   proc modpoi_catalogmean2apparent { rae dece equinox date } {
      global audace modpoi

      set modpoi(pi) 3.1415926535897
      set modpoi(deg2rad) [expr $modpoi(pi)/180.]
      set modpoi(rad2deg) [expr 180./$modpoi(pi)]

      if {[info exists modpoi(var,home)]==0} {
         if {[info exists audace(posobs,observateur,gps)]==1} {
            set modpoi(var,home) $audace(posobs,observateur,gps)
         } else {
            set modpoi(var,home) "GPS 1 E 43 0"
         }
      }
      set pi $modpoi(pi)
      set deg2rad $modpoi(deg2rad)
      set rad2deg $modpoi(rad2deg)
      #--- aberration annuelle
      set radec [mc_aberrationradec annual [list $rae $dece] $date ]
      #--- correction de precession
      set radec [mc_precessradec $radec $equinox $date]
      #--- correction de nutation
      set radec [mc_nutationradec $radec $date]
      #--- aberration de l'aberration diurne
      set radec [mc_aberrationradec diurnal $radec $date $modpoi(var,home)]
      #--- calcul de l'angle horaire et de la hauteur vraie
      set rav [lindex $radec 0]
      set decv [lindex $radec 1]
      set dummy [mc_radec2altaz ${rav} ${decv} $modpoi(var,home) $date]
      set azv [lindex $dummy 0]
      set hv [lindex $dummy 1]
      set Hv [lindex $dummy 2]
      #--- return
      return [list $rav $decv $Hv $hv $azv]
   }

   #------------------------------------------------------------
   #  addFrame
   #     add a frame with align button
   #------------------------------------------------------------
   proc addFrame { parentFrame } {
      variable This
      variable private
      global caption colorpad geompad

      set private(This) $parentFrame.frameAlign
      set This $private(This)

      frame $This -borderwidth 2 -bg $colorpad(backpad) -borderwidth 2 -relief groove

      #--- Frame du pointage
      frame $This.frameGoto -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Frame de selection de l'objet a pointer
      frame $This.frameGoto.frameSelect -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Button targetName
      button  $This.frameGoto.frameSelect.buttargetName -borderwidth 1 -bg $colorpad(backkey) -width 14\
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(targetName) \
         -command { ::AlignManager::cmdSelectStar }
      pack $This.frameGoto.frameSelect.buttargetName -in $This.frameGoto.frameSelect -anchor center -fill x -side left

      #--- Button carte
      button  $This.frameGoto.frameSelect.butSkyMap -borderwidth 1 -bg $colorpad(backkey) -width 6\
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonSkyMap) \
         -command { ::AlignManager::cmdSkyMap }
      pack   $This.frameGoto.frameSelect.butSkyMap -in $This.frameGoto.frameSelect -anchor center -fill x

      pack $This.frameGoto.frameSelect -in $This.frameGoto -fill x

      #--- Frame des coordonnees
      frame $This.frameTargetCoord -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Entry Ascension droite
      entry  $This.frameTargetCoord.targetRa -bg $colorpad(backdisp) -relief groove -width 13 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(targetRa)
      pack   $This.frameTargetCoord.targetRa -in $This.frameTargetCoord -anchor center -fill x -side left

      #--- Entry Declinaison
      entry  $This.frameTargetCoord.targetDec -bg $colorpad(backdisp) -relief groove -width 13 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(targetDec)
      pack   $This.frameTargetCoord.targetDec -in $This.frameTargetCoord -anchor center -fill x

      pack $This.frameTargetCoord -in $This.frameGoto -fill x

      #--- Frame Goto
      #--- button StartGOTO
      button  $This.frameGoto.buttonStartGoto -borderwidth 1 -bg $colorpad(backkey) -width 14\
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonGoto) \
         -relief ridge \
         -command { ::AlignManager::cmdStartGoto }
      pack   $This.frameGoto.buttonStartGoto -in $This.frameGoto -anchor center -fill x -side left

      #--- button StopGOTO
      button  $This.frameGoto.buttonStopGoto -borderwidth 1 -bg $colorpad(backkey) -width 6 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonStopGoto) \
         -relief ridge \
         -command { ::telescope::stopGoto }
      pack   $This.frameGoto.buttonStopGoto -in $This.frameGoto -anchor center -fill x

      pack $This.frameGoto -in $This -fill x

      #--- Frame du pointage
      frame $This.fraAlign -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- button MOUNTSIDE
      button  $This.fraAlign.butMountSide -borderwidth 1 -bg $colorpad(backkey) \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable  ::AlignManager::private(mountSide) \
         -relief ridge -width 4 \
         -command { ::AlignManager::cmdChangeMountSide }
      pack $This.fraAlign.butMountSide -in $This.fraAlign -fill both -side left

      #--- button ALIGN
      button  $This.fraAlign.butAlign -borderwidth 1 -bg $colorpad(backkey) \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonAlign) \
         -relief ridge \
         -command { ::AlignManager::cmdAlign }
      pack   $This.fraAlign.butAlign -in $This.fraAlign -fill x

      pack $This.fraAlign -in $This -fill x

      #--- Frame du Resolver
      frame $This.fraResolver -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Label Resolver
      button  $This.fraResolver.labResolver -bg $colorpad(backkey) -relief groove -width 11 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,labResolver) \
         -command { ::AlignManager::cmdResolver $::AlignManager::private(nameResolver) }
      pack   $This.fraResolver.labResolver -in $This.fraResolver -anchor center -fill y -side left

      #--- Entry Resolver
      entry  $This.fraResolver.entResolver -bg $colorpad(backdisp) -relief groove -width 11 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(nameResolver)
      pack   $This.fraResolver.entResolver -in $This.fraResolver -anchor center -fill both -expand 1

      pack $This.fraResolver -in $This -fill x

      pack $This -in $parentFrame -fill x

   }
}

###################################################################
#      FocusManager                                               #
###################################################################

namespace eval ::FrameFocusManager {
   array set private {
      This  ""
      speed "2"
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
         ::focus::move $::conf(superpad,focuserLabel) $direction
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(superpad,titre)
      }
   }

   #------------------------------------------------------------
   #  stopFocus
   #     arrete le mouvement du focuser
   #------------------------------------------------------------
   proc stopFocus { } {
      #--- Fin de mouvement
      ::focus::move $::conf(superpad,focuserLabel) stop
   }

   #------------------------------------------------------------
   #  incrementSpeedFocus
   #     gere les vitesses disponibles du focuser
   #------------------------------------------------------------
   proc incrementSpeedFocus { } {
      set catchError [ catch {
         #--- Gestion des vitesses
         ::focus::incrementSpeed $::conf(superpad,focuserLabel) pad
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(superpad,titre)
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
         ::focus::setSpeed $::conf(superpad,focuserLabel) $rate
      } ]

      if { $catchError != 0 } {
         ::tkutil::displayErrorInfo $::caption(superpad,titre)
         #--- Je fais un beep sonore pour signaler que la commande n'est pas prise en compte
         bell
      }
   }

   #------------------------------------------------------------
   #  getFrame
   #     returns current frame
   #------------------------------------------------------------
   proc getFrame { } {
      variable private

      return $private(This)
   }

   #------------------------------------------------------------
   #  addFrame
   #     adds a frame with focus buttons
   #------------------------------------------------------------
   proc addFrame { parentFrame zoom } {
      variable private
      global audace colorpad conf geompad

      set private(This) "$parentFrame.frameFocusManager"
      set This $private(This)

      if { $::conf(superpad,focuserLabel) != "" } {
         set state "normal"
      } else {
         set state "disabled"
      }

      #--- create frame to display focus buttons
      frame $This -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- create frame of the buttons
      frame $This.we \
         -width $geompad(larg2) -height $geompad(haut2) \
         -borderwidth 0 -relief flat -bg $colorpad(backpad)
      pack $This.we \
         -in $This -side top -fill x

      button  $This.we.buttonMoins -borderwidth 4 \
         -font [ list {Courier} $geompad(fontsize50) $geompad(textthick) ] \
         -text "-" \
         -width 2 \
         -anchor center \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -state $state \
         -relief ridge
      pack $This.we.buttonMoins -in $This.we -expand 0 -side left -padx 4 -pady 8

      #--- write the label of speed
      label $This.we.lab \
         -font [ list {Courier} $geompad(fontsize50) $geompad(textthick) ] \
         -textvariable audace(focus,labelspeed) \
         -borderwidth 0 -relief groove -bg $colorpad(backpad) \
         -fg $colorpad(textkey) \
         -state $state \
         -width 2
      pack $This.we.lab -in $This.we -side left -expand 1 -fill x -padx 2 -pady 8

      button  $This.we.buttonPlus -borderwidth 4 \
         -font [ list {Courier} $geompad(fontsize50) $geompad(textthick) ] \
         -text "+" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -state $state \
         -relief ridge
      pack $This.we.buttonPlus -in $This.we -expand 0 -side left -padx 4 -pady 8

      set zone(moins) $This.we.buttonMoins
      set zone(plus)  $This.we.buttonPlus

      pack $This -in $parentFrame -fill x

      if { $::conf(superpad,focuserLabel) != "" } {
        #--- toggles speed
        bind $This.we.lab <ButtonPress-1> { ::FrameFocusManager::incrementSpeedFocus }
        #--- focus move
        bind $zone(moins) <ButtonPress-1> {
           ::FrameFocusManager::moveFocus -
           [::FrameFocusManager::getFrame].we.buttonMoins configure -bg $colorpad(backpad)
        }
        bind $zone(moins) <ButtonRelease-1> {
           ::FrameFocusManager::stopFocus
           [::FrameFocusManager::getFrame].we.buttonMoins configure -bg $colorpad(backkey)
        }
        bind $zone(plus) <ButtonPress-1> {
           ::FrameFocusManager::moveFocus +
           [::FrameFocusManager::getFrame].we.buttonPlus configure -bg $colorpad(backpad)
        }
        bind $zone(plus) <ButtonRelease-1> {
           ::FrameFocusManager::stopFocus
           [::FrameFocusManager::getFrame].we.buttonPlus configure -bg $colorpad(backkey)
        }
      }
      #--- initialise et affiche la vitesse du focuser
      ::FrameFocusManager::setSpeedFocus 0
   }
}

###################################################################
#      exemple de mini catalogue                                  #
#      a remplacer par un appel a un catalogue confcat            #
###################################################################

namespace eval ::DlgSelectStar {

   #------------------------------------------------------------
   #  run this args
   #     Cree la fenetre de configuration du type de fenetre
   #     this = chemin de la fenetre
   #------------------------------------------------------------
   proc run { { this ".selectStar" } } {
      variable This
      variable result ""

      set This $this
      createDialog
      tkwait window $This
      return $result
   }

   #------------------------------------------------------------
   #  select
   #     Fonction appellee lors de l'appui sur le bouton 'OK' pour
   #     appliquer la configuration, et fermer la fenetre de
   #     configuration du type de fenetre
   #------------------------------------------------------------
   proc select { starname } {
      variable This
      variable result
      global stars

      set coord [split $stars($starname)]
      set result "$coord $starname"

      destroy $This
   }

   #------------------------------------------------------------
   #  createDialog
   #     fenetre de selection d'une etoile
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable startname
      global caption stars

      set stars(Achernar)        {01h37m43s -57d14m13s 01}
      set stars(Acrux)           {12h26m36s -63d05m57s 02}
      set stars(AlNair)          {22h08m14s -46d57m42s 03}
      set stars(Albireo)         {19h30m43s +27d57m35s 04}
      set stars(Aldebaran)       {04h35m55s +16d30m31s 05}
      set stars(Alphard)         {09h27m35s -08d39m31s 06}
      set stars(Alphecca)        {15h34m41s +26d42m52s 07}
      set stars(Alpheratz)       {00h08m23s +29d05m24s 08}
      set stars(Altair)          {19h50m47s +08d52m10s 09}
      set stars(Antares)         {16h29m24s -26d25m55s 10}
      set stars(Arcturus)        {14h15m39s +19d10m36s 11}
      set stars(Betelgeuse)      {05h55m10s +07d24m25s 12}
      set stars(Canopus)         {06h23m57s -52d41m45s 13}
      set stars(Capella)         {05h16m41s +45d59m48s 14}
      set stars(Deneb)           {20h41m26s +45d16m49s 15}
      set stars(Denebola)        {11h49m03s +14d34m18s 16}
      set stars(Diphda)          {00h43m36s -17d59m12s 17}
      set stars(Dubhe)           {11h03m44s +61d45m02s 18}
      set stars(Fomalhaut)       {22h57m39s -29d37m22s 19}
      set stars(Hamal)           {02h07m11s +23d27m43s 20}
      set stars(Markab)          {23h04m46s +15d12m19s 21}
      set stars(Mirphak)         {03h24m19s +49d51m40s 22}
      set stars(Mizar)           {13h23m56s +54d55m31s 23}
      set stars(Nunki)           {18h55m16s -26d17m49s 24}
      set stars(Pollux)          {07h45m18s +28d01m34s 25}
      set stars(Procyon)         {07h39m18s +05d13m19s 26}
      set stars(Rasalhague)      {17h34m56s +12d33m34s 27}
      set stars(Regulus)         {10h08m22s +11d58m02s 28}
      set stars(Rigel)           {05h14m32s -08d12m06s 29}
      set stars(RigelKentaurus)  {14h39m31s -60d49m59s 30}
      set stars(Schedir)         {00h40m31s +56d32m14s 31}
      set stars(Sirius)          {06h45m08s -16d43m11s 32}
      set stars(Spica)           {13h25m11s -11d09m41s 33}
      set stars(Alsuhail)        {09h08m00s -43d25m57s 34}
      set stars(Vega)            {18h36m56s +38d47m04s 35}

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #--- cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This 310x130+150+100
      wm title $This $caption(superpad,StarWindowTitle)

      #--- cree un frame pour y mettre des boutons
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- cree les boutons des etoiles
      set c 0
      set r 0
      set searchId [array startsearch stars]
      while { [array anymore stars $searchId] == 1 } {
         set value [array nextelement stars $searchId]
        # ::console::affiche_resultat "value = $value $This.frameButton.button$value\n"
         button $This.frameButton.button$value -text $value -borderwidth 2 -command "::DlgSelectStar::select $value"
         grid configure $This.frameButton.button$value -column $c -row $r -sticky we -in $This.frameButton
         incr c
         if { $c == 5 } {
            incr r
            set c 0
         }
      }
      array donesearch stars $searchId
      update
      set size [grid bbox $This.frameButton]
      wm geometry $This [lindex $size 2]x[lindex $size 3]

      pack $This.frameButton -side top -fill both -expand 1
   }

}

