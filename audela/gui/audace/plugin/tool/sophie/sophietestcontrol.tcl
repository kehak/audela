#
## @file     sophietestcontrol.tcl
#  @brief    Fichier du namespace ::sophie::testcontrol
#  @author   Michel PUJOL et Robert DELMAS
#  $Id: sophietestcontrol.tcl 13349 2016-03-11 14:45:52Z rzachantke $

## namespace sophie::testcontrol
# @brief procédures de test de l'outil sophie et simulation des interfaces externes
#

#============================================================
#
# SIMULATION DE L'INTERFACE DE CONTROLE DU T193
#
#============================================================
namespace eval ::sophie::testcontrol {

}

proc ::sophie::testcontrol::init { mainThreadNo telescopeCommandPort telescopeNotificationPort} {
   variable private

   set private(mainThreadNo)  $mainThreadNo
   set private(telescopeControl,commandSocket) ""
   set private(telescopeControl,notificationSocket) ""
   set private(telescopeControl,writeNotificationSocket) ""
   set private(telescopeCommandPort) $telescopeCommandPort
   set private(telescopeNotificationPort) $telescopeNotificationPort

   set private(motor,ra)      "45.0"          ; #--- en degres decimaux (positif vers l'est)
   set private(motor,dec)     "10.0"          ; #--- en degres decimaux (positif vers le nord)
   set private(motor,afterId) ""
   set private(motor,clock)   [clock milliseconds]
   set private(motor,raSpeed)   0
   set private(motor,decSpeed)  0

   set private(motor,slewSpeed,0)   0.0      ; #--- ces vitesses sont configurees quand le thread principal appelle sophie::test:configure au demarrage
   set private(motor,slewSpeed,1)   0.0
   set private(motor,slewSpeed,2)   0.0
   set private(motor,guidage)       0.0
   set private(motor,centrage)      0.0
   set private(motor,centrage2)     0.0
   set private(motor,gotoSpeed)     0.0

   #--- variables de travail
   set private(motor,slewMode)  1         ; #--- 0 = pas de suivi, 1=suivi sideral, 2=suivi lunaire
   set private(radecCoord,enabled) 0      ; #--- 1=envoit les coordonnes periodiquement 0=n'envoit pas les coordonnees
   set private(motor,mode)    "NONE"      ; #--- NONE, ILLIMITED_MOVE, LIMITED_MOVE, GOTO
   set private(goto,raSpeed)  0.0
   set private(goto,decSpeed) 0.0

   set private(focus,mode)    "NONE"
   set private(focus,speed)   0.0         ; #--- vitesse courante du focus
   set private(focus,L)       1           ; #--- vitesse lente de focus ( 1% par seconde)
   set private(focus,R)       5           ; #--- vitesse rapide du focus ( 5% par seconde)
   set private(focus,goto)    5           ; #--- vitesse du goto du focus( 5% par seconde)
   set private(focus,position)  "0"       ; #--- position courante du focus
   set private(focus,targetPosition)  "0" ; #--- position cible du focus pour un GOTO ou un MOVE limite
   set private(focus,notificationEnabled) "0"  ; #---notification de la position du focus

   #--- je charge la librairie de calcul de mecanique celeste dans le thread
   set binDirectory [file dirname [info nameofexecutable]]
   load [file join $binDirectory libmc[info sharedlibextension]]

   #--- je lance la boucle de simulation du moteur
   set private(motor,clock) [clock milliseconds]
   ::sophie::testcontrol::simulateMotor

   #--- j'envoi les coordonnees au thread principal pour les afficher dans la fenetre du simulateur
   ::sophie::testcontrol::updateGui

   ####disp "::sophie::testcontrol::init  \n"

}

proc ::sophie::testcontrol::disp { message } {
   variable private
   ::thread::send -async $private(mainThreadNo) [list ::console::disp "$message" ]
}

#------------------------------------------------------------
# openTelescopeControlSocket
#   ouvre une socket en lecture pour simuler l'interface de controle du telescope
#
#
#------------------------------------------------------------
proc ::sophie::testcontrol::openTelescopeControlSocket { } {
   variable private

   set catchError [ catch {
      #--- j'ouvre la socket des commandes
      set private(telescopeControl,commandSocket) [socket -server ::sophie::testcontrol::acceptTelescopeCommandSocket $private(telescopeCommandPort) ]

      #--- j'ouvre la socket de notification
      set private(telescopeControl,notificationSocket) [socket -server ::sophie::testcontrol::acceptTelescopeNotificationSocket $private(telescopeNotificationPort) ]

   }]

   set private(radecCoord,enabled) 0
   set private(motor,mode) "NONE"

   if { $catchError != 0 } {
      #--- je referme les sockets ouvertes
      if { $private(telescopeControl,commandSocket) != "" } {
         close $private(telescopeControl,commandSocket)
         set private(telescopeControl,commandSocket) ""
      }

      if { $private(telescopeControl,notificationSocket) != "" } {
         close $private(telescopeControl,notificationSocket)
         set private(telescopeControl,notificationSocket) ""
      }
      #--- je tranmets l'erreur
      error $::errorInfo
   }
}

