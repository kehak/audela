## @file eye.funcs.joystick.tcl
#  @brief     Projet EYE : Pilotage d un chercheur electronique asservissant une monture
#  @brief     Fonctionnalité d'une raquette de commande
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2016
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool eye eye.funcs.joystick.tcl]
#  @endcode
#  @note Mise a jour $Id: eye.funcs.joystick.tcl 12683 2016-01-16 00:31:17Z fredvachier $

   #============================================================
   # @brief  Connection au joystick
   # @return void
   #
   proc ::eye::joystick_connect { } {

      joystick_open
      ::eye::joystick_eventloop
      return
   }

   #============================================================
   # @brief  Fermeture de la Connection au joystick
   # @return void
   #
   proc ::eye::joystick_close { } {

      global x
      global audace
      set x 1
      fileevent $audace(joystick,channel) readable ""
      after 500
      joystick_close
      return
   }

   #============================================================
   # @brief  Lancement de la boucle d'evenement
   # @return void
   #
   proc ::eye::joystick_eventloop {  } {

      global x
      global audace
      fileevent $audace(joystick,channel) readable [list ::eye::joystick_event $audace(joystick,channel)]
      vwait x
      return
    }

   #============================================================
   # @brief  Apparition d'un evenement sur le channel
   # @param  s channel du Joystick
   # @return void
   #
   proc ::eye::joystick_event { s } {

      global x
      global audace

      set l [gets $s]

      if {[eof $s]} {
         close $s
         set x done
      } else {
         :::eye::joystick_tel_move [joystick_getall]
      }
      return
    }

   #============================================================
   # @brief    Interpretation des boutons utilisés pour le mouvement
   #           du telescope
   # @param    lst Liste des boutons
   # @return   void
   # @todo     Ajouter d autres fonctionnalité comme le moteur de foyer
   # @todo     Supprimer la remanence des boutons
   # @warning  Il apparait de la remanence sur certains boutons
   #============================================================
   proc ::eye::joystick_tel_move { lst } {

      set speed 0
      foreach but $lst {

         set type   [lindex $but 0]
         set num    [lindex $but 1]
         set action [lindex $but 2]

         if { $type == "button" && $num == 3 && $action == 1 } { set speed $::eye::widget(joystick,vitesse,4) }
         if { $type == "button" && $num == 2 && $action == 1 } { set speed $::eye::widget(joystick,vitesse,3) }
         if { $type == "button" && $num == 1 && $action == 1 } { set speed $::eye::widget(joystick,vitesse,2) }
         if { $type == "button" && $num == 0 && $action == 1 } { set speed $::eye::widget(joystick,vitesse,1) }
         if { $type == "axis" } {

            if {$num == "0"} {
               if {$action < 0 && $speed > 0} {
                  # 4
                  tel$::eye::tel radec move e $speed
               }
               if {$action > 0 && $speed > 0} {
                  # 2
                  tel$::eye::tel radec move w $speed
               }
            }
            if {$num == "1"} {
               if {$action < 0 && $speed > 0} {
                  # 4
                  tel$::eye::tel radec move s $speed
               }
               if {$action > 0 && $speed > 0} {
                  # 2
                  tel$::eye::tel radec move n $speed
               }
            }

         }

         if { $speed == 0 } {
            tel$::eye::tel radec stop
         }
      }
      return
   }
