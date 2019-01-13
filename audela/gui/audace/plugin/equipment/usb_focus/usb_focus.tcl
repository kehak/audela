#
## @file usb_focus.tcl
#  @brief Gère l'interface graphique de USB_Focus
#  @author Raymond ZACHANTKE
#  $Id: usb_focus.tcl 13604 2016-04-04 13:32:10Z rzachantke $
#

# Procedures generiques obligatoires (pour configurer tous les plugins camera, monture, equipement) :
#     getPluginTitle     : Retourne le titre du plugin dans la langue de l'utilisateur
#     getStartFlag       : Retourne l'indicateur de lancement au démarrage
#     getPluginHelp      : Retourne la documentation htm associee
#     getPluginDirectory : Retourne le nom du répertoire du plugin
#     getPluginType      : Retourne le type de plugin
#     getPluginOS        : Retourne les OS sous lesquels le plugin fonctionne
#     getPluginProperty  : Retourne la propriété du plugin
#     initPlugin         : Initialise le namespace (appelee pendant le chargement de ce source)
#     initConf           : Initialise les variables de configuration
#     createPlugin       : Démarre le plugin
#     deletePlugin       : Charge les variables locales dans des variables de configuration
#     fillConfigPage     : Affiche la fenêtre de configuration de ce plugin
#     configurePlugin    : Configure le plugin
#     isReady            : Informe de l'état de fonctionnement du plugin
#
# Procedures specifiques a ce plugin :
#     displayCurrentPosition : Affiche la position courante du focaliseur
#     getPosition            : Retourne la position courante du focaliseur
#     goto                   : Envoie le focaliseur a la position audace(focus,targetFocus)
#     incrementSpeed         : Incremente la vitesse du focaliseur et appelle la procedure setSpeed
#     initPosition           : Initialise la position du focaliseur a moteur pas a pas a 0
#     move                   : Demarre/arrete le mouvement du focaliseur
#     possedeControleEtendu  : Retourne 1 si le focaliseur possede un controle etendu du focus, sinon 0
#     setSpeed               : Change la vitesse du focaliseur
#

## @namespace usb_focus
#  @brief Gère l'interface graphique de USB_Focus
namespace eval ::usb_focus {
   package provide usb_focus 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] usb_focus.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::usb_focus::getPluginTitle { } {
   global caption

   return "$caption(usb_focus,label)"
}

#------------------------------------------------------------
## @brief    retourne l'indicateur de lancement au démarrage de Audela
#  @return   1 (lancé au démarrage) , 0 (pas lancé)
#
proc ::usb_focus::getStartFlag { } {
   return $::conf(usb_focus,start)
}

#------------------------------------------------------------
#  brief    retourne le nom du fichier d'aide principal
#  return  nom du fichier d'aide principal
#
proc ::usb_focus::getPluginHelp { } {
   return "usb_focus.htm"
}