#------------------------------------------------------------
# closeTelescopeControlSocket
#   ferme les sockets
#
#------------------------------------------------------------
proc ::sophie::testcontrol::closeTelescopeControlSocket { } {
   variable private

   if { $private(telescopeControl,commandSocket) != "" } {
      close $private(telescopeControl,commandSocket)
      set private(telescopeControl,commandSocket) ""
   }
   if { $private(telescopeControl,notificationSocket) != "" } {
      close $private(telescopeControl,notificationSocket)
      set private(telescopeControl,notificationSocket) ""
   }
}

#------------------------------------------------------------
## @brief traite la demande de connexion entrante sur l'interface de contrôle.
#  @details les données reçues sont traitées par \::sophie::spectro::readSocket
#  @param channel  identifiant du channel de la socket
#  @param address  adresse de la machine du client
#  @param port     port de la connexion entrante
#
proc ::sophie::testcontrol::acceptTelescopeCommandSocket { channel address port } {
   variable private

   disp " acceptTelescopeCommandSocket fconfigure $channel -buffering line -blocking false -translation binary -encoding binary\n"
   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   disp  "::sophie::testcontrol::acceptTelescopeCommandSocket $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::testcontrol::readTelescopeCommandSocket $channel ]
}

#------------------------------------------------------------
## @brief traite la demande de connexion entrante sur l'interface de contrôle.
#  @details les données reçues sur seront traitées par \::sophie::testcontrol::readSocket
#  @param channel  identifiant du channel de la socket
#  @param address  adresse de la machine du client
#  @param port     port de la connexion entrante
#
proc ::sophie::testcontrol::acceptTelescopeNotificationSocket { channel address port } {
   variable private

   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   set private(telescopeControl,writeNotificationSocket) $channel
   disp  "::sophie::testcontrol::acceptTelescopeNotificationSocket  $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::testcontrol::readTelescopeNotificationSocket $channel ]
}

