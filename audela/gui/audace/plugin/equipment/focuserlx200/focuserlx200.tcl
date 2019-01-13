#
## @file focuserlx200.tcl
#  @brief Gère le focuser associé à la monture LX200
#  @author Michel PUJOL
#  $Id: focuserlx200.tcl 13287 2016-02-29 11:35:40Z rzachantke $
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
# Procedures specifiques a ce plugin :
#

## namespace focuserlx200
#  @brief Gère le focuser associé à la monture LX200

namespace eval ::focuserlx200 {
   package provide focuserlx200 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] focuserlx200.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
## @brief initialise le plugin
#  @details pas de variable conf() pour ce focuser
proc ::focuserlx200::initPlugin { } {

}

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::focuserlx200::getPluginTitle { } {
   global caption

   return "$caption(focuserlx200,label)"
}

#------------------------------------------------------------
#  brief    retourne le nom du fichier d'aide principal
#  return  nom du fichier d'aide principal
#
proc ::focuserlx200::getPluginHelp { } {
   return "focuserlx200.htm"
}

#------------------------------------------------------------
#  brief    retourne le type de plugin
#  return   type de plugin
#
proc ::focuserlx200::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux Darwin"
#
proc ::focuserlx200::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#  @details  cet outil s'ouvre dans un onglet du menu Equipements
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::focuserlx200::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
      default  { return "" }
   }
}

#------------------------------------------------------------
## @brief    retourne l'indicateur de lancement au démarrage de Audela
#  @details  le focuser LX200 est démarré automatiquement à la creation de la monture
#  @return   toujours "0"
#
proc ::focuserlx200::getStartFlag { } {
   return 0
}

#------------------------------------------------------------
#  brief affiche la frame configuration du focuseur
#
proc ::focuserlx200::fillConfigPage { frm } {
   global caption

   #--- Frame pour le label
   frame $frm.frame1 -borderwidth 0 -relief raised

      label $frm.frame1.labelLink -text "$caption(focuserlx200,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

   pack $frm.frame1 -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  brief charge les variables locales dans des variables de configuration
#  details ne sauve rien du tout
#
proc ::focuserlx200::configurePlugin { } {

}

#------------------------------------------------------------
## @brief démarre le plugin
#
proc ::focuserlx200::createPlugin { } {
   global audace

   if { [ info exists audace(focus,speed) ] == "0" } {
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
## @brief  arrête le plugin et libère les ressources
#  @details il n'y a rien à faire pour ce focuser car il utilise la liaison série
#  de la monture LX200
#
proc ::focuserlx200::deletePlugin { } {
   return
}

#------------------------------------------------------------
## @brief   informe de l'état de fonctionnement du plugin
#  @return  1 (ready) , 0 (not ready)
#
proc ::focuserlx200::isReady { } {
   set result "0"
   #--- le focuser est ready si la monture LX200 est deja cree
   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "name" ] == "LX200" } {
         set result "1"
      }
   }
   return $result
}

#==============================================================
# ::focuserlx200::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
## @brief gère le mouvement du focuser
#  @param command
#  - "-" démarre le mouvement du focus en intra focale
#  - "+" démarre le mouvement du focus en extra focale
#  - "stop" arrête le mouvement
#
proc ::focuserlx200::move { command } {
   global audace

   if { [ ::tel::list ] != "" } {
      if { $audace(focus,labelspeed) != "?" } {
         if { $command == "-" } {
           tel$audace(telNo) focus move - $audace(focus,speed)
         } elseif { $command == "+" } {
           tel$audace(telNo) focus move + $audace(focus,speed)
         } elseif { $command == "stop" } {
           tel$audace(telNo) focus stop
         }
      }
   } else {
      if { $command != "stop" } {
         ::confTel::run
      }
   }
}

#------------------------------------------------------------
## @brief envoie le focaliseur à moteur pas à pas à une position prédéterminée (AudeCom)
#  @details non supportée
#
proc ::focuserlx200::goto { blocking } {

}

#------------------------------------------------------------
## @brief incrémente la vitesse du focus et appelle la procedure setSpeed
#  @param origin ?
#
proc ::focuserlx200::incrementSpeed { origin } {
   global audace caption

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "product" ] == "lx200" } {
         if { $audace(focus,speed) == "0" } {
            ::focuserlx200::setSpeed "1"
         } elseif { $audace(focus,speed) == "1" } {
            ::focuserlx200::setSpeed "0"
         } else {
            ::focuserlx200::setSpeed "1"
         }
      } elseif { [ ::confTel::getPluginProperty "product" ] == "audecom" } {
         #--- Inactif pour autres montures
         ::focuserlx200::setSpeed "0"
         set origine [ lindex $origin 0 ]
        if { $origine == "pad" } {
            #--- Message d'alerte venant d'une raquette
            tk_messageBox -title $caption(focuserlx200,attention) -type ok -icon error \
               -message "$caption(focuserlx200,msg1)\n$caption(focuserlx200,msg2)"
            ::confPad::run
         } elseif { $origine == "tool" } {
            #--- Message d'alerte venant d'un outil
            tk_messageBox -title $caption(focuserlx200,attention) -type ok -icon error \
               -message "$caption(focuserlx200,msg3)\n$caption(focuserlx200,msg2)"
            ::confEqt::run ::panneau([ lindex $origin 1 ],focuser) focuser
         }
      } else {
         #--- Inactif pour autres montures
         ::focuserlx200::setSpeed "0"
      }
   } else {
      ::confTel::run
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
## @brief change la vitesse du focus
#  @details met à jour les variables audace(focus,speed), audace(focus,labelspeed)
#  change la vitesse de mouvement de la monture
#  @param value 0 par défaut
#
proc ::focuserlx200::setSpeed { { value "0" } } {
   global audace caption

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "product" ] == "lx200" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "2"
            ::telescope::setSpeed "2"
         } elseif { $value == "0" } {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "1"
            ::telescope::setSpeed "1"
         }
      } else {
         set audace(focus,speed) "0"
         set audace(focus,labelspeed) "$caption(focuserlx200,interro)"
      }
   } else {
      ::confTel::run
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
## @brief retourne 1 si le focuser possède un contrôle étendu du focus
#  @return 0
#
proc ::focuserlx200::possedeControleEtendu { } {
   set result "0"
}

#------------------------------------------------------------
## @brief retourne la position courante du focuser
#
proc ::focuserlx200::getPosition { } {
   if { [ ::tel::list ] != "" } {
      return [tel$::audace(telNo) focus coord]
   } else {
      ::confTel::run
   }
}

