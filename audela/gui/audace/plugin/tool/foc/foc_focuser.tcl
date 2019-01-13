#
## @file foc_focuser.tcl
#  @brief Scripts de toutes les commandes concernant les focaliseurs
#  @author Alain KLOTZ, Robert DELMAS et Raymond ZACHANTKE
#  $Id: foc_focuser.tcl 12890 2016-01-24 22:21:52Z rzachantke $
#

#------------------------------------------------------------
## @brief gère la vitesse du focuser
#
proc ::foc::cmdSpeed { } {
   #--- Commande et gestion de l'erreur
   set catchResult [ catch {
      if { $::panneau(foc,focuser) != "" } {
         ::focus::incrementSpeed $::panneau(foc,focuser) "tool foc"
      }
   } ]
   #--- Traitement de l'erreur
   if { $catchResult == "1" } {
      #--- J'ouvre la fenetre de configuration du focuser
      ::confEqt::run ::panneau(foc,focuser) focuser
      #--- J'arrete les acquisitions continues
      ::foc::cmdStop
   }
}

#------------------------------------------------------------
## @brief commande associée au binding avec les mouvements à effectuer
#  @param command { + - stop }
#
proc ::foc::cmdFocus { command } {
   variable This

   #--   Ne doit jamais survenir
   if { $::panneau(foc,focuser) eq "" } {
      return
   }

   #--- Commande et gestion de l'erreur
   set catchResult [ catch {
      if {$command ne "stop"} {
         #--   Inhibe prealablement les boutons "GO CCD" et "RAZ"
         ::foc::setAcqState goto disabled
         ::focus::move $::panneau(foc,focuser) $command
      } else {
         #--   Stop d'abord le focuser
         ::focus::move $::panneau(foc,focuser) $command
         #--   Delai de stabilisation
         after $::conf(foc,attente)
         #--   Relaxe les boutons -/+
         ::foc::relaxeManualCmd
         #--   Libere les boutons "GO CCD" et "RAZ"
         ::foc::setAcqState goto normal
       }
   }]

   #--- Traitement de l'erreur
   if { $catchResult == "1" } {

      #--- J'ouvre la fenetre de configuration du focuser
      ::confEqt::run ::panneau(foc,focuser) focuser

      #--- J'arrete les acquisitions continues
      ::foc::cmdStop

      #--   Dans ce cas libere les boutons "GO CCD" et "RAZ"
      ::foc::setAcqState goto normal
      #--   Relaxe les boutons -/+
      ::foc::relaxeManualCmd
   }
}

#------------------------------------------------------------
#  brief relaxe les boutons -/+ (etat normal =ridge)
#
proc ::foc::relaxeManualCmd { } {
   variable This

   $This.fra4.we.canv1PoliceInvariant configure -relief ridge
   $This.fra4.we.canv2PoliceInvariant configure -relief ridge
   update
}


#------------------------------------------------------------
## @brief commande du bouton "Initialisation" ; pour focuseraudecom seulement
#
proc ::foc::cmdInitFoc { } {
   variable This
   global panneau

   if { [ ::tel::list ] != "" } {
      #--- Gestion graphique du bouton
      $This.fra5.but0 configure -relief groove -text $panneau(foc,initialise)
      update
      #--- Met le compteur de foc a zero et rafraichit les affichages
      ::focus::initPosition $::panneau(foc,focuser)
      set ::audace(focus,currentFocus) "0"
      $This.fra5.current configure -textvariable ::audace(focus,currentFocus)
      set ::audace(focus,targetFocus) ""
      $This.fra5.target configure -textvariable ::audace(focus,targetFocus)
      update
      #--- Gestion graphique du bouton
      $This.fra5.but0 configure -relief raised -text $panneau(foc,initialise)
      update
   } else {
      ::confTel::run
   }
}