#------------------------------------------------------------
#  brief    retourne le type de plugin
#  return   type de plugin
#
proc ::usb_focus::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  brief    retourne le nom du répertoire du plugin
#  return   nom du répertoire du plugin : "usb_focus"
#
proc ::usb_focus::getPluginDirectory { } {
   return "usb_focus"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux Darwin"
#
proc ::usb_focus::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans un onglet du menu Equipements
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::usb_focus::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
      default  { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#
proc ::usb_focus::initPlugin { } {
   variable private

   source [ file join $::audace(rep_plugin) equipment usb_focus usb_focus_cmd.tcl]

   ::usb_focus::initConf

   #::usb_focus::createPlugin

   set private(frm) ""
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'USB_Focus
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini"
#  - conf(usb_focus,start) définit l'indicateur de lancement au démarrage
#  - conf(usb_focus) définit une liste de paramètres utilisateurs
#    -# port COM                           = ""
#    -# increment en pas (mode pas entier) = 1
#    -# sens de rotation (sens direct)     = 0
#    -# valeur du backlash                 = 500
#    -# increment du nombre de pas         = 10
#
proc ::usb_focus::initConf { } {
   global conf

   if {![info exists conf(usb_focus,start)]} {
      set conf(usb_focus,start) "0"
   }

   #--- Cree les variables dans conf(...) si elles n'existent pas
   if {![info exists conf(usb_focus)] || [llength $conf(usb_focus)] != 5} {
      set conf(usb_focus) [list "" 1 0 500 10]
   }
}

#------------------------------------------------------------
## @brief démarre le plugin
#
proc ::usb_focus::createPlugin { } {
   variable widget
   variable private
   global conf caption

   #--   empeche la tentative d'ouvrir le port deja ouvert
   if {[info exists private(linkNo)] == 1 &&  $private(linkNo) != 0} { return }

   #--   cree le port et initialise les variables en cas de reussite
   if {![info exists widget(port)]} {
      #--- Prise en compte des liaisons
      set linkList [::confLink::getLinkLabels { "serialport" } ]
      #--- je copie les donnees de conf(...)
      lassign $conf(usb_focus) widget(port) widget(nbstep) widget(backlash)
   }

   if {$widget(port) ne "" && [::usb_focus::createPort $widget(port)]} {
      #--- cree la liaison du focuser
      #   (ne sert qu'a afficher l'utilisation de cette liaison par l'equipement)
      #     indispensable pour les tests isReady
      set private(linkNo) [::confLink::create $widget(port) "focuser" "USB_Focus" "" -noopen]
      ::console::disp "Start $caption(usb_focus,label)\n"
   }
}

#------------------------------------------------------------
## @brief  arrête le plugin et libère les ressources
#
proc ::usb_focus::deletePlugin { } {
   variable widget
   global caption

   ::usb_focus::configurePlugin
   ::confLink::delete $widget(port) "focuser" "USB_Focus"

   #--   ferme le port serie
   ::usb_focus::closePort

   #--   reinitialise les variable private et widget
   ::usb_focus::initLocalVar

   #--   inhibe les commandes
   ::usb_focus::setState disabled all

   #--   message de confirmation dans la console
   ::console::disp "Stop $caption(usb_focus,label)\n"
}

#------------------------------------------------------------
#  brief charge les variables locales dans des variables de configuration
#
proc ::usb_focus::configurePlugin { } {
   variable widget

   #--- copie les variables des widgets dans le tableau conf()
   set ::conf(usb_focus) [list $widget(port) $widget(stepincr) \
      $widget(motorsens) $widget(backlash) $widget(nbstep)]
}

#------------------------------------------------------------
## @brief initialise quelques variables lors du lancement et lors de la fermeture du port
#
proc ::usb_focus::initLocalVar {} {
   variable widget
   variable private
   global conf

   lassign [lrange $conf(usb_focus) 3 4] private(prev,backlash) private(prev,nbstep)

   set private(tty)           ""
   set private(linkNo)        0
   set private(prev,maxstep)  ""
   set private(prev,target)   ""
   set private(prev,coef)     ""
   set private(prev,seuil)    ""
   set widget(version)        ""
   set widget(motorspeed)     ""
   set widget(maxstep)        ""
   set widget(position)       ""
   set widget(target)         "0"
   set widget(temperature)    ""
   set widget(mode)           0
   set widget(coef)           ""
   set widget(seuil)          ""
}

#------------------------------------------------------------
## @brief   informe de l'état de fonctionnement du plugin
#  @return  1 (ready) , 0 (not ready)
#
proc ::usb_focus::isReady { } {
   variable private

   if {[info exists private(linkNo)] && $private(linkNo) != "0" } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  brief  affiche la frame configuration du focuseur
#  param  frm généré automatiquement  (.audace.confeqt.usr.onglet.fusb_focus)
#
proc ::usb_focus::fillConfigPage { frm } {
   variable widget
   variable private
   global caption conf

   set private(frm) $frm

   #--- je copie les donnees de conf(...)
   lassign $conf(usb_focus) widget(port) widget(stepincr) \
      widget(motorsens) widget(backlash) widget(nbstep)

   #--- Prise en compte des liaisons
   set linkList [::confLink::getLinkLabels { "serialport" } ]

   #--- Je verifie le contenu de la liste
   if {[llength $linkList ] > 0} {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
     if {[lsearch -exact $linkList $widget(port)] == -1} {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(port) [lindex $linkList 0]
      }
   } else {
      #--- si la liste est vide
      #--- je desactive l'option focuser
      set widget(port) ""
   }

   #--- Creation du frame contenant les commandes de usb_focus
   set f [frame $frm.frame1 -borderwidth 0 -relief raised]
   pack $frm.frame1 -side top -fill x

   #--   frame de la com
   labelframe $f.link -borderwidth 2 -text $caption(usb_focus,link)

      #--- Label de la liaison
      label $f.link.labelPort -text "$caption(usb_focus,port)"
      grid $f.link.labelPort -row 0 -column 0 -padx 5 -sticky w

      #--- Choix de la liaison
      ComboBox $f.link.port \
         -width [::tkutil::lgEntryComboBox $linkList] \
         -height [llength $linkList] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::usb_focus::widget(port) \
         -modifycmd "::usb_focus::onChangeLink" \
         -values $linkList
      grid $f.link.port -row 0 -column 1 -sticky ew

      #--- Bouton de configuration de la liaison
      button $f.link.configure -text "$caption(usb_focus,configure)" -relief raised \
         -command "::confLink::run ::usb_focus::widget(port) {\"serialport\"} \"$caption(usb_focus,label)\""
      grid $f.link.configure -row 0 -column 2 -padx 5 -pady 5 -sticky ew

   grid $f.link -row 0 -column 0 -padx 10 -pady 5 -sticky w

   #--- Version du microcontroleur
   frame $f.chip

      #--- Label N° de version
      label $f.chip.labelVersion -text "$caption(usb_focus,version)"
      grid $f.chip.labelVersion -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- N° de version
      label $f.chip.version -width 5 -justify left \
         -textvariable ::usb_focus::widget(version)
      grid  $f.chip.version -row 0 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton Reset
      button $f.chip.reset -text "$caption(usb_focus,reset)" -relief raised \
            -command "::usb_focus::reset"
      grid $f.chip.reset -row 0 -column 2 -padx 5 -pady 5 -sticky w

   grid $f.chip -row 1 -column 0 -padx 5 -pady 5 -sticky ew

   #--   frame du moteur
   labelframe $f.motor -borderwidth 2 -text $caption(usb_focus,motor)

      #--- Label du nombre de pas
      label $f.motor.labelStep -text "$caption(usb_focus,maxstep)"
      grid $f.motor.labelStep -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- Nombre de pas maxi
      entry $f.motor.maxstep -width 6 -justify right \
         -textvariable ::usb_focus::widget(maxstep)
      grid $f.motor.maxstep -row 0 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton de setmaxi
      button $f.motor.setmax -text "$caption(usb_focus,set)" -relief raised \
         -width 4 -command "::usb_focus::setMaxPos"
      grid $f.motor.setmax -row 0 -column 2 -padx 5 -sticky w

      #--- Label de la vitesse
      label $f.motor.labelSpeed -text "$caption(usb_focus,motorspeed)"
      grid $f.motor.labelSpeed -row 1 -column 0 -padx 5 -pady 5 -sticky w

      #--- Vitesse de deplacement
      ComboBox $f.motor.speed -width 4 -height 8 -relief sunken -borderwidth 1 -editable 0 \
         -textvariable ::usb_focus::widget(motorspeed) \
         -modifycmd "::usb_focus::setSpeed" \
         -values [list 2 3 4 5 6 7 8 9]
      grid $f.motor.speed -row 1 -column 1 -padx 5 -sticky w

      #--- Label de l'increment
      label $f.motor.labelIncrStep -text "$caption(usb_focus,step)"
      grid $f.motor.labelIncrStep -row 2 -column 0 -padx 5 -pady 5 -sticky w

      radiobutton $f.motor.halfstep -text "$caption(usb_focus,halfstep)" \
         -indicatoron 1 -variable ::usb_focus::widget(stepincr) -value 0 \
         -command "::usb_focus::setStepIncr"
      grid $f.motor.halfstep -row 2 -column 1 -padx 5 -sticky w

      radiobutton $f.motor.fullstep -text "$caption(usb_focus,fullstep)" \
         -indicatoron 1 -variable ::usb_focus::widget(stepincr) -value 1 \
         -command "::usb_focus::setStepIncr"
      grid $f.motor.fullstep -row 2 -column 2 -padx 5 -sticky w

      #--- Label du sens de rotation
      label $f.motor.labelRot -text "$caption(usb_focus,motorrot)"
      grid $f.motor.labelRot -row 3 -column 0 -padx 5 -pady 5 -sticky w

      set clockwise [image create photo]
      $clockwise configure -data {R0lGODlhGAAYAIIAMWyRQqDPFMnfebTReYyzQPj69nOqH5ysjCwAAAAAGAAY
         AAIDnVi63P4wSnfAhKIIYMC4y1ABZBB4l1AZAcsGhCVtr2nb8rMRJt/bBELk
         wPIJjkeeYVgbDAgdT1By8AUGhk8BAJ00DRnFIBepwUANsO0AGQicjhqB7YiR
         APSF2gRuYG9kBXstB2EFYzcBeQoHAQI2HQeSHDd9DQSPkAabiVgPT5mJN2OG
         fpg/P0dZElgHbldOAjFaE09Bt1NoChm8EQkAOw==}

      radiobutton $f.motor.clockwise -image $clockwise \
         -indicatoron 1 -variable ::usb_focus::widget(motorsens) -value 0 \
         -command "::usb_focus::setRot"
      grid $f.motor.clockwise -row 3 -column 1 -padx 5 -sticky w

      set anticlockwise [image create photo]
      $anticlockwise configure -data {R0lGODlhGAAYAIIAMWyRQqDPFMnfebTReYyzQPj69nOqH5ysjCwAAAAAGAAY
         AAIDnVi6LOWOyVkGufjSOcwZQjCMAgEMm2KFARG8riAYKLW+eP4OQCQRrJdh
         aNB1JodA0AA4OAFFnMGnmEoPPp7uILEKqZXoC9DFEbgTE2CNXngDbQloNBG3
         UilxJ0vGFw4uOzQKAAQGfgd6FkwnGniJLS8yky6HKQKFMGZmBHiYdjoBfZcH
         UAFFUSZ+CwOlawBjNasKEFAnsxSluLu8qwkAOw==}

      radiobutton $f.motor.anticlockwise -image $anticlockwise \
         -indicatoron 1 -variable ::usb_focus::widget(motorsens) -value 1 \
         -command "::usb_focus::setRot"
      grid $f.motor.anticlockwise -row 3 -column 2 -padx 5 -sticky w

      label $f.motor.backlash_lab -text "$caption(usb_focus,backlash)"
      grid $f.motor.backlash_lab -row 4 -column 0 -padx 5 -sticky w

      entry $f.motor.backlash -width 5 -justify right \
         -textvariable ::usb_focus::widget(backlash)
      if {$widget(motorsens) == 0} {
         set col 2
      } else {
         set col 1
      }
      grid $f.motor.backlash -row 4 -column $col -padx 5 -pady 5 -sticky w

   grid $f.motor -row 2 -column 0 -padx 10 -pady 5 -sticky w

   #--   frame de la temperature
   labelframe $f.temp -borderwidth 2 -text $caption(usb_focus,temperature)

      #--- Label de la temperature
      label $f.temp.labelTemp -text "$caption(usb_focus,actuelle)"
      grid $f.temp.labelTemp -row 0 -column 0 -padx 5 -pady 10 -sticky w

      #--- Temperature
      label $f.temp.temperature  -textvariable ::usb_focus::widget(temperature)
      grid $f.temp.temperature -row 0 -column 1 -padx 5 -sticky e

      checkbutton $f.temp.mode -text "$caption(usb_focus,tempmode)" \
         -indicatoron 1 -onvalue 1 -offvalue 0 \
         -variable ::usb_focus::widget(tempmode) \
         -command "::usb_focus::setTempMod"
      grid $f.temp.mode -row 1 -column 0 -columnspan 3 -sticky w

      #--- Label du coefficient
      label $f.temp.labelTempCoef -text "$caption(usb_focus,tempcoef)"
      grid $f.temp.labelTempCoef -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- Coefficient
      entry $f.temp.coef -width 5 -justify right \
         -textvariable ::usb_focus::widget(coef)
      grid $f.temp.coef -row 2 -column 1 -padx 5 -sticky e

      #--- Bouton de set coeftemp
      button $f.temp.setcoef -text "$caption(usb_focus,set)" -relief raised \
         -width 4 -command "::usb_focus::setCoefTemp"
      grid $f.temp.setcoef -row 2 -column 2 -padx 5

      #--- Label du coefficient
      label $f.temp.labelTempStep -text "$caption(usb_focus,tempseuil)"
      grid $f.temp.labelTempStep -row 3 -column 0 -padx 5 -pady 5 -sticky w

      #--- Coefficient
      entry $f.temp.seuil -width 5 -justify right \
         -textvariable ::usb_focus::widget(seuil)
      grid $f.temp.seuil -row 3 -column 1 -padx 5 -sticky e

      #--- Bouton de steptemp
      button $f.temp.setseuil -text "$caption(usb_focus,set)" -relief raised \
         -width 4 -command "::usb_focus::setSeuilTemp"
      grid $f.temp.setseuil -row 3 -column 2 -padx 5

   grid $f.temp -row 2 -column 1 -padx 10 -pady 5 -sticky w

   #--   frame de la position
   labelframe $f.pos -borderwidth 2 -text $caption(usb_focus,position)

      #--- Label de la position actuelle
      label $f.pos.labelPosAct -text "$caption(usb_focus,actuelle)"
      grid $f.pos.labelPosAct -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- Position actuelle
      label $f.pos.posact -textvariable ::usb_focus::widget(position)
      grid $f.pos.posact -row 0 -column 1 -padx 5 -sticky e

      #--- Label de la position cible
      label $f.pos.labelTarget -text "$caption(usb_focus,target) "
      grid $f.pos.labelTarget -row 1 -column 0 -padx 5 -sticky w

      #--- Position cible
      entry $f.pos.target -width 6 -justify right \
         -textvariable ::usb_focus::widget(target)
      grid $f.pos.target -row 1 -column 1 -padx 5 -pady 5 -sticky ew

      #--  bouton Goto
      button $f.pos.goto -text "$caption(usb_focus,goto)" -relief raised -width 5 \
         -command "::usb_focus::goto"
      grid $f.pos.goto -row 1 -column 2 -padx 5 -pady 5 -sticky ew

      #--  bouton Stop
      button $f.pos.stop -text "$caption(usb_focus,stopmove)" -relief raised -width 5 \
         -command "::usb_focus::stopMove"
      grid $f.pos.stop -row 1 -column 3 -padx 5 -sticky ew

      #--- Label des pas
      label $f.pos.labelStep -text "$caption(usb_focus,nbstep) "
      grid $f.pos.labelStep -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- nombre de pas
      entry $f.pos.nbstep -width 6 -justify right \
         -textvariable ::usb_focus::widget(nbstep)
      grid $f.pos.nbstep -row 2 -column 1 -padx 5 -sticky w

      #--  bouton -
      button $f.pos.decrease -text "-" -relief raised -width "5" \
         -command "::usb_focus::move -"
      grid $f.pos.decrease -row 2 -column 2 -padx 5 -pady 5 -sticky ew

      #--  bouton +
      button $f.pos.increase -text "+" -relief raised -width "5" \
         -command "::usb_focus::move +"
      grid $f.pos.increase -row 2 -column 3 -padx 5 -pady 5 -sticky ew

   grid $f.pos -row 3 -column 0 -padx 10 -pady 5 -sticky w

   #--- Frame du site web, du bouton Arreter et du checkbutton creer au demarrage
   frame $frm.frame2 -borderwidth 0 -relief flat

      #--- Site web officiel de USB_FOCUS
      label $frm.frame2.lab -text "$caption(usb_focus,site_web)"
      pack $frm.frame2.lab -side top -fill x -pady 2

      set labelName [ ::confEqt::createUrlLabel $frm.frame2 "$caption(usb_focus,site_web_ref)" \
            "$caption(usb_focus,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Bouton Arreter
      button $frm.frame2.stop -text "$caption(usb_focus,arreter)" -relief raised \
         -command { ::usb_focus::deletePlugin }
      pack $frm.frame2.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

      #--- Checkbutton demarrage automatique
      checkbutton $frm.frame2.chk -text "$caption(usb_focus,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(usb_focus,start)
      pack $frm.frame2.chk -side top -padx 3 -pady 3 -fill x

   pack $frm.frame2 -side bottom -fill x

   #--   filtre l'action si le lien n'a pas ete cree ou s'il est nul
   if {![info exists private(linkNo)] || $private(linkNo) ==0} {
      #--- initialise les variables locales
      ::usb_focus::initLocalVar
      #--- inhibe les commandes en attendant la creation du port
      ::usb_focus::setState disabled all
   }
   if {$widget(tempmode) == 1} {
      #--- inhibe les commandes en attendant la creation du port
      ::usb_focus::setState disabled auto
   }

   #--- Mise a jour
   ::usb_focus::onChangeLink

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  brief ne fait rien
#
proc ::usb_focus::onChangeLink { } {
}

#------------------------------------------------------------
## @brief retourne 1 si le focuser possède un contrôle étendu du focus
#  @return 1
#
proc ::usb_focus::possedeControleEtendu { } {
   return "1"
}

#------------------------------------------------------------
## @brief incrémente la vitesse du focus
#  @warning non implementé du fait du sélecteur de vitesses et sa proc \::usb_focus::setSpeed
#
proc ::usb_focus::incrementSpeed { } {
}

#------------------------------------------------------------
#  brief inhibe les commandes lors de la création du widget et de l'arrêt,
#  désinhibe les commandes lors de la création du port
#  param state    normal, disabled
#  param limited  facultatif, (all,auto)
#
proc ::usb_focus::setState { state {limited 0} } {
   variable private

   set w $private(frm).frame1

   #--   traite les saisies
   set entryList [list "motor.maxstep" "motor.backlash" \
      "pos.target" "pos.nbstep" "temp.coef" "temp.seuil"]
   foreach entr $entryList {
      if {[winfo exists $w.$entr]}  {
         if {$state eq "normal"} {
            lassign [split $entr "."] -> param
            #--   cree les binding
            bind $w.$entr <Leave> [list ::usb_focus::verifValue $param]
          } else {
            #--   supprime les binding
            bind $w.$entr <Leave> ""
         }
         $w.$entr configure -state $state
      }
   }

   #--   traite tous les boutons
   set buttonList [list chip.reset motor.setmax motor.speed \
      motor.halfstep motor.fullstep pos.goto pos.stop \
      motor.clockwise motor.anticlockwise pos.decrease \
      pos.increase temp.mode temp.setcoef temp.setseuil]
   foreach but $buttonList {
      if {[winfo exists $w.$but]} {
         $w.$but configure -state $state
      }
   }

   #--   gere les exceptions
   switch -exact  $limited {
      manual {  if {[winfo exists $w.$but]} {
                  #--   inhibe le bouton STOP
                  $w.pos.stop configure -state disabled
                }
             }
      auto   {  if {[winfo exists $w.$but]} {
                  #--   desinhibe le radiobutton du Mode
                  $w.temp.mode configure -state normal
                }
             }
      stop   {  if {[winfo exists $w.$but]} {
                  #--   desinhibe le bouton STOP
                  $w.pos.stop configure -state normal
                }
             }
      all    {  #--   ne fait aucune correction
             }
   }

   update
}

#------------------------------------------------------------
#  brief vérifie une valeur numérique et sa limite, en cas d'erreur émet un message et rétablit l'ancienne valeur
#  param v nom de la variable (maxstep backlash target nbstep seuil)
#
proc ::usb_focus::verifValue { v } {
   variable widget
   variable private
   global caption

   set err 0

   #--   toutes les valeurs (a l'exception de coef) doivent etre positives
   if { $v in [list maxstep backlash target nbstep seuil] && $widget($v) < 0} {
      set err 1
   }

   #--   definit la limite superieure
   switch -exact $v {
      maxstep  { set limite 65535 ; # steps }
      backlash { set limite 4000 ; # steps }
      target   { set limite $widget(maxstep) ; # steps }
      nbstep   { set limite $widget(maxstep) ; # steps }
      coef     { set limite 999 ; # steps/°C }
      seuil    { set limite 999 ; # steps }
   }

   #--   toutes les valeurs absolues doivent etre <= limite
   if {[expr { abs($widget($v)) }] > $limite} {
      set err 1
   }

   if {$err == 0 } {
      #--   memorise la nouvelle valeur
      set private(prev,$v) $widget($v)
   } else {
      tk_messageBox -title $caption(usb_focus,attention)\
         -icon error -type ok -message "[format $caption(usb_focus,limit) $limite]"
      #--   retablit l'ancienne valeur en cas d'erreur
      set widget($v) $private(prev,$v)
   }
}

