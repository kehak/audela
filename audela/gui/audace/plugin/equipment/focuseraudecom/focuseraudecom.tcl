#
# Fichier : focuseraudecom.tcl
# Description : Gere le focuser associe a la monture AudeCom
# Auteur : Robert DELMAS
# Mise à jour $Id: focuseraudecom.tcl 9495 2013-05-26 09:56:25Z robertdelmas $
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
#     displayCurrentPosition : Affiche la position courante du focaliseur
#     getPosition            : Retourne la position courante du focaliseur
#     goto                   : Envoie le focaliseur a la position audace(focus,targetFocus)
#     incrementSpeed         : Incremente la vitesse du focaliseur et appelle la procedure setSpeed
#     initPosition           : Initialise la position du focaliseur a moteur pas a pas a 0
#     move                   : Demarre/arrete le mouvement du focaliseur
#     possedeControleEtendu  : Retourne 1 si le focaliseur possede un controle etendu du focus, sinon 0
#     setSpeed               : Change la vitesse du focaliseur
#

namespace eval ::focuseraudecom {
   package provide focuseraudecom 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] focuseraudecom.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::focuseraudecom::initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::focuseraudecom::initPlugin { } {
   #--- Cree les variables dans conf(...) si elles n'existent pas
   #--- pas de variable conf() pour ce focuser
}

#------------------------------------------------------------
#  ::focuseraudecom::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::focuseraudecom::getPluginTitle { } {
   global caption

   return "$caption(focuseraudecom,label)"
}

#------------------------------------------------------------
#  ::focuseraudecom::getPluginHelp
#     retourne la documentation du equipement
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::focuseraudecom::getPluginHelp { } {
   return "focuseraudecom.htm"
}

#------------------------------------------------------------
#  ::focuseraudecom::getPluginType
#     retourne le type de plugin
#
#  return "focuser"
#------------------------------------------------------------
proc ::focuseraudecom::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  ::focuseraudecom::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::focuseraudecom::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  ::focuseraudecom::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::focuseraudecom::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::focuseraudecom::getStartFlag { } {
   #--- le focuser AudeCom est demarre automatiquement a la creation de la monture
   return 0
}

#------------------------------------------------------------
#  ::focuseraudecom::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::focuseraudecom::fillConfigPage { frm } {
   global caption

   #--- Frame pour le label
   frame $frm.frame1 -borderwidth 0 -relief raised

      label $frm.frame1.labelLink -text "$caption(focuseraudecom,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

   pack $frm.frame1 -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  ::focuseraudecom::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuseraudecom::configurePlugin { } {
   #--- copie les variables des widgets dans le tableau conf()
}

#------------------------------------------------------------
#  ::focuseraudecom::createPlugin
#     demarre le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuseraudecom::createPlugin { } {
   global audace

   if { [ info exists audace(focus,speed) ] == "0" } {
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::focuseraudecom::deletePlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison serie
   #--- de la monture AudeCom
   return
}

#------------------------------------------------------------
#  ::focuseraudecom::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::focuseraudecom::isReady { } {
   set result "0"
   #--- le focuser est ready si la monture AudeCom est deja cree
   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "name" ] == "AudeCom" } {
         set result "1"
      }
   }
   return $result
}