#------------------------------------------------------------
## @brief commande du bouton "Aller à" pour focuseraudecom et usb_focus
#
proc ::foc::cmdFocusGoto { } {
   variable This
   global caption panneau

   if {$panneau(foc,focuser) eq "focuseraudecom" && [ ::tel::list ] eq ""} {
      ::confTel::run
   } elseif {$panneau(foc,focuser) eq "usb_focus" && [::usb_focus::isReady] == 0} {
      ::confEqt::run ::confEqt::private(selectedFocuser) focuser "Focaliseur USB_Focus"
   } else {
      #--- Gestion graphique des boutons
      ::foc::setFocusState goto disabled
      ::foc::setAcqState disabled

      #--- Gestion des limites
      lassign [::foc::getLimits $panneau(foc,focuser)] limite1 limite2
      set panneau(foc,end) $limite2
      if {$::audace(focus,targetFocus) >= $limite1 && $::audace(focus,targetFocus) <= $limite2} {
         #--   tout est bon
         #--- Lit la position du compteur de foc
         ::focus::displayCurrentPosition $::panneau(foc,focuser)
         #--- Lance le goto du focaliseur
         ::focus::goto $::panneau(foc,focuser)
      } else {
         #--   il y a une erreur
         if { $::audace(focus,targetFocus) < "$limite1" } {
            set texte [format $caption(foc,limitefoc) $limite1]
         } elseif { $::audace(focus,targetFocus) > "$limite2" } {
            set texte [format $caption(foc,limitefoc) $limite2]
         }
         tk_messageBox -title $caption(foc,attention)\
            -icon error -type ok -message "$texte"
         set ::audace(focus,targetFocus) ""
         update
      }

      #--- Gestion graphique des boutons
      ::foc::setFocusState goto normal
      ::foc::setAcqState stop
   }
}

#------------------------------------------------------------
#  brief gère l'état des boutons +/-, 'Aller à' et choix du focuser
#
#pour tout type de focuser
#
# param op { goto acq }
# param state { normal disabled }
#
proc ::foc::setFocusState { op state } {
   variable This

   switch -exact $op {
      goto { #--  Etat lors d'un GOTO
             #--  Etat du bouton 'Aller à'
             if {$state eq "normal"} {
                $This.fra5.but2 configure -relief raised
             } else {
                $This.fra5.but2 configure -relief sunken
             }
             #--  Inhibition du choix du focuser, de +/-, de stabilisation et de cible
             foreach w [list fra3.focuser.list fra4.we.canv1PoliceInvariant \
                fra4.we.canv2PoliceInvariant fra4.delai fra5.target] {
                $This.$w configure -state $state
             }
           }
     acq  { #--  Etat lors d'une acquisition
            #--  toutes les commandes existantes, a l'exception du bouton Configurer, sont inhibees
            $This.fra3.focuser.list configure -state $state
            foreach cmd [list fra4.we.canv1PoliceInvariant fra4.we.canv2PoliceInvariant \
               fra4.delai fra5.but2 fra5.target fra6.start fra6.end fra6.step fra6.repeat] {
               if {[winfo exists $This.$cmd]} {
                  $This.$cmd configure -state $state
               }
            }
         }
   }
   update
}

#------------------------------------------------------------
## @brief commande pour focuseraudecom seulement
#
proc ::foc::cmdSeTrouveA { } {
   variable This
   global panneau

   if { [ ::tel::list ] != "" } {
      #--- Gestion graphique du bouton
      $This.fra5.but1 configure -relief groove -text $panneau(foc,trouve)
      update
      #--- Lit et affiche la position du compteur de foc
      ::focus::displayCurrentPosition $::panneau(foc,focuser)
      if { $::audace(focus,currentFocus) == "" } {
         set ::audace(focus,currentFocus) "0"
      }
      $This.fra5.current configure -textvariable ::audace(focus,currentFocus)
      update
      #--- Gestion graphique du bouton
      $This.fra5.but1 configure -relief raised -text $panneau(foc,trouve)
      update
   } else {
      ::confTel::run
   }
}

