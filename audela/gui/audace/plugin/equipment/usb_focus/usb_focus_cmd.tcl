#
## @file usb_focus_cmd.tcl
#  @brief Commandes du focuser USB_focus sur port série
#  @author Raymond ZACHANTKE
#  $Id: usb_focus_cmd.tcl 12957 2016-01-27 19:09:46Z rzachantke $
#

#==============================================================
# ::usb_focus::Procedures specifiques du plugin
#==============================================================

#  ::usb_focus::reset
#  ::usb_focus::setMaxPos
#  ::usb_focus::setSpeed
#  ::usb_focus::setStepIncr
#  ::usb_focus::setRot
#  ::usb_focus::setCoefTemp
#  ::usb_focus::setSeuilTemp
#  ::usb_focus::setTempMod
#  ::usb_focus::setManualMode
#  ::usb_focus::setAutoMode
#  ::usb_focus::goto
#  ::usb_focus::move
#  ::usb_focus::stopMove
#  ::usb_focus::getPosition
#  ::usb_focus::getTemperature
#  ::usb_focus::getTempCoef
#  ::usb_focus::refreshAll
#  ::usb_focus::createPort
#  ::usb_focus::waitAnswer
#  ::usb_focus::readPort
#  ::usb_focus::closePort
#  ::usb_focus::initFromChip
#  ::usb_focus::writeControl_1
#  ::usb_focus::writeControl_2
#  ::usb_focus::trimZero

#  Notes :
#  1) la liaison est asynchrone et gérée par fileevent
#  2) ::usb_focus::createPort retourne {0|1} selon l'échec ou la reussite
#  3) ::usb_focus::waitAnswer retourne la valeur lue sur le port serie
#     pour exploitation par les commandes de decodage et d'affichage des valeurs
#  4) les microcommandes SEERAZ, Mnnnnn, SMO00n, SMAnnn, SMSTPF, SMSTPD, SMROTH, SMROTT
#     ne retournent rien; SGETAL est appellee pour rafraichir les valeurs concernées
#  5) les valeurs numériques transmises au chip ont un format fixe et sont précédées avec des 0
#     ces 0 sont otés pour l'affichage et rétablis pour le codage
#  6) les commandes qui prennent un temps appréciable (move, goto, setTempMod)
#     provoquent l'inhibtion des commandes; elles sont libérées à la fin de la proc

#------------------------------------------------------------
#  brief    commade du bouton RESET, rétablit les paramètres par defaut du contrôleur
#
proc ::usb_focus::reset { } {
   variable widget
   variable private

   #--   liste des valeurs par defaut du chip, dans l'ordre :
   #  motorsens stepincr motorspeed coef seuil version maxstep
   set private(attendu) [list 0 1 2 015 010 1217 65535]

   set private(command) "SEERAZ"
   ::usb_focus::writeControl_1
}

#------------------------------------------------------------
#  brief    commande du bouton SET, définit la position maximale
#
proc ::usb_focus::setMaxPos { } {
   variable widget
   variable private

   #--   formate le nombre de pas avec le 0 necessaires
   set formatValue [format "%05d" $widget(maxstep)]

   set private(attendu) [lreplace $private(attendu) 6 6 $formatValue]

   set private(command) "M$formatValue"
   ::usb_focus::writeControl_1
}

#------------------------------------------------------------
## @brief commande de la combox de sélection de la vitesse, change la vitesse du focus
#
proc ::usb_focus::setSpeed { } {
   variable widget
   variable private

   set private(attendu) [lreplace $private(attendu) 2 2 $widget(motorspeed)]

   set private(command) "SMO00$widget(motorspeed)"
   ::usb_focus::writeControl_1
}

