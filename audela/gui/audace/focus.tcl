#
## @file focus.tcl
#  @brief centralise les commandes du focus du télescope
#  @author Michel PUJOL
#  $Id: focus.tcl 12948 2016-01-26 21:47:47Z rzachantke $
#

## namespace focus
#  @brief centralise les commandes du focus du télescope
#  @warning focuserLabel (nom du focuser) est le spacename du focuser sans ::

namespace eval ::focus {

}

#------------------------------------------------------------
# @brief initialisation de variables
#
proc ::focus::init { } {
   global audace

   #--- Initialisation
   set audace(focus,currentFocus) "0"
   set audace(focus,targetFocus)  ""
}

#------------------------------------------------------------
## @brief démarre/arrête le mouvement du focuseur
#  @code exemple ::focus::move "focuserquickr" "+"
#  @endcode
#  @param focuserLabel nom du focuser
#  @param command "-" "+" ou "stop"
#  @details
#  - si command = "-" , démarre le mouvement du focus en intra focale
#  - si command = "+" , démarre le mouvement du focus en extra focale
#  - si command = "stop" , arrête le mouvement
#
proc ::focus::move { focuserLabel command } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::move $command
      if { [::focus::possedeControleEtendu $focuserLabel] == 1 } {
         set ::audace(focus,currentFocus) [getPosition $focuserLabel]
      }
   }
}

#------------------------------------------------------------
## @brief incrémente la vitesse du focus et appelle la procédure setSpeed
#  @param focuserLabel nom du focuser
#  @param origin origine de l'action (pad ou tool)
#
proc ::focus::incrementSpeed { focuserLabel origin } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::incrementSpeed $origin
   }
}

#------------------------------------------------------------
## @brief change la vitesse du focus
#  @param focuserLabel nom du focuser
#  @param value valeur de la vitesse
#
proc ::focus::setSpeed { focuserLabel { value "0" } } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::setSpeed $value
   }
}

#------------------------------------------------------------
## @brief envoie le focaliseur à moteur pas à pas a une position prédeterminée (AudeCom + USB_Foc)
#  @param focuserLabel nom du focuser
#  @param blocking     0 (par défaut) ou 1
#  @param gotoButton   "" (par défaut) ou valeur
#
proc ::focus::goto { focuserLabel { blocking 0 } { gotoButton "" } } {
   variable private
   if { "$focuserLabel" != "" } {

      #--- Gestion des boutons Goto et Match
      if { $gotoButton != "" } {
         $gotoButton configure -state disabled
         update
      }

      set catchError [catch {
         ::$focuserLabel\::goto $blocking

         if { $blocking == 0 } {
            #--- Boucle tant que le focus n'est pas arretee (si on n'utilise pas le mode bloquant du goto)
            set position [::focus::getPosition $focuserLabel]
            #--- j'attends que le focus commence a bouger
            #--- car sinon la boucle de surveillance va considerer que les
            #--- coordonnees n'ont pas changé et va s'arreter immediatement
            after 500
            set private(gotoIsRunning) 1
            set derniereBoucle [ ::focus::surveille_goto $focuserLabel $position ]
            if { $derniereBoucle == 1 } {
               #--- j'attends que la variable soit remise a zero
               vwait ::focus::private(gotoIsRunning)
            }
         } else {
            displayCurrentPosition $focuserLabel
         }
      }]

      #--- je reactive du bouton
      if { $gotoButton != "" } {
         $gotoButton configure -state normal
         update
      }

      if { $catchError != 0 } {
        error $::errorInfo
     }
   }
}

#------------------------------------------------------------
## @brief surveille si la fonction goto est active
#  @param focuserLabel nom du focuser
#  @param position     position du focuser
#  @return 0 si dernière boucle, 1 si nouvelle boucle est lancée
#
proc ::focus::surveille_goto { focuserLabel position } {
   variable private

   set position1 [::focus::getPosition $focuserLabel]
   if { $position1 == "" } {
      #--- j'arrete la boucle de surveillance car les coordonnees n'ont pas pu etre recuperees
      set private(gotoIsRunning) "0"
      return 0
   }
   if { [expr abs($position - $position1) ] > 0.1 } {
      after 500 ::focus::surveille_goto $focuserLabel $position1
      #--- je retourne 1 pour signaler que ce n'est pas pas la derniere boucle
      return 1
   } else {
      #--- j'arrete la surveillance car le GOTO est termine
      set private(gotoIsRunning) "0"
      return 0
   }
}

#------------------------------------------------------------
## @brief affiche la position du moteur pas a pas si elle existe (AudeCom + USB_Foc)
#  @param focuserLabel nom du focuser
#
proc ::focus::displayCurrentPosition { focuserLabel } {
   if { "$focuserLabel" != "" } {
      if { [ info command ::$focuserLabel\::displayCurrentPosition ] != "" } {
         ::$focuserLabel\::displayCurrentPosition
      }
   }
}

#------------------------------------------------------------
## @brief initialise la position du focuser a 0
#  @param focuserLabel nom du focuser
#
proc ::focus::initPosition { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::initPosition
   }
}

#------------------------------------------------------------
## @brief affiche la position du moteur pas à pas si elle existe
#  @param focuserLabel nom du focuser
#
proc ::focus::getPosition { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::getPosition
   }
}

#------------------------------------------------------------
## @brief recherche si le focuser possède un contôle étendu
#  @param focuserLabel nom du focuser
#  @return 1 si le télescope possède un controle étendu du focus (AudeCom + USB_Foc), sinon 0
#
proc ::focus::possedeControleEtendu { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::possedeControleEtendu
   }
}

::focus::init

