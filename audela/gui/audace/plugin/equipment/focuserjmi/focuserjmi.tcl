#
## @file focuserjmi.tcl
#  @brief Gère un focuser sur port parallèle ou quickremote
#  @author Michel PUJOL
#  $Id: focuserjmi.tcl 13290 2016-02-29 20:53:47Z rzachantke $
#

#
# Procedures generiques obligatoires (pour configurer tous les plugins camera, monture, equipement) :
#     initPlugin        : Initialise le namespace (appelee pendant le chargement de ce source)
#     getStartFlag      : Retourne l'indicateur de lancement au demarrage
#     getPluginHelp     : Retourne la documentation htm associee
#     getPluginTitle    : Retourne le titre du plugin dans la langue de l'utilisateur
#     getPluginType     : Retourne le type de plugin
#     getPluginOS       : Retourne les OS sous lesquels le plugin fonctionne
#     getPluginProperty : Retourne la propriete du plugin
#     fillConfigPage    : Affiche la fenetre de configuration de ce plugin
#     configurePlugin   : Configure le plugin
#     stopPlugin        : Arrete le plugin et libere les ressources occupees
#     isReady           : Informe de l'etat de fonctionnement du plugin
#

## namespace focuserjmi
#  @brief Gère un focuser sur port parallèle ou quickremote

namespace eval ::focuserjmi {
   package provide focuserjmi 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] focuserjmi.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::focuserjmi::getPluginTitle { } {
   global caption

   return "$caption(focuserjmi,label)"
}

#------------------------------------------------------------
#  brief    retourne le nom du fichier d'aide principal
#  return  nom du fichier d'aide principal
#
proc ::focuserjmi::getPluginHelp { } {
   return "focuserjmi.htm"
}

#------------------------------------------------------------
#  brief    retourne le type de plugin
#  return   type de plugin
#
proc ::focuserjmi::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux Darwin"
#
proc ::focuserjmi::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief retourne la valeur de la propriété
#  @param propertyName : nom de la propriété
#  @return valeur de la propriété , ou "" si la propriété n'existe pas
#
proc ::focuserjmi::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres du focuser JMI, lancé automatiquement au chargement de ce fichier tcl
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini"
#  - conf(focuserjmi,link)          définit le numero de link associé au focuser attribué par ::confLink::create
#  - conf(focuserjmi,bitStart)      définit le numero du bit du port pour démarrer/arrêter le moteur du focuser
#  - conf(focuserjmi,bitDirection)  définit le numero du bit du port pour indiquer le sens de rotation
#  - conf(focuserjmi,start)         définit le chargement du focuser au lancement d'Audela
#  - conf(focuserjmi,pulseMode)     définit le mode de commande du moteur :
#    * "manual"=rotation du moteur tant que bitStart=1, valeur par défaut
#    * "fixed"=rotation du moteur pendant une durée fixe déterminée par conf(focuserjmi,pulseDuration) .
#  - conf(focuserjmi,pulseDuration) définit la durée de rotation du moteur en secondes.
#    Utilisé uniquement si conf(focuserjmi,pulseMode)="fixed"; Valeur par défaut = 0.1 seconde
#
proc ::focuserjmi::initPlugin { } {
   variable private
   global conf

   #--- Cree les variables dans conf(...) si elles n'existent pas
   if { ! [ info exists conf(focuserjmi,link) ] }         { set conf(focuserjmi,link)         "" }
   if { ! [ info exists conf(focuserjmi,bitStart) ] }     { set conf(focuserjmi,bitStart)     "4" }
   if { ! [ info exists conf(focuserjmi,bitDirection) ] } { set conf(focuserjmi,bitDirection) "5" }
   if { ! [ info exists conf(focuserjmi,start) ] }        { set conf(focuserjmi,start)        "0" }
   if { ! [ info exists conf(focuserjmi,pulseMode) ] }    { set conf(focuserjmi,pulseMode)    "manual" }
   if { ! [ info exists conf(focuserjmi,pulseDuration) ]} { set conf(focuserjmi,pulseDuration)   0.1 }

   #--- variables locales
   set private(frm)     ""
   set private(linkNo) "0"
}