#==============================================================
# ::focuseraudecom::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::focuseraudecom::move
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#     si command = "stop" , arrete le mouvement
#------------------------------------------------------------
proc ::focuseraudecom::move { command } {
   global audace conf

   if { [ ::tel::list ] != "" } {
      if { $audace(focus,labelspeed) != "?" } {
         if { $conf(audecom,inv_rot) == "0" } {
            if { $command == "-" } {
              tel$audace(telNo) focus move - $audace(focus,speed)
            } elseif { $command == "+" } {
              tel$audace(telNo) focus move + $audace(focus,speed)
            } elseif { $command == "stop" } {
              tel$audace(telNo) focus stop
              ::focuseraudecom::displayCurrentPosition
            }
         } else {
            if { $command == "-" } {
              tel$audace(telNo) focus move + $audace(focus,speed)
            } elseif { $command == "+" } {
              tel$audace(telNo) focus move - $audace(focus,speed)
            } elseif { $command == "stop" } {
              tel$audace(telNo) focus stop
              ::focuseraudecom::displayCurrentPosition
            }
         }
      }
   } else {
      if { $command != "stop" } {
         ::confTel::run
      }
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::goto
#     envoie le focus a la position audace(focus,targetFocus)
#     et met la nouvelle valeur de la position dans la variable audace(focus,currentFocus)
#------------------------------------------------------------
proc ::focuseraudecom::goto { blocking } {
   global audace conf

   if { [ ::tel::list ] != "" } {
      #--- Direction de focalisation prioritaire : Extrafocale
      if { $conf(audecom,intra_extra) == "1" } {
         if { $audace(focus,targetFocus) > "$audace(focus,currentFocus)" } {
            #--- Envoie la foc a la consigne
            #--- Format de la commande : tel1 focus goto number ?-rate value? ?-blocking boolean?
            tel$audace(telNo) focus goto $audace(focus,targetFocus) -blocking $blocking
         } else {
            #--- Depasse la consigne de $conf(audecom,dep_val) pas pour le rattrapage des jeux
            #--- 250 pas correspondent a 1/2 tour du moteur de focalisation
            set nbpas [ expr $audace(focus,targetFocus)-$conf(audecom,dep_val) ]
            if { $nbpas < "-32767" } {
               set nbpas "-32767"
            }
            tel$audace(telNo) focus goto $nbpas -blocking $blocking
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,targetFocus) -blocking $blocking
         }
      #--- Direction de focalisation prioritaire : Intrafocale
      } else {
         if { $audace(focus,targetFocus) < "$audace(focus,currentFocus)" } {
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,targetFocus) -blocking $blocking
         } else {
            #--- Depasse la consigne de $conf(audecom,dep_val) pas pour le rattrapage des jeux
            #--- 250 pas correspondent a 1/2 tour du moteur de focalisation
            set nbpas [ expr $audace(focus,targetFocus) + $conf(audecom,dep_val) ]
            if { $nbpas > "32767" } {
               set nbpas "32767"
            }
            tel$audace(telNo) focus goto $nbpas -blocking $blocking
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,targetFocus) -blocking $blocking
         }
      }
      #--- Boucle tant que la foc n'est pas arretee
      ::focuseraudecom::displayCurrentPosition
   } else {
      ::confTel::run
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::displayCurrentPosition
#     affiche la position courante du focaliseur a moteur pas a pas audace(focus,currentFocus)
#------------------------------------------------------------
proc ::focuseraudecom::displayCurrentPosition { } {
   global audace

   #--- Boucle tant que la foc n'est pas arretee
   set foc0 [ tel$audace(telNo) focus coord ]
   after 500
   set foc1 [ tel$audace(telNo) focus coord ]
   while { $foc0 != "$foc1" } {
      set foc0 $foc1
      after 500
      set foc1 [ tel$audace(telNo) focus coord ]
   }
   set currentPosition $foc1
   split $currentPosition "\n"
   if { $currentPosition > 0 } {
      set audace(focus,currentFocus) [ string trimleft [ lindex $currentPosition 0 ] 0 ]
   } else {
      set currentPosition [ string trimleft [ lindex $currentPosition 0 ] - ]
      set currentPosition [ string trimleft [ lindex $currentPosition 0 ] 0 ]
      if { $currentPosition == "" } {
         set currentPosition "0"
      }
      set audace(focus,currentFocus) [ expr 0 - $currentPosition ]
   }
   if { $audace(focus,currentFocus) == "" } {
      set audace(focus,currentFocus) "0"
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::initPosition
#     initialise la position du focaliseur a moteur pas a pas a 0
#------------------------------------------------------------
proc ::focuseraudecom::initPosition { } {
   global audace

   if { [ ::tel::list ] != "" } {
      tel$audace(telNo) focus init 0
   } else {
      ::confTel::run
   }
}

#------------------------------------------------------------
#  getPosition
#     retourne la position courante du focuser
#------------------------------------------------------------
proc ::focuseraudecom::getPosition { } {
   if { [ ::tel::list ] != "" } {
      set focPosition [ tel$::audace(telNo) focus coord ]
      split $focPosition "\n"
      if { $focPosition > 0 } {
         set currentPosition [ string trimleft [ lindex $focPosition 0 ] 0 ]
      } else {
         set focPosition [ string trimleft [ lindex $focPosition 0 ] - ]
         set focPosition [ string trimleft [ lindex $focPosition 0 ] 0 ]
         if { $focPosition == "" } {
            set focPosition "0"
         }
         set currentPosition [ expr 0 - $focPosition ]
      }
      return $currentPosition
   } else {
      ::confTel::run
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::incrementSpeed
#     incremente la vitesse du focus et appelle la procedure setSpeed
#------------------------------------------------------------
proc ::focuseraudecom::incrementSpeed { origin } {
   global audace caption

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "product" ] == "audecom" } {
         if { $audace(focus,speed) == "0" } {
            ::focuseraudecom::setSpeed "1"
         } elseif { $audace(focus,speed) == "1" } {
            ::focuseraudecom::setSpeed "0"
         } else {
            ::focuseraudecom::setSpeed "1"
         }
      } elseif { [ ::confTel::getPluginProperty "product" ] == "lx200" } {
         #--- Inactif pour autres montures
         ::focuseraudecom::setSpeed "0"
         set origine [ lindex $origin 0 ]
         if { $origine == "pad" } {
            #--- Message d'alerte venant d'une raquette
            tk_messageBox -title $caption(focuseraudecom,attention) -type ok -icon error \
               -message "$caption(focuseraudecom,msg1)\n$caption(focuseraudecom,msg2)"
            ::confPad::run
         } elseif { $origine == "tool" } {
            #--- Message d'alerte venant d'un outil
            tk_messageBox -title $caption(focuseraudecom,attention) -type ok -icon error \
               -message "$caption(focuseraudecom,msg3)\n$caption(focuseraudecom,msg2)"
            ::confEqt::run ::panneau([ lindex $origin 1 ],focuser) focuser
         }
      } else {
         #--- Inactif pour autres montures
         ::focuseraudecom::setSpeed "0"
      }
   } else {
      ::confTel::run
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::setSpeed
#     change la vitesse du focus
#     met a jour les variables audace(focus,speed), audace(focus,labelspeed)
#     change la vitesse de mouvement de la monture
#------------------------------------------------------------
proc ::focuseraudecom::setSpeed { { value "0" } } {
   global audace caption

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "product" ] == "audecom" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "$caption(focuseraudecom,x5)"
            ::telescope::setSpeed "2"
         } elseif { $value == "0" } {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "$caption(focuseraudecom,x1)"
            ::telescope::setSpeed "1"
         }
      } else {
         set audace(focus,speed) "0"
         set audace(focus,labelspeed) "$caption(focuseraudecom,interro)"
      }
   } else {
      ::confTel::run
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::possedeControleEtendu
#     retourne 1 si le focuser possede un controle etendu du focus
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focuseraudecom::possedeControleEtendu { } {
   set result "1"
}