#------------------------------------------------------------
#  brief calcule et effectue le déplacement de focuseraudecom et usb_focus
#
#met à jour les fenêtres du panneau
#
proc ::foc::dynamicFoc { } {
   global panneau

   if {[::usb_focus::isReady] ==1 || [::focuseraudecom::isReady] == 1} {
      set activFocuser 1
   } else {
      set activFocuser 0
   }

   #--   GOTO si la position de depart n'est pas la position courante
   if {$::audace(focus,currentFocus) != $panneau(foc,start)} {

      #--   Fixe la position cible
      set ::audace(focus,targetFocus) $panneau(foc,start)

      if {$activFocuser == 1} {

         #--   Execute le goto
         ::foc::cmdFocusGoto

      } else {

         #--   Cas des focusers non connectes = simulation
         #--   Actualise la position courante
         set ::audace(focus,targetFocus) $panneau(foc,start)
         after 5000
         set ::audace(focus,currentFocus) $::audace(focus,targetFocus)
      }

      #--   delai de stabilisation
      after $::conf(foc,attente)

   } else {
      #--   Pas de deplacement
      set ::audace(focus,targetFocus) $::audace(focus,currentFocus)
   }

   update

   #--   Apres un deplacement reel ou simule
   if {$panneau(foc,menu) ne "$::caption(foc,centrage)"} {

      #--   En mode Fenetrage
      #--   Calcule la position suivante
      set newPosition [expr { $::audace(focus,currentFocus)+$panneau(foc,step) }]
      #--   Si position finale pas atteinte, fixe la prochaine etape avec start
      if {$newPosition <= $panneau(foc,end)} {
         set panneau(foc,start) $newPosition
      }
      #--   Demande l'arret apres l'acquisition si cycle termine
      if {$::audace(focus,currentFocus) == $panneau(foc,start)} {
         set panneau(foc,demande_arret) "1"
      }

   } else {

      #--   Simulation : initialise durant le Centrage
      if {$panneau(foc,simulation) ==1 && $activFocuser ==0} {
         #--   Fixe les valeurs initiales
         lassign [::foc::getLimits $panneau(foc,focuser)] panneau(foc,start) panneau(foc,end)
         set panneau(foc,step) 4000
         set panneau(foc,repeat) 1
      }
   }
   update
}

#-  gestion des limites specifiques a AudeCOM et a USB_Focus -

#------------------------------------------------------------
#  brief analyse les valeurs attente, start, end, step et nb du programme Auto
#
#émet un message en cas d'erreur
#
proc ::foc::analyseAuto { v } {
   global caption panneau

   set err 0
   #--   Verifie qu'il s'agit d'un entier
   if {$v eq "attente"} {
      set value $::conf(foc,attente)
   } else {
      set value $panneau(foc,$v)
   }
   if {[string is integer -strict $value] ==0 } {
      tk_messageBox -title $caption(foc,attention)\
         -icon error -type ok -message "$caption(foc,errInt) "
      return
   }

   #--   Focuser AudeCom ou USB_Focus
   lassign [::foc::getLimits $panneau(foc,focuser)] limite1 limite2
   switch -exact $v {
      start {  if {$panneau(foc,$v) < $limite1 || $panneau(foc,$v) > $limite2} {
                  tk_messageBox -title $caption(foc,attention)\
                     -icon error -type ok -message "$caption(foc,errLim)"
                  return
               }
            }
      end   { if {$panneau(foc,$v) < $panneau(foc,start) || $panneau(foc,$v) > $limite2} {
                  tk_messageBox -title $caption(foc,attention)\
                     -icon error -type ok -message "$caption(foc,errLim)"
              }
            }
   }
}

#------------------------------------------------------------
#  brief retourne les positions limites du focuser
#  param focuser nom du focuser
#  return liste des limites basse et hautes
#
proc ::foc::getLimits { focuser } {

   #--   valeurs par defaut pour la simulation
   set limite1 0 ; set limite2 65535

   if {$focuser eq "focuseraudecom"} {
      set limite1 -32767 ; set limite2 32767
   } elseif {$focuser eq "usb_focus"} {
      if {[::usb_focus::isReady] == 1} {
         set limite2 $::usb_focus::widget(maxstep)
      }
   }

   return [list $limite1 $limite2]
}