#------------------------------------------------------------
## @brief retourne l'indicateur de lancement au démarrage de Audela
#
proc ::focuserjmi::getStartFlag { } {
   return $::conf(focuserjmi,start)
}

#------------------------------------------------------------
#  brief affiche la frame configuration du focuseur
#
proc ::focuserjmi::fillConfigPage { frm } {
   variable widget
   variable private
   global caption conf

   set private(frm) $frm
   #--- je copie les donnees de conf(...) dans les variables widget(...)
   set widget(link)           $conf(focuserjmi,link)
   set widget(bitStart)       $conf(focuserjmi,bitStart)
   set widget(bitDirection)   $conf(focuserjmi,bitDirection)
   set widget(pulseMode)      $conf(focuserjmi,pulseMode)
   set widget(pulseDuration)  $conf(focuserjmi,pulseDuration)

   #--- Je constitue la liste des liaisons pour le focuser
   set linkList [ ::confLink::getLinkLabels {"parallelport" "serialport" "quickremote" } ]

   #--- Je verifie le contenu de la liste
   if { [llength $linkList ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [lsearch -exact $linkList $widget(link)] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(link) [lindex $linkList 0]
      }
   } else {
      #--- si la liste est vide
      #--- je desactive l'option focuser
      set widget(link) ""
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Label de la liaison
      label $frm.frame1.labelLink -text "$caption(focuserjmi,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky nw -padx 5

      #--- Choix de la liaison
      ComboBox $frm.frame1.link \
         -width [ ::tkutil::lgEntryComboBox $linkList ] \
         -height [ llength $linkList ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::focuserjmi::widget(link) \
         -modifycmd "::focuserjmi::onChangeLink" \
         -values $linkList
      grid $frm.frame1.link -row 0 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Bouton de configuration de la liaison
      button $frm.frame1.configure -text "$caption(focuserjmi,configure)" -relief raised \
         -command {
            ::confLink::run ::focuserjmi::widget(link) {"parallelport" "serialport" "quickremote" } $caption(focuserjmi,label)
         }
      grid $frm.frame1.configure -row 0 -column 2 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix du numero du bit pour le demarrage du moteur
      label $frm.frame1.bitDecrLabel -text "$caption(focuserjmi,bitStart)"
      grid $frm.frame1.bitDecrLabel -row 1 -column 0 -columnspan 1 -rowspan 1 -sticky nw -padx 5

      set bitList [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.frame1.bitStart \
         -width [ ::tkutil::lgEntryComboBox $bitList ] \
         -height [ llength $bitList ] \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::focuserjmi::widget(bitStart) \
         -editable 0                \
         -values $bitList
      grid $frm.frame1.bitStart -row 1 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix du numero du bit pour le sens de rotation du moteur
      label $frm.frame1.bitIncrLabel -text "$caption(focuserjmi,bitDirection)"
      grid $frm.frame1.bitIncrLabel -row 2 -column 0 -columnspan 1 -rowspan 1 -sticky nw -padx 5

      set bitList [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.frame1.bitDirection \
         -width [ ::tkutil::lgEntryComboBox $bitList ] \
         -height [ llength $bitList ]   \
         -relief sunken                 \
         -borderwidth 1                 \
         -textvariable ::focuserjmi::widget(bitDirection) \
         -editable 0                    \
         -values $bitList
      grid $frm.frame1.bitDirection -row 2 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      radiobutton $frm.frame1.manualPulse \
         -indicatoron 1 -text $caption(focuserjmi,manualPulse) -value "manual" \
         -variable ::focuserjmi::widget(pulseMode)
      grid $frm.frame1.manualPulse -row 3 -column 0 -columnspan 1 -rowspan 1 -sticky nw -padx 5

      radiobutton $frm.frame1.fixedPulse \
         -indicatoron 1 -text $caption(focuserjmi,fixedPulse) -value "fixed" \
         -variable ::focuserjmi::widget(pulseMode)
      grid $frm.frame1.fixedPulse -row 4 -column 0 -columnspan 1 -rowspan 1 -sticky nw -padx 5

      LabelEntry $frm.frame1.duration -label "$caption(focuserjmi,duration)  " \
         -labeljustify left -width 6 -justify right \
         -textvariable ::focuserjmi::widget(pulseDuration)
      grid $frm.frame1.duration -row 4 -column 1 -columnspan 2 -rowspan 1 -sticky nw

   pack $frm.frame1 -side top -fill x

   TitleFrame $frm.test -borderwidth 2 -text $caption(focuserjmi,test)
      button $frm.test.decrease -text "-" -relief raised -width "12"
      bind $frm.test.decrease <ButtonPress-1>      { ::focuserjmi::testMove "-" }
      bind $frm.test.decrease <ButtonRelease-1>    { ::focuserjmi::testMove "stop" }
      pack $frm.test.decrease -in [$frm.test getframe] -side left -padx 3 -pady 3 -fill none

      button $frm.test.increase -text "+" -relief raised -width "12"
      bind $frm.test.increase <ButtonPress-1>      { ::focuserjmi::testMove "+" }
      bind $frm.test.increase <ButtonRelease-1>    { ::focuserjmi::testMove "stop" }
      pack $frm.test.increase -in [$frm.test getframe] -side left -padx 3 -pady 3 -fill none

   pack $frm.test -side top -fill x

   #--- Frame du bouton Arreter et du checkbutton creer au demarrage
   frame $frm.start -borderwidth 0 -relief flat

      #--- Bouton Arreter
      button $frm.start.stop -text "$caption(focuserjmi,arreter)" -relief raised \
         -command { ::focuserjmi::deletePlugin }
      pack $frm.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

      #--- Checkbutton demarrage automatique
      checkbutton $frm.start.chk -text "$caption(focuserjmi,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(focuserjmi,start)
      pack $frm.start.chk -side top -padx 3 -pady 3 -fill x

   pack $frm.start -side bottom -fill x

   #--- Mise a jour de liste de bit des liaisons
   ::focuserjmi::onChangeLink
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
## @brief met à jour les données affichées quand on change de liaison
#
proc ::focuserjmi::onChangeLink { } {
   variable widget
   variable private

   set frm $private(frm)
   #--- je rafraichis la liste des bits disponibles sur la laison
   set bitList [ ::confLink::getPluginProperty $widget(link) "bitList" ]
   $frm.frame1.bitStart configure -values $bitList -height [ llength $bitList ] -width [::tkutil::lgEntryComboBox $bitList]
   $frm.frame1.bitDirection configure -values $bitList -height [ llength $bitList ] -width [::tkutil::lgEntryComboBox $bitList]

   if { [lsearch $bitList $widget(bitStart)] == -1 } {
      #--- si le bit n'existe pas dans la liste, je selectionne le premier element de la liste
      set widget(bitStart) [lindex $bitList 0 ]
   }
   if { [lsearch $bitList $widget(bitDirection)] == -1 } {
      #--- si le bit n'existe pas dans la liste, je selectionne le premier element de la liste
      set widget(bitDirection) [lindex $bitList 0 ]
   }

}

#------------------------------------------------------------
## brief configure le plugin
#
proc ::focuserjmi::configurePlugin { } {
   variable widget
   global conf

   #--- copie les variables des widgets dans le tableau conf()
   set conf(focuserjmi,link)           $widget(link)
   set conf(focuserjmi,bitStart)       $widget(bitStart)
   set conf(focuserjmi,bitDirection)   $widget(bitDirection)
   set conf(focuserjmi,pulseMode)      $widget(pulseMode)
   set conf(focuserjmi,pulseDuration)  $widget(pulseDuration)
}

#------------------------------------------------------------
## @brief démarre le plugin
#
#
proc ::focuserjmi::createPlugin { } {
   variable private
   global conf

   #--- je cree la liaison du focuser
   set private(linkNo) [::confLink::create $conf(focuserjmi,link) "focuser" \
     "jmi" "bits $conf(focuserjmi,bitStart),$conf(focuserjmi,bitDirection)"]
}

#------------------------------------------------------------
## @brief arrête le plugin et libère les ressources occupees
#
proc ::focuserjmi::deletePlugin { } {
   variable private
   global conf

   #--- je ferme la liaison du focuser
   ::confLink::delete $conf(focuserjmi,link) "focuser" "jmi"
   set private(linkNo) "0"
   return
}

#------------------------------------------------------------
## @brief informe de l'état de fonctionnement du plugin
#  @return 1 (ready) , 0 (not ready)
#
proc ::focuserjmi::isReady { } {
   variable private

   if { [info exists private(linkNo)] && $private(linkNo) != "0" } {
      return 1
   } else {
      return 0
   }
}

#==============================================================
# ::focuserjmi::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
## @brief gère le mouvement du focus
#  @param command
#  - "-" démarre le mouvement du focus en intra focale
#  - "+" démarre le mouvement du focus en extra focale
#  - "stop" arrête le mouvement
#
proc ::focuserjmi::move { command } {
   variable private

   if { [isReady] == 0 } {
      return
   }
   set linkNo $private(linkNo)

   if { $::conf(focuserjmi,pulseMode) == "manual" } {
      if { "$command" == "-" } {
         link$linkNo bit $::conf(focuserjmi,bitDirection) "0"
         link$linkNo bit $::conf(focuserjmi,bitStart)     "1"
      } elseif { "$command" == "+" } {
         link$linkNo bit $::conf(focuserjmi,bitDirection) "1"
         link$linkNo bit $::conf(focuserjmi,bitStart)     "1"
      } elseif { "$command" == "stop" } {
         link$linkNo bit $::conf(focuserjmi,bitDirection) "0"
         link$linkNo bit $::conf(focuserjmi,bitStart)     "0"
      }
   } else {
      if { "$command" == "-" } {
         link$linkNo bit $::conf(focuserjmi,bitDirection) 0
         link$linkNo bit $::conf(focuserjmi,bitStart)     1 $::conf(focuserjmi,pulseDuration)
      } elseif { "$command" == "+" } {
         link$linkNo bit $::conf(focuserjmi,bitDirection) 1
         link$linkNo bit $::conf(focuserjmi,bitStart)     1 $::conf(focuserjmi,pulseDuration)
      }
   }
}

#------------------------------------------------------------
## @brief test les mouvements en utilisant les variables widget
#  @param command
#  - "-" démarre le mouvement du focus en intra focale
#  - "+" démarre le mouvement du focus en extra focale
#  - "stop" arrête le mouvement
#
proc ::focuserjmi::testMove { command } {
   variable private
   variable widget

   if { [isReady] == 0 } {
      return
   }
   set linkNo $private(linkNo)

   if { $widget(pulseMode) == "manual" } {
      if { "$command" == "-" } {
         link$linkNo bit $widget(bitDirection) "0"
         link$linkNo bit $widget(bitStart)     "1"
      } elseif { "$command" == "+" } {
         link$linkNo bit $widget(bitDirection) "1"
         link$linkNo bit $widget(bitStart)     "1"
      } elseif { "$command" == "stop" } {
         link$linkNo bit $widget(bitDirection) "0"
         link$linkNo bit $widget(bitStart)     "0"
      }
   } else {
      if { "$command" == "-" } {
         link$linkNo bit $widget(bitDirection) "0"
         link$linkNo bit $widget(bitStart)     "1" $widget(pulseDuration)
      } elseif { "$command" == "+" } {
         link$linkNo bit $widget(bitDirection) "1"
         link$linkNo bit $widget(bitStart) "1" $widget(pulseDuration)
      }
   }
}

#------------------------------------------------------------
## @brief envoie le focaliseur à moteur pas à pas à une position prédéterminée (AudeCom)
#  @details non supportée
#
proc ::focuserjmi::goto { blocking } {

}

#------------------------------------------------------------
## @brief incrémente la vitesse du focus et appelle la procédure setSpeed
#  @details non supportée
#
proc ::focuserjmi::incrementSpeed { origin } {

}

#------------------------------------------------------------
## @brief change la vitesse du focus
#  @details non supportée
#
proc ::focuserjmi::setSpeed { { value "0" } } {

}

#------------------------------------------------------------
## @brief retourne 1 si le focuser possède un controle étendu du focus
#  @details non supportée
#  @return tojours 0
#
proc ::focuserjmi::possedeControleEtendu { } {
   set result "0"
}

#------------------------------------------------------------
## @brief retourne la position courante du focuser
#
proc ::focuserjmi::getPosition { } {
   if { [ ::tel::list ] != "" } {
      return [tel$::audace(telNo) focus coord]
   } else {
      ::confTel::run
   }
}