#------------------------------------------------------------
#  brief    commande de la combox de sélection de l'incrément (half ou full step)
#
proc ::usb_focus::setStepIncr { } {
   variable widget
   variable private

   set private(attendu) [lreplace $private(attendu) 1 1 $widget(stepincr)]

   #--   commute half/full step
   switch -exact $widget(stepincr) {
      0  { set private(command) "SMSTPF" ; # full step }
      1  { set private(command) "SMSTPD" ; # half step }
   }
   ::usb_focus::writeControl_1
}

#------------------------------------------------------------
#  brief    commande des radiobutton de sélection du sens de rotation du moteur
#
proc ::usb_focus::setRot { } {
   variable widget
   variable private

   set private(attendu) [lreplace $private(attendu) 0 0 $widget(motorsens)]

   #--   commute le sens horaire/antihoraire
   switch -exact $widget(motorsens) {
      0  { set private(command) "SMROTH" ; # clockwise
           set col 2 ; # backlash dans la colonne 2
         }

      1  { set private(command) "SMROTT" ; # anticlockwise
           set col 1 ; # backlash dans la colonne 1
         }
   }
   ::usb_focus::writeControl_1

   #--   modifie la position de la saisie du backlash
   grid $private(frm).frame1.motor.backlash -column $col
   update
}

#------------------------------------------------------------
#  brief    commande du bouton SET du coefficient de compensation lié à la température
#
proc ::usb_focus::setCoefTemp { } {
   variable widget
   variable private

   if {$widget(coef) < 0} {
      set sign 0
   } else {
      set sign 1
   }

   set n [format "%03d" [expr { abs($widget(coef)) }]]
   set private(command) "FLX$n"
   ::usb_focus::writePort

   after 50
   set private(command) "FZSIG$sign"
   ::usb_focus::writePort

   ::usb_focus::getTempCoef

   if {$widget(coef) != $private(prev,coef)} {
      ::console::affiche_resultat "setCoefTemp : error\n\n"
   }
}

#------------------------------------------------------------
#  brief    fixe le seuil min de compensation
#
proc ::usb_focus::setSeuilTemp { } {
   variable widget
   variable private

   set private(prev,seuil) $widget(seuil)

   set n [format "%03d" $widget(seuil)]
   set private(attendu) [lreplace $private(attendu) 4 4 $n]
   set private(command) "SMA$n"
   ::usb_focus::writeControl_1

   if {$widget(seuil) != $private(prev,seuil)} {
      ::console::affiche_resultat "setSeuilTemp : error\n\n"
   }
}

#------------------------------------------------------------
#  brief    commande du radiobutton de sélection du mode manuel/automatique
#
proc ::usb_focus::setTempMod { } {
   variable widget

   #--   selectionne la commande
   switch -exact $widget(tempmode) {
      0  {  ::usb_focus::setManualMode }
      1  {  ::usb_focus::setAutoMode }
   }
}

#------------------------------------------------------------
#  brief    stoppe le mode auto
#
proc ::usb_focus::setManualMode { } {
   variable private

   set private(command) "FMANUA"
   ::usb_focus::writeControl_2
}

#------------------------------------------------------------
#  brief    démarre le mode de compensation automatique
#
proc ::usb_focus::setAutoMode { } {
   variable widget
   variable private
   global audace caption

   #--   inhibe les commandes a l'exception du Mode
   ::usb_focus::setState disabled auto

   set private(command) "FAUTOM"
   ::usb_focus::writePort

   #--   reponse attendue == "P=wxyz LFCRT=+/-xy.z LFCR"; longueur 21 car
   set answer [::usb_focus::waitAnswer 21]
   set widget(position) [string range $answer 0 4]
   set widget(temperature) [format $caption(usb_focus,deg_c) [string range $answer 5 end]]

   #--   recopie la valeur vers la variable audace apres avoir ote les 0 inutiles
   set audace(focus,currentFocus) [::usb_focus::trimZero $widget(position)]
}

#------------------------------------------------------------
#  brief    commande du bouton GOTO, envoie le focaliseur à moteur pas à pas à une position prédéterminée ; si nécessaire, le déplacement est corrigé pour rester dans les limites {0|maxstep)
#  param    blocking (0 ou 1), facultatif
#
proc ::usb_focus::goto { {blocking 0} } {
   variable widget
   variable private
   global audace panneau

   if {[info exists panneau(foc,focuser)] && $panneau(foc,focuser) eq "usb_focus"} {
      #--   recopie la valeur de la cible
      set widget(target) $audace(focus,targetFocus)
   }

   set d $widget(target)

   #--   arrete si la valeur est vide
   if {$d eq ""} {return}

   #--   inhibe les commandes, a l'exception du bouton STOP
   ::usb_focus::setState disabled stop

   set position [::usb_focus::trimZero $widget(position)]
   if {$d > $position} {
      #---  pas de backlash
      set dif [expr { $d-$position }]
      set private(command) O[format "%05d" $dif]
      ::usb_focus::applyGoto $blocking
   } else {
      #---  avec backlash
      set dif [expr { $position-$d+$widget(backlash) }]
      if {$dif < 0} {set dif 0}
      set private(command) I[format "%05d" $dif]
      ::usb_focus::applyGoto $blocking
      after 100
      set position [::usb_focus::trimZero $widget(position)]
      set dif [expr { $d-$position }]
      set private(command) O[format "%05d" $dif]
      ::usb_focus::applyGoto $blocking
   }

   #--   libere toutes les commandes, a l'exception du bouton STOP
   ::usb_focus::setState normal manual

   #::usb_focus::writeControl_2 $blocking
}

#------------------------------------------------------------
#  brief    exécute le GOTO
#  param    blocking (0 ou 1)
#
proc ::usb_focus::applyGoto { blocking } {
   variable widget

   ::usb_focus::writePort

   #--   reponse attendue "*LFCR" ou "!LFCR" ; longueur 3 car
   if {[::usb_focus::waitAnswer 3] in [list "*" "!"]} {
      ::usb_focus::getPosition
   }

   if {$blocking == 1} {
      while {1==1} {
         after 100
         ::usb_focus::getPosition
         if {[::usb_focus::trimZero $widget(position)] == $widget(target)} {
            break
         }
      }
   }
}

#------------------------------------------------------------
#  brief    commandes des boutons + - et stop, dans les limites {0 | maxstep)
#  param    command (+ - stop}
#
proc ::usb_focus::move { command } {
   variable widget
   variable private

   #--   commande speciale pour Focalisation
   if {$command eq "stop"} {
      ::usb_focus::stopMove
      return
   }

   set d $widget(nbstep)
   set position [::usb_focus::trimZero $widget(position)]

   if {$command eq "+"} {
      set nbstepMax [expr { $widget(maxstep)-$position }]
      if {$d > $nbstepMax} {
         set widget(nbstep) $nbstepMax
      }
      set private(command) O[format "%05d" $widget(nbstep)]
   } elseif {$command eq "-"} {
      set nbstepMax [expr { abs(0-$position) }]
      if {$d > $nbstepMax} {
         set widget(nbstep) $nbstepMax
      }
      set private(command) I[format "%05d" $widget(nbstep)]
   }
   ::usb_focus::writeControl_2
}

#------------------------------------------------------------
#  brief    commande du bouton STOP, arrête le mouvement
#
proc ::usb_focus::stopMove { } {
   variable private

   set private(command) "FQUITx"
   ::usb_focus::writePort

   #--   reponse attendue == "*LFCR" ; longueur 3 car
   if {[::usb_focus::waitAnswer 3] eq "*"} {
      ::usb_focus::getPosition
   }
   #--   libere toutes les commandes, a l'exception du bouton STOP
   ::usb_focus::setState normal manual
}

#------------------------------------------------------------
#  brief    demande la position
#
proc ::usb_focus::getPosition { } {
   variable widget
   variable private
   global audace

   set private(command) "FPOSRO"
   ::usb_focus::writePort

   #--   reponse attendue == "P=vwxyz LFCR" ; longueur 9 car
   set widget(position) [::usb_focus::waitAnswer 9]

   #--   recopie la valeur vers la variable audace apres avoir ote les 0 inutiles
   set audace(focus,currentFocus) [::usb_focus::trimZero $widget(position)]
}

#------------------------------------------------------------
#  brief    demande la température
#
proc ::usb_focus::getTemperature { } {
   variable widget
   variable private

   set private(command) "FTMPRO"
   ::usb_focus::writePort

   #--   reponse attendue == "T=+/-xy.z LFCR" ; longueur 10 car
   set widget(temperature) "[::usb_focus::waitAnswer 10] °C"
}

#------------------------------------------------------------
#  brief    demande le coefficient de compensation
#
proc ::usb_focus::getTempCoef {} {
   variable widget
   variable private

   #-- demande la valeur aboslue du coef
   set private(command) "FREADA"
   ::usb_focus::writePort

   #--   reponse attendue == "A=0xyz" : longueur 6 car
   set coef [string trimleft [::usb_focus::waitAnswer 6] 0]

   #-- demande lle signe
   set private(command) "FTxxxA"
   ::usb_focus::writePort

   #--   reponse attendue == "A=x" : longueur 3 car
   if {[::usb_focus::waitAnswer 3] == 1} {
      set widget(coef) "+$coef"
   } else {
      set widget(coef) "-$coef"
   }
   set private(prev,coef) $widget(coef)
}

#------------------------------------------------------------
#  brief    demande les parametres de configuration
#
proc ::usb_focus::refreshAll { } {
   variable widget
   variable private

   set private(command) "SGETAL"
   ::usb_focus::writePort

   #--   reponse attendue == longueur 28 car
   set private(values) [string map {"-" " "} [::usb_focus::waitAnswer 28]]

   #--   verifie qu'il n'y a pas d'erreur
   package require struct::set
   if {[::usb_focus::isReady] == 0} {
      set private(attendu) $private(values)
   } else {
      if {![::struct::set equal $private(attendu) $private(values)]} {
         #--   message console si une commande n'a pas ete executee
         ::console::affiche_resultat "\nattendu $private(attendu)\nobtenu $private(values)\n"
      }
   }

   #--   formate les valeurs
   lassign $private(values) widget(motorsens) widget(stepincr) widget(motorspeed) \
      coef seuil widget(version) maxstep

   #--   ote les 0 inutiles
   set widget(maxstep) [::usb_focus::trimZero $maxstep]
   set widget(seuil) [::usb_focus::trimZero $seuil]

   #--   rafraichit ces variables
   set private(prev,maxstep) $widget(maxstep)
   set private(prev,seuil) $widget(seuil)

   #--   affiche la position, la temperature et le coef de compensation
   ::usb_focus::getTempCoef
   ::usb_focus::getPosition
   ::usb_focus::getTemperature
}

#------------------------------------------------------------
#  brief    établit la liaison avec le port COM
#  param    port
#  return   0 (échec) ou 1 (ok)
#
proc ::usb_focus::createPort { port } {
   #variable widget
   variable private

   if { $::tcl_platform(platform) == "unix" } {
      set port [ string tolower [ string trim $port ] ]
      set num [ expr [ string index $port 3 ] - 1 ]
      set port /dev/ttyS$num
   }

  if {[catch {
      set tty [open $port r+]
      set private(tty) $tty
      chan configure $tty -mode "19200,n,8,1" \
         -blocking 0 -buffering none
      } errmsg]} {

      #--   message d'erreur
      ::console::affiche_resultat "error : $errmsg\n"

      return 0
  } else {
      ::usb_focus::initFromChip
      return 1
  }
}

#------------------------------------------------------------
#  brief    envoie une commande sur le port serie
#
proc ::usb_focus::writePort { } {
   variable private

   chan puts -nonewline $private(tty) $private(command)
   chan flush $private(tty)
}

#------------------------------------------------------------
#  brief    lit n caracteres sur le port série de manière asynchrone, appellée par toutes les commandes qui demandent réponse
#  param     car nombre de caractères
#  return    réponse du processeur
#
proc ::usb_focus::waitAnswer { car } {
   variable private
   global usb_focus_answer

   set usb_focus_answer ""
   fileevent $private(tty) readable "::usb_focus::readPort $private(tty) $car"
   vwait usb_focus_answer
   return $usb_focus_answer
}

#------------------------------------------------------------
#  brief    lit n caracteres sur le port serie
#  param     tty
#  param     nbcar nombre de caractères
#
proc ::usb_focus::readPort { tty nbcar } {
   variable private
   global usb_focus_answer

   set entities [list "\n" "" "\r" "" A "" T "" P "" C "" = "" " " ""]

   chan configure $tty -blocking 1
   #--   ote les LF et CR dans l'ensemble du message
   set answer [chan read $tty $nbcar]
   chan configure $tty -blocking 0
   if {$answer eq "A=err"} {
      ::console::affiche_resultat "USB_Focus error\n"
   }
   set usb_focus_answer [string map $entities $answer]

   #--   debug
   #::console::affiche_resultat "$private(command) --> $usb_focus_answer \
   #   [string length $answer] [string length $usb_focus_answer]\n"
}

#------------------------------------------------------------
#  brief    ferme la liaison
#
proc ::usb_focus::closePort { } {
   variable private

  if {$private(tty) ne ""} {
      chan close $private(tty)
   }
}

#------------------------------------------------------------
#  brief    met à jour la fenêtre avec les valeurs lues dans le chip
#
proc ::usb_focus::initFromChip {} {
   variable private

   ::usb_focus::setManualMode
   ::usb_focus::refreshAll
}

#------------------------------------------------------------
#  brief    contrôle avec les parametres de conf de usb_focus et la position
#
proc ::usb_focus::writeControl_1 { } {
   ::usb_focus::writePort
   ::usb_focus::refreshAll
}

#------------------------------------------------------------
#  brief    contrôle la position
#
proc ::usb_focus::writeControl_2 { } {

   #--   inhibe les commandes, a l'exception du bouton STOP
   ::usb_focus::setState disabled stop

   ::usb_focus::writePort

   #--   reponse attendue "*LFCR" ou "!LFCR" ; longueur 3 car
   if {[::usb_focus::waitAnswer 3] in [list "*" "!"]} {
      ::usb_focus::getPosition
   }

   #--   libere toutes les commandes, a l'exception du bouton STOP
   ::usb_focus::setState normal manual
}

#------------------------------------------------------------
#  brief    ôte les zéro inutiles
#  param    val valeur à traiter
#  return   valeur sans les 0
#
proc ::usb_focus::trimZero { val } {

   set val "[string trimleft $val 0]"
   if {[llength $val] ==0} {
      set val  0
   }

   return $val
}