#------------------------------------------------------------
## @brief lit la commande du PC de guidage, traite la commande et retoune une réponse
#  @param channel handle de la socket
#
proc ::sophie::testcontrol::readTelescopeCommandSocket { channel } {
   variable private

   set catchError [ catch {
      if {[eof $channel ]} {
         #--- le client s'est deconnecte , je ferme la socket
         disp "::sophie::testcontrol::readTelescopeCommandSocket close socket\n"
         #---  je ferme la socket
         close $channel
         #--- j'arrete l'envoi des notifications
         set private(radecCoord,enabled) 0
      } else {
         set command [gets $channel ]
         disp "::sophie::testcontrol::readTelescopeCommandSocket command=$command\n"

         #--- je decoupe la commande en un tableau
         set commandArray [split $command]
         #--- je traite la commande
         switch [lindex $commandArray 0] {
            "!RADEC" {
               switch [lindex $commandArray 1] {
                  MOVE {
                     #---  je recupere la direction et la vitesse
                     set direction [lindex $commandArray 2]
                     set speedCode [lindex $commandArray 3]
                     set returnCode [startRadecMove $direction $speedCode]
                     set response [format "!RADEC MOVE %d %s @" $returnCode $direction ]
                     writeTelescopeCommandSocket $channel $response
                   }
                   CORRECT {
                     #---  je recupere la direction et la vitesse
                     set alphaDirection [lindex $commandArray 2]
                     set alphaDistance  [lindex $commandArray 3]
                     set deltaDirection [lindex $commandArray 4]
                     set deltaDistance  [lindex $commandArray 5]
                     set speedCode      [lindex $commandArray 6]
                     set returnCode [startRadecCorrect $alphaDirection $alphaDistance $deltaDirection $deltaDistance $speedCode]
                     set response [format "!RADEC CORRECT %d %s %s @" $returnCode $alphaDirection $deltaDistance ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  STOP {
                     #---  je recupere la direction
                     set direction [lindex $commandArray 2]
                     set returnCode [stopRadecMove $direction]
                     set response [format "!RADEC STOP %d %s @" $returnCode $direction ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  COORD {
                     switch [lindex $commandArray 2] {
                        "0" {
                           #--- j'arrete de l'envoi periodique des coordonnees
                           set returnCode [stopRadecNotification]
                           #--- je retourne la reponse
                           set response [format "!RADEC COORD %d @" $returnCode ]
                           writeTelescopeCommandSocket $channel $response
                        }
                        "1" {
                           #--- je demarre l'envoi periodique des coordonnees (boucle infinie en tache de fond)
                           set returnCode [startRadecNotification]
                           #--- je retourne la reponse
                           set response [format "!RADEC COORD %d @" $returnCode ]
                           writeTelescopeCommandSocket $channel $response
                           #--- envoi des coordonnees
                        }
                        "2" {
                           #--- je retourne les coordonnes immediatement dans la reponse
                           set returnCode 0
                           set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string]
                           set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string]
                           set response [format "!RADEC COORD %d %s %s @" $returnCode $raHms $decDms ]
                           writeTelescopeCommandSocket $channel $response
                        }
                     }
                  }
                  GOTO {
                     set returnCode [startRadecGoto [lindex $commandArray 2] [lindex $commandArray 3]]
                     #--- j'envoie le code retour
                     set response [format "!RADEC GOTO %d @" $returnCode ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  GUIDING {
                     set returnCode 0
                     #--- j'envoie le code retour
                     set response [format "!RADEC GUIDING %d @" $returnCode ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  SLEW {
                     set returnCode [setRadecSlew [lindex $commandArray 2] ]
                     #--- j'envoie le code retour
                     set response [format "!RADEC SLEW %d @" $returnCode ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  default {
                     #--- j'envoie le code retour 99
                     set response [format "!RADEC [lindex $commandArray 1] 99 @" ]
                     writeTelescopeCommandSocket $channel $response
                     disp "::sophie::testcontrol::readTelescopeCommandSocket invalid [lindex $commandArray 1] command=$command\n"
                  }
               }
            }
            "!FOC" {
               switch [lindex $commandArray 1] {
                  MOVE {
                     #---  je recupere la direction et la vitesse
                     set direction [lindex $commandArray 2]
                     set speedCode [lindex $commandArray 3]
                     set distance  [lindex $commandArray 4]
                     set returnCode [startFocusMove $direction $speedCode $distance]
                     #--- je retourne la reponse
                     set response [format "!FOC MOVE %d @" $returnCode ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  STOP {
                     set returnCode [stopFocusMove]
                     set response [format "!FOC STOP %d @" $returnCode]
                     writeTelescopeCommandSocket $channel $response
                  }
                  COORD {
                     switch [lindex $commandArray 2] {
                        "0" {
                           #--- j'arrete de l'envoi periodique de la position
                           set returnCode [stopFocusNotification]
                           #--- je retourne la reponse
                           set response [format "!FOC COORD %d @" $returnCode ]
                           writeTelescopeCommandSocket $channel $response
                        }
                        "1" {
                           #--- je demarre l'envoi periodique des coordonnees (boucle infinie en tache de fond)
                           set returnCode [startFocusNotification]
                           #--- je retourne la reponse
                           set response [format "!FOC COORD %d @" $returnCode ]
                           writeTelescopeCommandSocket $channel $response
                        }
                        "2" {
                           #--- je retourne la position immediatement dans la reponse
                           set returnCode 0
                           switch $private(focus,mode) {
                              "NONE" {
                                 #--- le focus n'est pas  en mouvement
                                 set moveCode 0
                              }
                              default {
                                 #--- le focus est en mouvement
                                 set moveCode 1
                              }
                           }

                           set response [format "!FOC COORD %d %d %s @" $returnCode $moveCode $private(focus,position) ]
                           writeTelescopeCommandSocket $channel $response
                        }
                     }
                  }
                  GOTO {
                     disp "::sophie::testcontrol::readTelescopeCommandSocket FOC GOTO: $commandArray\n"
                     set returnCode [startFocusGoto [lindex $commandArray 2] ]
                     #--- j'envoie le code retour
                     set response [format "!FOC GOTO %d @" $returnCode ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  default {
                     #--- j'envoie le code retour 99
                     set response [format "!RADEC [lindex $commandArray 1] 99 @" ]
                     writeTelescopeCommandSocket $channel $response
                     disp "::sophie::testcontrol::readTelescopeCommandSocket invalid [lindex $commandArray 1] command=$command\n"
                  }
               }
            }
            default {
               #--- j'envoie le code retour 99
               set returnCode 99
               set response [format "[lindex $commandArray 0] [lindex $commandArray 1] %d @" $returnCode ]
               writeTelescopeCommandSocket $channel $response
               disp "::sophie::testcontrol::readTelescopeCommandSocket invalid [lindex $commandArray 0] command=$command\n"
            }
         }
      }
   }]

   if { $catchError != 0 } {
      set response "!ERROR 1 \"$::errorInfo\" @"
      writeTelescopeCommandSocket $channel $response
      #--- je trace l'erreur dans la console
      disp $::errorInfo
   }
}

#------------------------------------------------------------
## @brief envoie une réponse de la commande vers le PC de guidage
#  @param channel handle de la socket
#  @param response réponse à envoyer
#
proc ::sophie::testcontrol::writeTelescopeCommandSocket { channel response } {
   variable private

   disp "::sophie::testcontrol::writeTelescopeCommandSocket response=$response\n"
   #--- remarque la commande puts ajoute "\n" a la fin de la chaine
   puts $channel $response

}

#------------------------------------------------------------
# readTelescopeNotificationSocket
#   envoie une donne vers le PC de guidage
#
proc ::sophie::testcontrol::readTelescopeNotificationSocket { channel } {
   variable private

   set response [gets $private(telescopeControl,notificationSocket) ]
   disp "::sophie::testcontrol::readTelescopeNotificationSocket response=$response\n"
}

#------------------------------------------------------------
## @brief envoie une notitifaction au PC de guidage
#  @code Exemple :
#  ::sophie::testcontrol::writeTelescopeNotificationSocket "!RADEC COORD 0 0 03h00m00.0s +44d59m59.0s @"
#  @endcode
#  @param notification à envoyer
#
proc ::sophie::testcontrol::writeTelescopeNotificationSocket { notification } {
   variable private

   ###disp "::sophie::testcontrol::writeTelescopeNotificationSocket notification=$notification\n"
   puts $private(telescopeControl,writeNotificationSocket)  $notification

}

#############################################################
#
#  RADEC
#
#############################################################

#------------------------------------------------------------
#  brief démarre l'envoi des notifications de coordonnées
#  return
#  - 0=OK
#  - 1=Erreur
#
proc ::sophie::testcontrol::startRadecNotification { } {
   variable private

   if { $private(radecCoord,enabled) == 0 } {
      set private(radecCoord,enabled) 1
      after 1000 ::sophie::testcontrol::sendRadecNotificationLoop
   }
   return 0
}

#------------------------------------------------------------
#  brief arrête l'envoi des coordonnées au PC de guidage
#  return
#  - 0=OK
#  - 1=Erreur
#
proc ::sophie::testcontrol::stopRadecNotification { } {
   variable private
   set private(radecCoord,enabled) 0
   return 0
}

#------------------------------------------------------------
#  brief envoie une donnée au PC de guidage
#
proc ::sophie::testcontrol::sendRadecNotification { } {
   variable private

   set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string ]
   set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string ]
   switch $private(motor,mode) {
      "NONE" {
         #--- le telescope n'est pas en mouvement (excepte le suivi)
         set moveCode 0
      }
      default {
         #--- le telescope est pas en mouvement
         set moveCode 1
      }
   }
   set returnCode 0
   set raCalage "C"
   set decCalage "D"
   set response [format "!RADEC NOTIF %d %d %s %s %s %s %s @" \
      $returnCode $moveCode $private(motor,slewMode) $raCalage $decCalage $raHms $decDms ]
   disp "sendRadecNotification response=$response\n"
   ::sophie::testcontrol::writeTelescopeNotificationSocket $response
}

#------------------------------------------------------------
#  brief boucle d'envoi des notifications de la position radec
#
proc ::sophie::testcontrol::sendRadecNotificationLoop { } {
   variable private

   sendRadecNotification
   if { $private(radecCoord,enabled) == 1 } {
      #--- je lance une nouvelle iteration apres 1000 miliscondes
      after 1000 ::sophie::testcontrol::sendRadecNotificationLoop
   }
}

#------------------------------------------------------------
#  briefchange la vitess de suivi
#  param slewMode mode de suivi
#  - 0= pas de suivi,
#  - 1= suivi sideral
#  - 2= suivi lunaire
#  return
#  - 0=OK
#  - 1=Erreur
#
proc ::sophie::testcontrol::setRadecSlew { slewMode } {
   variable private

   switch $slewMode {
      0 -
      1 -
      2 {
         #--- je memorise la nouvelle vitesse de suivi
         set private(motor,slewMode) $slewMode
         set result 0
      }
      default {
         set result 1
      }
   }
   return $result
}

#------------------------------------------------------------
## @brief démarre un mouvement de moteur
#  @param direction N S E W
#  @param speedCode guidage ou centrage
#  @return
#  - 0=OK
#  - 1=Erreur
#
proc ::sophie::testcontrol::startRadecMove { direction speedCode} {
   variable private

   set catchError [ catch {

      if { $private(motor,mode) == "NONE" } {
         set speed $private(motor,$speedCode)

         #--- je change la vitesse de la monture
         switch $direction {
            "E" {
               set private(motor,raSpeed) $speed
            }
            "W" {
               set private(motor,raSpeed) [expr 0 - $speed]
            }
            "N" {
               set private(motor,decSpeed) $speed
            }
            "S" {
               set private(motor,decSpeed) [expr 0 - $speed]
            }
         }

         set private(motor,mode) "ILLIMITED_MOVE"
         set result 0
      } else {
         #--- le telescope est deja en mouvement
         set result 1
      }
   }]

   if { $catchError != 0 } {
      ::sophie::testcontrol::disp  "$::errorInfo \n"
      set result 1
   }

   return $result
}

#------------------------------------------------------------
## @brief démarre un mouvement de moteur
#  @param alphaDirection direction E W
#  @param alphaDistance en arcsec
#  @param deltaDirection direction N S
#  @param deltaDistance en arcsec
#  @param speedCode guidage ou centrage
#  @return code retour 0=OK , 1=Erreur
#
proc ::sophie::testcontrol::startRadecCorrect { alphaDirection alphaDistance deltaDirection deltaDistance speedCode } {
   variable private

   set catchError [ catch {

       if { $private(motor,mode) == "NONE" } {
          set speed $private(motor,$speedCode)

          #--- je change la vitesse de la monture
          switch $alphaDirection {
             "E" {
                set private(motor,raSpeed) $speed
             }
             "W" {
                set private(motor,raSpeed) [expr 0 - $speed]
             }
          }
          switch $deltaDirection {
             "N" {
                set private(motor,decSpeed) $speed
             }
             "S" {
                set private(motor,decSpeed) [expr 0 - $speed]
             }
          }

          set private(motor,mode) "LIMITED_MOVE"
          #--- je calcule les coordonnees cibles
          switch $alphaDirection {
             "E" {
                set private(target,ra) [expr $private(motor,ra) + $alphaDistance / 3600.0]
             }
             "W" {
                set private(target,ra) [expr $private(motor,ra) - $alphaDistance / 3600.0]
             }
          }
          #--- je calcule les coordonnees cibles
          switch $deltaDirection {
             "N" {
                set private(target,dec) [expr $private(motor,dec) + $deltaDistance / 3600.0]
             }
             "S" {
                set private(target,dec) [expr $private(motor,dec) - $deltaDistance / 3600.0]
             }
          }
          set result 0
       } else {
          #--- le telescope est deja en mouvement
          set result 1
       }
    }]

   if { $catchError != 0 } {
      ::sophie::testcontrol::disp  "$::errorInfo \n"
      set result 1
   }

   return $result
}

#------------------------------------------------------------
## @brief arrête un mouvement de moteur
#  @param direction N S E W
#  @return 0
#
proc ::sophie::testcontrol::stopRadecMove { direction } {
   variable private
   switch $direction {
      "E" -
      "W" {
         set private(motor,raSpeed) 0
      }
      "N" -
      "S" {
         set private(motor,decSpeed) 0
      }
      "T" {
         set private(motor,raSpeed) 0
         set private(motor,decSpeed) 0
      }
   }
   if { $private(motor,raSpeed) == 0 && $private(motor,decSpeed) == 0 } {
      set private(motor,mode) "NONE"
   }

   return 0
}

#------------------------------------------------------------
## @brief démarre un GOTO
#  @param ra  ascension droite (format hms)
#  @param dec declinaison (format dms)
#  @return code retour
#  - 0=OK ,
#  - 1=goto déja en cours
#  - 2=sous l'horizon (moins de 10 degres de hauteur
#
proc ::sophie::testcontrol::startRadecGoto { ra dec } {
   variable private
   set result 0

   #--- je convertis les coordonnees en degres
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec]

   #--- je verifie que les coordonnees sont au dessus de l'horizon
   set now [clock format [clock seconds] -format "%Y %m %d %H %M %S" -timezone :UTC ]
   set altazCoord [ mc_radec2altaz $ra $dec $private(observaterPosition) $now ]
   set azimuth    [ lindex $altazCoord 0 ]
   set elevation  [ lindex $altazCoord 1 ]

   disp "::sophie::testcontrol::startRadecGoto private(motor,mode)=$private(motor,mode) \n"
   if { $private(motor,mode) == "NONE" } {
      #--- je verifie que l'elevation est superieure a 10 degres
      if { $elevation != "" } {
         #--- je calcule le sens de deplacement en ascension droite
         if { $ra > $private(motor,ra) } {
            set private(goto,raSpeed) $private(motor,gotoSpeed)
         } else {
            set private(goto,raSpeed) [expr 0 - $private(motor,gotoSpeed)]
         }

         if { $dec > $private(motor,dec) } {
            set private(goto,decSpeed) $private(motor,gotoSpeed)
         } else {
            set private(goto,decSpeed) [expr 0 - $private(motor,gotoSpeed)]
         }

         #--- je memorise les coordonnes cibles
         set private(target,ra) $ra
         set private(target,dec) $dec

         set private(motor,mode) "GOTO"

      } else {
         set result 2
      }
   } else {
      set result 1
   }
   return $result
}

#############################################################
#
#  FOCUS
#
#############################################################

#------------------------------------------------------------
## @brief démarre un mouvement du focus
#  @param direction + ou -
#  @param speedCode L ou R
#  @param distance en arcsec
#  @return code retour
#  - 0=OK
#  - 1=Erreur
#
proc ::sophie::testcontrol::startFocusMove { direction speedCode distance} {
   variable private

   set catchError [ catch {
      set result 0

      if { $private(focus,mode) == "NONE" } {
         set speed $private(focus,$speedCode)

         #--- je change la vitesse de la monture
         switch $direction {
            "+" {
               set private(focus,speed) $speed
            }
            "-" {
               set private(focus,speed) [expr 0 - $speed]
            }
            default {
               set result 2  ; # erreur: direction incorrecte
            }
         }

         if { $result == 0 } {
            if { $distance == 0 } {
               set private(focus,mode) "ILLIMITED_MOVE"
            } else {
               set private(focus,mode) "LIMITED_MOVE"
               #--- je calcule les coordonnees cibles
               switch $direction {
                  "+" {
                     set private(focus,targetPosition) [expr $private(focus,position) + $distance ]
                  }
                  "-" {
                     set private(focus,targePosition) [expr $private(focus,position) - $distance ]
                  }
               }
            }
         }
      } else {
         #--- erreur: le focus est deja en mouvement
         set result 1
      }
   }]

   if { $catchError != 0 } {
      ::sophie::testcontrol::disp  "$::errorInfo \n"
      set result 1
   }

   return $result
}

#------------------------------------------------------------
## @brief démarre un goto du focus
#  @param targetPosition position cibble du goto
#  @return code retour 0=OK , 1=Erreur
#
proc ::sophie::testcontrol::startFocusGoto { targetPosition } {
   variable private

   disp "::sophie::testcontrol::startFocusGoto targetPosition=$targetPosition \n"
   if { $private(motor,mode) == "NONE" } {
      #--- je calcule le sens de deplacement
      if { $targetPosition > $private(focus,position) } {
         set private(focus,speed) $private(focus,goto)
      } else {
         set private(focus,speed) [expr 0 - $private(focus,goto)]
      }
      #--- je memorise la position cible
      set private(focus,targetPosition) $targetPosition
      set private(focus,mode) "GOTO"
      set result 0
   } else {
      set result 1
   }
   return $result
}

#------------------------------------------------------------
## @brief brief arrête un mouvement du focus
#  @return 0
#
proc ::sophie::testcontrol::stopFocusMove { } {
   variable private

   set private(focus,speed) 0.0
   set private(focus,mode) "NONE"

   return 0
}

#------------------------------------------------------------
## @brief démarre l'envoi des notifications de la position du focus
#  @return code retour 0=OK , 1=Erreur
#
proc ::sophie::testcontrol::startFocusNotification { } {
   variable private

   if { $private(focus,notificationEnabled) == 0 } {
      set private(focus,notificationEnabled) 1
      after 500 ::sophie::testcontrol::sendFocusNotificationLoop
   }
   return 0
}

#------------------------------------------------------------
## @brief arrête l'envoi des notifications de la position du focus
#  @return code retour 0=OK , 1=Erreur
#
proc ::sophie::testcontrol::stopFocusNotification { } {
   variable private
   set private(focus,notificationEnabled) 0
   return 0
}

#------------------------------------------------------------
## @brief boucle d'envoi des notificiations de la position du focus
#
proc ::sophie::testcontrol::sendFocusNotificationLoop { } {
   variable private

   sendFocusPosition
   if { $private(focus,notificationEnabled) == 1 } {
      #--- je lance une nouvelle iteration apres 1000 miliscondes
      after 500 ::sophie::testcontrol::sendFocusNotificationLoop
   }
}

#------------------------------------------------------------
## @brief envoie une donnée au PC de guidage
#
proc ::sophie::testcontrol::sendFocusPosition { } {
   variable private

   switch $private(focus,mode) {
      "NONE" {
         #--- le focus n'est pas  en mouvement
         set moveCode 0
      }
      default {
         #--- le focus est en mouvement
         set moveCode 1
      }
   }
   set returnCode 0
   set response [format "!FOC COORD %d %d %0.2f @" $returnCode $moveCode $private(focus,position)]
   disp "sendFocusPosition $response \n"
   ::sophie::testcontrol::writeTelescopeNotificationSocket $response
}

#------------------------------------------------------------
## @brief simule un mouvement de moteur en modifiant les coordonnées
#  toutes les 500 millisecondes
#
proc ::sophie::testcontrol::simulateMotor { } {
   variable private

   set catchError [ catch {

      set now [clock milliseconds]

      #--- je calcule le delai ecoule depuis le debut du mouvement
      set delay [ expr double($now - $private(motor,clock)) / 1000.0]
      set private(motor,clock) $now

      switch $private(motor,mode) {
         "NONE" {
            #--- je simule l'arret du suivi en ascension droite (la declinaison n'est pas modifiee)
            set private(motor,ra) [expr $private(motor,ra) + $delay * (15.0 - $private(motor,slewSpeed,$private(motor,slewMode)))  / 3600.0  ]
         }
         "ILLIMITED_MOVE" {
            #--- je simule le deplacement  illimitee
            set private(motor,ra) [expr $private(motor,ra) + $delay * ($private(motor,raSpeed) + (15.0 - $private(motor,slewSpeed,$private(motor,slewMode))))  / 3600.0  ]
            set private(motor,dec) [expr $private(motor,dec) + $delay * $private(motor,decSpeed)  / 3600.0  ]
         }
         "LIMITED_MOVE" {
            #--- je simule le deplacement limite
            if { [expr abs($private(motor,ra) - $private(target,ra)) > abs($delay * $private(motor,raSpeed) /3600.0) ] } {
               set private(motor,ra) [expr $private(motor,ra) + $delay * $private(motor,raSpeed) /3600.0 ]
            } else {
               set private(motor,ra) $private(target,ra)
            }
            if { [expr abs($private(motor,dec) - $private(target,dec)) > abs($delay * $private(motor,decSpeed) /3600.0) ] } {
               set private(motor,dec) [expr $private(motor,dec) + $delay * $private(motor,decSpeed) /3600.0 ]
            } else {
               set private(motor,dec) $private(target,dec)
            }

            if { $private(motor,ra) == $private(target,ra) && $private(motor,dec) == $private(target,dec) } {
               #--- je memorise l'arret du MOVE
               set private(motor,mode) "NONE"
               set private(motor,raSpeed) 0
               set private(motor,decSpeed) 0
               ##disp "simulateMotor fin de mouvement limité\n"
               #--- j'envoie une notification pour signaler que le GOTO est termine
               ::sophie::testcontrol::sendRadecNotification
            }
         }
         "GOTO" {
            #--- je simule le GOTO
            if { [expr abs($private(motor,ra) - $private(target,ra)) > abs($delay * $private(goto,raSpeed) /3600.0) ] } {
               set private(motor,ra) [expr $private(motor,ra) + $delay * $private(goto,raSpeed) /3600.0 ]
            } else {
               set private(motor,ra) $private(target,ra)
            }
            if { [expr abs($private(motor,dec) - $private(target,dec)) > abs($delay * $private(goto,decSpeed) /3600.0) ] } {
               set private(motor,dec) [expr $private(motor,dec) + $delay * $private(goto,decSpeed) /3600.0 ]
            } else {
               set private(motor,dec) $private(target,dec)
            }

            if { $private(motor,ra) == $private(target,ra) && $private(motor,dec) == $private(target,dec) } {
               #--- je memorise l'arret du GOTO
               disp "simulateMotor fin de mouvement limité\n"
               set private(motor,mode) "NONE"
               #--- j'envoie une notification pour signaler que le GOTO est termine
               ::sophie::testcontrol::sendRadecNotification
            }
         }
      }

      switch $private(focus,mode) {
         "NONE" {
            #--- rien a faire
         }
         "ILLIMITED_MOVE" {
            #--- je simule le deplacement illimitee
            set private(focus,position) [expr $private(focus,position) + $delay * $private(focus,speed) ]
         }
         "LIMITED_MOVE" {
            #--- je simule le deplacement limite
            if { [expr abs($private(focus,position) - $private(focus,targetPosition)) > abs($delay * $private(focus,speed)) ] } {
               set private(focus,position) [expr $private(focus,position) + $delay * $private(focus,speed) ]
            } else {
               #--- l'ecart est tout petit, je considere qu'on a atteint la position cible
               set private(focus,position) $private(focus,targetPosition)
            }
            if { $private(focus,position) == $private(focus,targetPosition) } {
               #--- je memorise l'arret du MOVE
               set private(focus,mode) "NONE"
               #--- j'envoie une notification pour signaler que le MOVE est termine
               ::sophie::testcontrol::sendFocusPosition
            }
         }
         "GOTO" {
            #--- je simule le GOTO
            if { [expr abs($private(focus,position) - $private(focus,targetPosition)) > abs($delay * $private(focus,speed)) ] } {
               set private(focus,position) [expr $private(focus,position) + $delay * $private(focus,speed) ]
               ###disp "simulateMotor delai=$delay private(focus,position)=$private(focus,position)\n"
            } else {
               #--- l'ecart est tout petit, je considere qu'on a atteint la position cible
               set private(focus,position) $private(focus,targetPosition)
               ###disp "simulateMotor delai=$delay private(focus,position)=$private(focus,position) FIN \n"
            }

            if { $private(focus,position) == $private(focus,targetPosition) } {
               #--- je memorise l'arret du GOTO
               set private(focus,mode) "NONE"
               #--- j'arrete l'nvoi des notifications
               stopFocusNotification
               #--- j'envoie une notification pour signaler que le GOTO est termine
               ::sophie::testcontrol::sendFocusPosition
            }
         }
      }

      ###disp "simulateMotor delai=$delay ra=$private(motor,ra) dec=$private(motor,ra) \n"

      #--- je met a jour la fenetre du simulateur
      ::sophie::testcontrol::updateGui

      set private(motor,afterId) [after 500 ::sophie::testcontrol::simulateMotor ]
   }]

   if { $catchError != 0 } {
      ::sophie::testcontrol::disp  "$::errorInfo \n"
   }
}

#------------------------------------------------------------
## @brief met à jour les paramètres de configuration
#  @details cette procédure est appelée par le thread principal chaque fois qu'un paramètre est modifié par l'utilisateur
#  @param sideralSpeed   vitesse siderale (arsec/sec)
#  @param lunarSpeed     vitesse lunaire (arsec/sec)
#  @param guidingSpeed   vitesse des corrections de guidage (arsec/sec)
#  @param centeringSpeed vitesse de centrage (arsec/sec)
#  @param centering2Speed ?
#  @param gotoSpeed       ?
#  @param observaterPosition position de l'observateur au format "GPS 0.142300 E 42.936639 2890.5"
#  @todo compléter la doc des param
#
proc ::sophie::testcontrol::configure { sideralSpeed lunarSpeed guidingSpeed centeringSpeed centering2Speed gotoSpeed observaterPosition } {
   variable private

   set private(motor,slewSpeed,1)   $sideralSpeed
   set private(motor,slewSpeed,2)   $lunarSpeed
   set private(motor,guidage)       $guidingSpeed
   set private(motor,centrage)      $centeringSpeed
   set private(motor,centrage2)     $centering2Speed
   set private(motor,gotoSpeed)     $gotoSpeed
   set private(observaterPosition)  $observaterPosition
}

#-----------------------------------------------------------
## brief envoie les valeurs courantes au thread principal pour les afficher dans la fenêtre du simulateur
#  pour simuler la dérive du télescope par rapport au ciel
#
proc ::sophie::testcontrol::updateGui { } {
   variable private

   ::thread::send -async $private(mainThreadNo) \
      [list ::sophie::test::updateGui $private(motor,ra) $private(motor,dec) \
            [expr $private(motor,raSpeed)+ $private(motor,slewSpeed,$private(motor,slewMode))]  \
       $private(motor,decSpeed) \
       $private(motor,slewMode) $private(motor,slewSpeed,$private(motor,slewMode)) \
       [format "%6.2f" $private(focus,position)] $private(focus,speed) ]
}

