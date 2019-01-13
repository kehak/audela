#
## @file telescope.tcl
#  @brief Centralise les commandes de mouvement des montures
#  @author Michel PUJOL
#  @namespace telescope
#  @brief Centralise les commandes de mouvement des montures
#  $Id: telescope.tcl 14466 2018-08-23 00:24:38Z alainklotz $
#

namespace eval ::telescope {
}

#------------------------------------------------------------
#  brief chargement des captions et initialisation de variables
#
proc ::telescope::init { } {
   variable private
   global audace caption conf

   #--- Chargement des captions
   source [ file join $audace(rep_caption) telescope.cap ]

   #--- Initialisation de variables audace
   set audace(telescope,getra)         "00h00m00"
   set audace(telescope,getdec)        "+00d00m00"
   set audace(telescope,targetRa)      "00h00m00"
   set audace(telescope,targetDec)     "+00d00m00"
   set audace(telescope,targetName)    ""
   set audace(telescope,targetEquinox) "J2000.0"
   set audace(telescope,rate)          "1"
   set audace(telescope,labelspeed)    "$caption(telescope,interro)"
   set audace(telescope,speed)         "1"
   set audace(telescope,goto)          "0"
   set audace(telescope,inittel)       "$caption(telescope,init)"
   set audace(telescope,controle)      "$caption(telescope,suivi_marche)"

   #--- Initialisation de variables private
   set private(telescopeMoving)        "0"
}

#------------------------------------------------------------
## @brief initialise le pointage en AD et en Dec de la monture AudeCom
#  @param  this  : Widget du bouton dédié
#  @param visuNo : Numéro de la visu
#
proc ::telescope::initTel { this visuNo } {
   variable Button_Init
   global audace caption conf

   set Button_Init $this

   set base [ ::confVisu::getBase $visuNo ]

   if { ( $conf(telescope) == "audecom" ) && ( [ ::confTel::isReady ] == 1 ) } {
      #--- Neutralisation du bouton initialisation
      $Button_Init configure -relief groove -state disabled
      #--- Reset position de la monture
      tel$audace(telNo) initcoord
      #--- Creation d'une fenetre Toplevel
      toplevel $base.inittel
      wm transient $base.inittel $base
      wm resizable $base.inittel 0 0
      wm title $base.inittel "$caption(telescope,inittelscp0)"
      set posx_inittel [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_inittel [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $base.inittel +[ expr $posx_inittel + 150 ]+[ expr $posy_inittel + 105 ]
      #--- Cree l'affichage du message
      label $base.inittel.lab1 -text "$caption(telescope,inittelscp1)\n$caption(telescope,inittelscp2)\n \
         $caption(telescope,inittelscp3)\n$caption(telescope,inittelscp4)\n$caption(telescope,inittelscp5)\n \
         $caption(telescope,inittelscp6)\n\n$caption(telescope,inittelscp7)\n$caption(telescope,inittelscp8)\n \
         $caption(telescope,inittelscp9)"
      pack $base.inittel.lab1 -padx 10 -pady 2
      #--- La nouvelle fenetre est active
      focus $base.inittel
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base.inittel
      #--- Fermeture de la fenetre
      bind $base.inittel <Destroy> {
         #--- Les coordonnees AD et Dec sont mises a jour a la fermeture de la fenetre
         ::telescope::afficheCoord
         #--- Activation du bouton initialisation
         if { [ winfo exists $::telescope::Button_Init ] } {
            $::telescope::Button_Init configure -relief raised -state normal
         }
      }
   } else {
      ::confTel::run
      tkwait window $base.confTel
      #--- Activation du bouton initialisation
      $Button_Init configure -relief raised -state normal
   }
   #--- Les coordonnees AD et Dec sont mises a jour
   ::telescope::afficheCoord
}

#------------------------------------------------------------
## @brief synchronise la monture avec la liste de coordonnées radec d'un objet
#  @remark Si modele = gemini, propose un alignement additionnel
#  @param radec        : liste des coordonnées AD et Dec a pointer
#  @param radecEquinox : équinoxe des coordonnées de l'objet (optionnel)
#  @param mountSide    : position du tube par rapport à la monture (valeurs : auto,W,E) (optionnel)
#
proc ::telescope::match { radec { radecEquinox "J2000.0" } { mountSide ? } } {
   variable private
   global audace caption conf

   #--- S'il manque une ou les 2 coordonnees, on sort immediatement
   if { "" in $radec } {
      tk_messageBox -title "$caption(telescope,attention)" -type ok \
         -message "$caption(telescope,match) - $caption(telescope,errorCoord)\n"
      return
   }

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "lx200" && $conf(lx200,modele) == "$caption(telescope,modele_gemini)" } {
         #--- cas du modele Losmandy Gemini
         set choix [ tk_dialog \
            $audace(base).selectAlign \
            "$caption(telescope,match)" \
            "$caption(telescope,match_confirm)" \
            "" \
            1  \
            "$caption(telescope,match_alg_init)" "$caption(telescope,match_alg_add)" \
            "$caption(telescope,match_cancel)" \
            ]
         if { $choix == "0" } {
            #--- alignement normal
            if { $mountSide == "?" } {
               tel$audace(telNo) radec init $radec
            } else {
               tel$audace(telNo) radec init $radec -mountside $mountSide
            }
         } elseif { $choix == "1" } {
            #--- alignement additionel pour modele gemini
             tel$audace(telNo) radec init -option additional $radec
         } else {
            #--- rien a faire
         }
      } else {
         #--- cas des autres modeles (lx200, audecom, skysensor, ...)
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(telescope,match)" \
            -message "$caption(telescope,match_confirm)" ]
         set private(choix) $choix
         if { $choix == "yes" } {
            #--- Cas de la monture principale
            if { $mountSide == "?" } {
               tel$audace(telNo) radec init $radec
            } else {
               tel$audace(telNo) radec init $radec -mountside $mountSide
            }
            #--- Si Ouranos est une monture secondaire, envoie egalement le Match a l'interface Ouranos
            set secondaryTelNo [ getSecondaryTelNo ]
            if { $secondaryTelNo != "0" } {
               tel$secondaryTelNo radec init $radec
            }
         }
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
   }
   ::telescope::afficheCoord
}

#------------------------------------------------------------
## @brief vérifie que la monture possède la fonction goto et
#  envoie l'ordre à la monture de pointer les coordonnees list_radec
#  en mode bloquant ou non
#  @param list_radec         liste des coordonnees AD et Dec a pointer
#  @param blocking blocking  mode bloquant (1) ou non (0)
#  @param But_Goto           widget du bouton Goto (optionnel)
#  @param But_Match          widget du bouton Match (optionnel)
#  @param objectName         nom de l'objet (optionnel)
#  @param radecEquinox       équinoxe des coordonnees de l'objet (optionnel)
#  @return
#  - 0 si OK
#  - 1 si erreur (monture absente), erreur à catcher pour les autres erreurs
#
proc ::telescope::goto { list_radec blocking { But_Goto "" } { But_Match "" } { objectName "" } { radecEquinox "J2000.0" } } {
   global audace caption cataGoto conf

   #--- S'il manque une ou les 2 coordonnees, on sort immediatement
   if { "" in $list_radec } {
      tk_messageBox -title "$caption(telescope,attention)" -type ok \
         -message "$caption(telescope,goto) - $caption(telescope,errorCoord)\n"
      return -1
   }

   if { [ ::tel::list ] != "" } {
      set audace(telescope,targetRa)      [lindex $list_radec 0]
      set audace(telescope,targetDec)     [lindex $list_radec 1]
      set audace(telescope,targetName)    $objectName
      set audace(telescope,targetEquinox) $radecEquinox
      #---
      setTrackSpeed
      #--- Gestion des boutons Goto et Match
      if { $But_Goto != "" } {
         $But_Goto configure -relief groove -state disabled
      }
      if { $But_Match != "" } {
         $But_Match configure -relief raised -state disabled
      }
      update
      #--- Affichage du champ dans une carte. Parametres : nom_objet, ad, dec, zoom_objet, avant_plan
      if { $cataGoto(carte,validation) == "1" } {
         if { [::carte::isReady] == "0" } {
            ::carte::gotoObject $cataGoto(carte,nom_objet) $cataGoto(carte,ad) $cataGoto(carte,dec) $cataGoto(carte,zoom_objet) $cataGoto(carte,avant_plan)
         }
      }
      #--- Cas d'un Goto avec rattrapage des jeux
      set audace(telescope,stopgoto) "0"
      if { [ ::confTel::getPluginProperty backlash ] == "1" } {
         #--- Goto
         tel$audace(telNo) radec goto $list_radec -blocking $blocking -backlash 1 -equinox $radecEquinox
         if { $blocking == 0 } {
            #--- Boucle tant que la monture n'est pas arretee (si on n'utilise pas le mode bloquant du goto)
            set audace(telescope,goto) "1"
            set radec0 [ tel$audace(telNo) radec coord -equinox $radecEquinox ]
            set derniereBoucle [ ::telescope::surveille_goto [ list $radec0 ] $radecEquinox]
            if { $derniereBoucle == 1 } {
               #--- j'attends que la variable soit remise a zero
               vwait ::audace(telescope,goto)
            }
         }
         #--- je traite le mode slewpath (si long, je passe en short pour le rattrapage des jeux)
         slewpathLong2Short
      }

      #--- Goto
      set catchError [catch {
         if { $audace(telescope,stopgoto) == "0" } {
            tel$audace(telNo) radec goto $list_radec -blocking $blocking -equinox $radecEquinox
            if { $blocking == 0 } {
               #--- Boucle tant que la monture n'est pas arretee (si on n'utilise pas le mode bloquant du goto)
               set audace(telescope,goto) "1"
               set radec0 [ tel$audace(telNo) radec coord -equinox $radecEquinox ]
               #--- j'attends une seconde que le telescope commence a tourner
               #--- car sinon la boucle de surveillance va considerer que les
               #--- coordonnees n'ont pas changé et va s'arreter immediatement
               after 1000
               set derniereBoucle [ ::telescope::surveille_goto $radec0 $radecEquinox ]
               if { $derniereBoucle == 1 } {
                  #--- j'attends que la variable soit remise a zero
                  vwait ::audace(telescope,goto)
               }
            } else {
               ::telescope::afficheCoord
            }
         }
      }]

      #--- je restaure le mode slewpath si necessaire
      slewpathShort2Long

      #--- je mets a jour les boutons avant de retourner un eventuel message d'erreur
      if { $But_Goto != "" } {
         $But_Goto configure -relief raised -state normal
      }
      if { $But_Match != "" } {
         $But_Match configure -relief raised -state normal
      }

      #--- je retourne l'erreur si elle existe
      if { $catchError != 0 } {
         error $::errorInfo
      } else {
         return 0
      }
   } else {
      ::confTel::run
      return -1
   }
}

#------------------------------------------------------------
## @brief surveille si la fonction goto est active
#  @param  radec0  liste des coordonnees AD et Dec de l'objet
#  @param  radecEquinox équinoxe des coordonnées
#  @return
#  -  0 si dernière boucle
#  -  1 si nouvelle boucle est lancée
#
proc ::telescope::surveille_goto { radec0 radecEquinox } {
   global audace conf

   if { $audace(telNo) != 0 } {
      set radec1 [::telescope::afficheCoord]
      if { $radec1 == "" } {
         #--- j'arrete la boucle de surveillance  car les coordonnees n'ont pas pu etre recuperees
         console::affiche_erreur "surveille_goto pas de coordonnees\n"
         return 0
      }
      set ra0 [ mc_angle2deg [ lindex $radec0 0 ] 360 ]
      set dec0 [ mc_angle2deg [ lindex $radec0 1 ] 90 ]
      set ra1 [ mc_angle2deg [ lindex $radec1 0 ] 360 ]
      set dec1 [ mc_angle2deg [ lindex $radec1 1 ] 90 ]

      set sepangle [ mc_anglesep [ list $ra0 $dec0 $ra1 $dec1 ] ]
      if { [ lindex $sepangle 0 ] > 0.01 } {
         after 1100 ::telescope::surveille_goto [ list $radec1 ] $radecEquinox
         #--- je retourne 1 pour signaler que ce n'est pas pas la derniere boucle
         return 1
      } else {
         #--- on relance eventuellement le suivi car le GOTO est termine
         if { ($conf(telescope) == "eqmod") || ($conf(telescope) == "csi") || ($conf(telescope) == "deltatau") } {
            after 500
            tel$audace(telNo) radec motor off
            tel$audace(telNo) radec motor on
         }
         #--- j'arrete la surveillance car le GOTO est termine
         set ::audace(telescope,goto) "0"
         update
         return 0
      }
   } else {
      #--- j'arrete la surveillance car le telescope a ete deconnecte pendant le GOTO
      set ::audace(telescope,goto) "0"
      update
      return 0
   }
}

#------------------------------------------------------------
## @brief arrête le mouvement du GOTO
#  @param  But_Stop Widget du bouton Stop Goto (optionnel)
#
proc ::telescope::stopGoto { { But_Stop "" } } {
   global audace conf

   set audace(telescope,stopgoto) "1"
   if { ( $conf(telescope) == "audecom" ) && ( [ ::confTel::isReady ] == 1 ) } {
      #--- Arret d'urgence du pointage et retour a la position au moment de l'action
      tel$audace(telNo) radec stop
      if { $audace(telescope,goto) == "0" } {
         if { $But_Stop != "" } {
            $But_Stop configure -relief raised -state normal
         }
         update
      }
      set audace(telescope,goto) "0"
   } elseif { ( $conf(telescope) == "eqmod" ) } {
      #--- Arret d'urgence du pointage
      tel$audace(telNo) radec stop
      tel$audace(telNo) radec motor off
      if { $audace(telescope,goto) == "0" } {
         if { $But_Stop != "" } {
            $But_Stop configure -relief raised -state normal
         }
         update
      }
      set audace(telescope,goto) "0"
   } elseif { [ ::tel::list ] != "" } {
      tel$audace(telNo) radec stop
      set audace(telescope,goto) "0"
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      catch {
         if { $But_Stop != "" } {
            $But_Stop configure -relief raised -state normal
         }
         update
      }
   }
   ::telescope::afficheCoord
}

#------------------------------------------------------------
## @brief retourne la liste des libellés des vitesses supportées par la monture
#
proc ::telescope::getSpeedLabelList { } {
   global caption conf

   if { $conf(telescope) == "audecom" } {
      set speedList "$caption(telescope,x1) $caption(telescope,x5) $caption(telescope,200)"
   } elseif { $conf(telescope) == "temma" } {
      set speedList "$caption(telescope,NS) $caption(telescope,HS)"
   } elseif { $conf(telescope) == "eqmod" } {
      set speedList "1 2 3 4 5 6 7"
   } elseif { $conf(telescope) == "mcmt" } {
      set speedList "1 2 3"
   } else {
      set speedList "1 2 3 4"
   }
   return $speedList
}

#------------------------------------------------------------
## @brief retourne la liste des valeurs des vitesses supportées par la monture
#
proc ::telescope::getSpeedValueList { } {
   global conf

   if { $conf(telescope) == "audecom" } {
      set speedList "1 2 3"
   } elseif { $conf(telescope) == "temma" } {
      set speedList "1 2"
   } elseif { $conf(telescope) == "eqmod" } {
      set speedList "1 2 3 4 5 6 7"
   } elseif { $conf(telescope) == "mcmt" } {
      set speedList "1 2 3"
   } else {
      set speedList "1 2 3 4"
   }
   return $speedList
}

#------------------------------------------------------------
## @brief décode la vitesse de la monture pour les décalages des outils d'acquisition
#  concernés (Acquisition, Acquisition T1M, Acquisition video, Aquisition Zadko)
#  @param namespace pour initialiser la variable panneau
#
proc ::telescope::decodeSpeedDlgShift { namespace } {
   global audace caption conf panneau

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         switch $panneau($namespace,shiftSpeed) {
            "$caption(telescope,x1)"  { setSpeed "1" }
            "$caption(telescope,x5)"  { setSpeed "2" }
            "$caption(telescope,200)" { setSpeed "3" }
         }
      } elseif { $conf(telescope) == "lx200" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
         }
      } elseif { $conf(telescope) == "temma" } {
         switch $panneau($namespace,shiftSpeed) {
            "$caption(telescope,NS)" { setSpeed "1" }
            "$caption(telescope,HS)" { setSpeed "2" }
         }
      } elseif { $conf(telescope) == "eqmod" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
            "5" { setSpeed "5" }
            "6" { setSpeed "6" }
            "7" { setSpeed "7" }
         }
      } elseif { $conf(telescope) == "mcmt" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
         }
      } elseif { $conf(telescope) == "csi" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
         }
      } elseif { $conf(telescope) == "deltatau" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
         }
      } elseif { $conf(telescope) == "etel" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
         }
      } elseif { $conf(telescope) == "telscript" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
         }
      } elseif { $conf(telescope) == "gemini" } {
         switch $panneau($namespace,shiftSpeed) {
            "1" { setSpeed "1" }
            "2" { setSpeed "2" }
            "3" { setSpeed "3" }
            "4" { setSpeed "4" }
         }
      } else {
         #--- Inactif pour les autres telescopes
         setSpeed "0"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(telescope,rate) "0"
   }
}

#------------------------------------------------------------
## @brief incrémente la vitesse de la monture et
#  met la nouvelle valeur dans la variable audace(telescope,speed)
#
proc ::telescope::incrementSpeed { } {
   global audace conf

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         #--- Pour audecom, l'increment peut prendre 3 valeurs ( 1 2 3 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "lx200" } {
         #--- Pour lx200, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "csi" } {
         #--- Pour CSI, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "deltatau" } {
         #--- Pour Deltatau, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "etel" } {
         #--- Pour Etel, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "temma" } {
         #--- Pour temma, l'increment peut prendre 2 valeurs ( 1 2 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "eqmod" } {
         #--- Pour eqmod, l'increment peut prendre 7 valeurs ( 1 2 3 4 5 6 7 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            "4"     { setSpeed "5" }
            "5"     { setSpeed "6" }
            "6"     { setSpeed "7" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "mcmt" } {
         #--- Pour mcmt, l'increment peut prendre 3 valeurs ( 1 2 3 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "telscript" } {
         #--- Pour telscript, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "ascom" } {
         #--- Pour ascom, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            "3"     { setSpeed "4" }
            default { setSpeed "1" }
         }
      } elseif { $conf(telescope) == "t193" } {
         #--- Pour t193, l'increment peut prendre 3 valeurs ( 1 2 3 )
         switch $audace(telescope,speed) {
            "1"     { setSpeed "2" }
            "2"     { setSpeed "3" }
            default { setSpeed "1" }
         }
      } else {
         #--- Inactif pour les autres montures
         setSpeed "0"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(telescope,rate) "0"
   }
}

#------------------------------------------------------------
## @brief change la vitesse de la monture
#  @remark met à jour les variables audace(telescope,speed), audace(telescope,labelspeed),
#  audace(telescope,rate)
#  @param value vitesse de la monture (optionnel)
#
proc ::telescope::setSpeed { { value "2" } } {
   global audace caption conf

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "$caption(telescope,x1)"
               set audace(telescope,rate) "0"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "$caption(telescope,x5)"
               set audace(telescope,rate) "0.5"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "$caption(telescope,200)"
               set audace(telescope,rate) "1"
            }
         }
      } elseif { $conf(telescope) == "lx200" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.33"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.66"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "1"
            }
         }
      } elseif { $conf(telescope) == "csi" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.25"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.5"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.55"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "0.82"
            }
         }
      } elseif { $conf(telescope) == "deltatau" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.001"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.01"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.1"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "1.00"
            }
         }
      } elseif { $conf(telescope) == "etel" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.25"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.5"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.55"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "0.82"
            }
         }
      } elseif { $conf(telescope) == "temma" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "$caption(telescope,NS)"
               set audace(telescope,rate) "0"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "$caption(telescope,HS)"
               set audace(telescope,rate) "1"
            }
         }
      } elseif { $conf(telescope) == "eqmod" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) [ expr 360.0 / 86164. ]
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) [ expr 4 * 360.0 / 86164. ]
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) [ expr 64 * 360.0 / 86164. ]
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "1"
            }
            "5" {
               set audace(telescope,speed) "5"
               set audace(telescope,labelspeed) "5"
               set audace(telescope,rate) "2"
            }
            "6" {
               set audace(telescope,speed) "6"
               set audace(telescope,labelspeed) "6"
               set audace(telescope,rate) "3"
            }
            "7" {
               set audace(telescope,speed) "7"
               set audace(telescope,labelspeed) "7"
               set audace(telescope,rate) "10"
            }
         }
      } elseif { $conf(telescope) == "mcmt" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.1"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.5"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "1"
            }
         }
      } elseif { $conf(telescope) == "telscript" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.25"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.5"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.75"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "1"
            }
         }
      } elseif { $conf(telescope) == "ascom" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.01"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.1"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.25"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "1"
            }
         }
      } elseif { $conf(telescope) == "t193" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.33"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.66"
            }
         }
      } elseif { $conf(telescope) == "gemini" } {
         switch $value {
            "1" {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0.25"
            }
            "2" {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "2"
               set audace(telescope,rate) "0.5"
            }
            "3" {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "3"
               set audace(telescope,rate) "0.75"
            }
            "4" {
               set audace(telescope,speed) "4"
               set audace(telescope,labelspeed) "4"
               set audace(telescope,rate) "1.0"
            }
         }
      } else {
         set audace(telescope,speed) "1"
         set audace(telescope,labelspeed) "$caption(telescope,interro)"
         set audace(telescope,rate) "0"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(telescope,rate) "0"
   }
}

#------------------------------------------------------------
## @brief  arrête ou met en marche la monture et
#  met a jour la variable audace(telescope,controle)
#  @param value Marche (Suivi on) ou arret (Suivi off) du suivi (optionnel)
#
proc ::telescope::controleSuivi { { value " " } } {
   global audace caption conf

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty hasControlSuivi ] == "1" } {
         if { $value == " " } {
            if { $audace(telescope,controle) == "$caption(telescope,suivi_marche)" } {
               tel$audace(telNo) radec motor off
               set audace(telescope,controle) "$caption(telescope,suivi_arret)"
            } elseif { $audace(telescope,controle) == "$caption(telescope,suivi_arret)" } {
               tel$audace(telNo) radec motor on
               set audace(telescope,controle) "$caption(telescope,suivi_marche)"
            }
         } else {
            if { $value == "$caption(telescope,suivi_marche)" } {
               tel$audace(telNo) radec motor off
               set audace(telescope,controle) "$caption(telescope,suivi_arret)"
            } elseif { $value == "$caption(telescope,suivi_arret)" } {
               tel$audace(telNo) radec motor on
               set audace(telescope,controle) "$caption(telescope,suivi_marche)"
            }
         }
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
   }
   ::telescope::afficheCoord
}

#------------------------------------------------------------
## @brief démarre le mouvement dans une direction
#  @param direction : Direction du deplacement (n, s, e ou w)
#
proc ::telescope::move { direction } {
   variable AfterId
   variable AfterState
   global audace conf

   if { $audace(telNo) != "0" } {
      if { $conf(telescope) == "temma" } {
         set AfterState "1"
         set AfterId [ after 10 ::telescope::nextPulseTemma $direction ]
      } elseif { $conf(telescope) == "lx200" } {
         $::conf(telescope)::move $direction $audace(telescope,rate)
      } else {
         tel$audace(telNo) radec move $direction $audace(telescope,rate)
      }
   } else {
      #--- Comme le '::telescope::move' est toujours suivi d'un '::telescope::stop'
      #--- c'est dans le 'stop' que je traite le cas de la monture non connectee
   }
}

#------------------------------------------------------------
## @brief envoie des pulses des boutons cardinaux pour Temma
#  @param direction direction du déplacement (n, s, e ou w)
#
proc ::telescope::nextPulseTemma { direction } {
   variable AfterId
   variable AfterState
   global audace

   if { $AfterState == "1" } {
      tel$audace(telNo) radec move $direction $audace(telescope,rate)
      set AfterId [ after 250 ::telescope::nextPulseTemma $direction ]
   }
}

#------------------------------------------------------------
## @brief arrête le mouvement dans une direction
#  @param direction direction du deplacement (n, s, e ou w)
#
proc ::telescope::stop { direction } {
   variable AfterId
   variable AfterState
   global audace conf

   #--- j'interromps la boucle dans ::telescope::moveTelescope
   set private(telescopeMoving) 0

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         tel$audace(telNo) radec stop $direction
         if { $audace(telescope,speed) == "3" } {
            after 3700
         } else {
            ::telescope::Boucle
         }
      } elseif { $conf(telescope) == "lx200" } {
         tel$audace(telNo) radec stop $direction
         if { $conf(lx200,modele) == "AudeCom" } {
            if { ( $audace(telescope,speed) == "3" ) || ( $audace(telescope,speed) == "4" ) } {
               after 3700
            }
         }
      } elseif { $conf(telescope) == "temma" } {
         set AfterState "0"
         after cancel $AfterId
         tel$audace(telNo) radec stop $direction
      } else {
         tel$audace(telNo) radec stop $direction
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
   }
   ::telescope::afficheCoord
}

#------------------------------------------------------------
#  brief boucle tant que la monture n'est pas arrêtée
#
proc ::telescope::Boucle { } {
   global audace

   #--- Boucle tant que la monture n'est pas arretee
   set radecB0 [ tel$audace(telNo) radec coord -equinox J2000.0 ]
   after 300
   set radecB1 [ tel$audace(telNo) radec coord -equinox J2000.0 ]
   while { $radecB0 != $radecB1 } {
      set radecB0 $radecB1
      after 200
      set radecB1 [ tel$audace(telNo) radec coord -equinox J2000.0 ]
   }
}

#------------------------------------------------------------
## @brief met à jour l'affichage des coordonnées ;
#  interroge la monture et met le résultat dans
#  les variables audace(telescope,getra) et audace(telescope,getdec)
#  @return liste des coordonnées AD et Dec a pointer
#
proc ::telescope::afficheCoord { } {
   global audace caption conf

   set radec ""

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty hasCoordinates ] == "1" } {
         set radec [ tel$audace(telNo) radec coord -equinox J2000.0 ]
         #--- Traitement des coordonnees
         if { [ lindex $radec 0 ] == "tel$audace(telNo)" } {
            set audace(telescope,getra)  "$caption(telescope,astre_est)"
            set audace(telescope,getdec) "$caption(telescope,pas_leve)"
         } else {
            set audace(telescope,getra)  [ lindex $radec 0 ]
            set audace(telescope,getdec) [ lindex $radec 1 ]
            #--- Cas de la monture Temma non connectee
            if { $conf(telescope) == "temma" } {
               #--- Affichage de la position du telescope sur la monture equatoriale allemande
               monture_allemande
               if { [ tel$audace(telNo) firmware ] == "" } {
                  set audace(telescope,getra)  "$caption(telescope,tel)"
                  set audace(telescope,getdec) "$caption(telescope,non_connecte)"
               }
            #--- Cas de la monture AudeCom non connectee
            } elseif { $conf(telescope) == "audecom" } {
               if { [ tel$audace(telNo) firmware ] == "" } {
                  set audace(telescope,getra)  "$caption(telescope,tel)"
                  set audace(telescope,getdec) "$caption(telescope,non_connecte)"
               }
            }
         }
      } else {
         set audace(telescope,getra)  "$caption(telescope,pas_coord1)"
         set audace(telescope,getdec) "$caption(telescope,pas_coord2)"
      }
   } else {
      set audace(telescope,getra)  "$caption(telescope,tel)"
      set audace(telescope,getdec) "$caption(telescope,non_connecte)"
   }

   return $radec
}

#------------------------------------------------------------
## @brief initialise la position du télescope sur la monture allemande ;
#  le tube optique est à l'est ou à l'ouest de la monture ;
#  met à jour la variable audace(pos_tel_ew) avec cette position
#
proc ::telescope::monture_allemande { } {
   global audace caption

   #--- Position E ou O du telescope sur la monture equatoriale allemande
   set pos_tel [ tel$audace(telNo) german ]
   if { $pos_tel == "E" } {
      set audace(pos_tel_ew) "$caption(telescope,cote_est)"
      set audace(chg_pos_tel) "$caption(telescope,cote_ouest)"
   } elseif { $pos_tel == "W" } {
      set audace(pos_tel_ew) "$caption(telescope,cote_ouest)"
      set audace(chg_pos_tel) "$caption(telescope,cote_est)"
   } else {
      set audace(pos_tel_ew) ""
      set audace(chg_pos_tel) "  ?  "
   }
}

#------------------------------------------------------------
## @brief retourne le numéro de la monture secondaire, sinon retourne "0"
#
proc ::telescope::getSecondaryTelNo { } {
   global conf

   if { [ ::confTel::getPluginProperty multiMount ] == "1" } {
      set result [ ::$conf(telescope)::getSecondaryTelNo ]
   } else {
      set result "0"
   }
   return $result
}

#------------------------------------------------------------
## @brief commute le mode slewpath de long a short
#
proc ::telescope::slewpathLong2Short { } {
   global conf

   if { [ info command ::$conf(telescope)::slewpathLong2Short ] != "" } {
      ::$conf(telescope)::slewpathLong2Short
   }
}

#------------------------------------------------------------
## @brief commute le mode slewpath de short a long
#
proc ::telescope::slewpathShort2Long { } {
   global conf

   if { [ info command ::$conf(telescope)::slewpathShort2Long ] != "" } {
      ::$conf(telescope)::slewpathShort2Long
   }
}

#------------------------------------------------------------
## @brief paramètre la vitesse de suivi pour le Soleil ou la Lune
#
proc ::telescope::setTrackSpeed { } {
   global conf

   if { [ info command ::$conf(telescope)::setTrackSpeed ] != "" } {
      ::$conf(telescope)::setTrackSpeed
   }
}

#------------------------------------------------------------
## @brief ajoute une procédure à appeler si on change de vitesse
#  @param cmd commande TCL à lancer quand la vitsse change
#
proc ::telescope::addSpeedListener { cmd } {
   trace add variable "::audace(telescope,speed)" write $cmd
}

#------------------------------------------------------------
## @brief supprime une procédure à appeler si on change de vitesse
#  @param cmd commande TCL à supprimer quand la vitesse change
#
proc ::telescope::removeSpeedListener { cmd } {
   trace remove variable "::audace(telescope,speed)" write $cmd
}

#------------------------------------------------------------
## @brief retourne l'ascension droite de l'objet cible
#
proc ::telescope::getTargetRa { } {
   global audace

   return $audace(telescope,targetRa)
}

#------------------------------------------------------------
## @brief retourne la déclinaison de l'objet cible
#
proc ::telescope::getTargetDec { } {
   global audace

   return $audace(telescope,targetDec)
}

#------------------------------------------------------------
## @brief  retourne le nom de l'objet cible
#
proc ::telescope::getTargetName { } {
   global audace

   return $audace(telescope,targetName)
}

#------------------------------------------------------------
## @brief retourne l'équinoxe des coordonnées de l'objet cible
#
proc ::telescope::getTargetEquinox { } {
   global audace

   return $audace(telescope,targetEquinox)
}

#------------------------------------------------------------
## @brief déplace le télescope pendant un durée determinée ;
#  le déplacement est interrompu si private(telescopeMoving)!=1
#  @param alphaDirection : direction (e ou w) du mouvement en AD
#  @param alphaDiff      : déplacement alpha en arcseconde
#  @param deltaDirection : direction (n ou s) du mouvement en Dec
#  @param deltaDiff      : déplacement delta en arcseconde
#
proc ::telescope::moveTelescope { alphaDirection alphaDiff deltaDirection deltaDiff } {
   variable private
   global audace
   global audace conf

   #--- je recupere les vitesses de guidage (en arseconde par seconde de temps)
   set guidingSpeed  [::confTel::getPluginProperty "guidingSpeed"]
   #--- je calcule le delai de rattrapage
   set alphaDelay    [expr int(1000.0 * ($alphaDiff / [lindex $guidingSpeed 0 ])) ]
   set deltaDelay    [expr int(1000.0 * ($deltaDiff / [lindex $guidingSpeed 1 ])) ]

   set private(telescopeMoving) 1

   if { [ ::confTel::getPluginProperty hasMotionWhile ] == "0" } {
      #--- je demarre le deplacement alpha
      tel$audace(telNo) radec move $alphaDirection $audace(telescope,rate)
      #--- j'attend l'expiration du delai par tranche de 1 seconde
      set delay $alphaDelay
      while { $delay > 0 } {
         if { $private(telescopeMoving) == 1 } {
            if { $delay > 1000 } {
               after 999
               set delay [expr $delay - 1000 ]
            } else {
               after $delay
               set delay 0
            }
         } else {
            #--- j'interromp l'attente s'il y a une demande d'arret
            set delay 0
         }
      }
      #--- j'arrete le deplacement alpha
      tel$audace(telNo) radec stop $alphaDirection
   } else {
      tel$audace(telNo) correct $alphaDirection $alphaDelay
   }

   if { [ ::confTel::getPluginProperty hasMotionWhile ] == "0" } {
      #--- je demarre le deplacement delta
      tel$audace(telNo) radec move $deltaDirection $audace(telescope,rate))
      #--- j'attend l'expiration du delai par tranche de 1 seconde
      set delay $deltaDelay
      while { $delay > 0 } {
         if { $private(telescopeMoving) == 1 } {
            if { $delay > 10000 } {
               after 9990
               set delay [expr $delay - 10000 ]
            } else {
               after $delay
               set delay 0
            }
         } else {
            #--- j'interromp l'attente s'il y a une demande d'arret
            set delay 0
         }
      }
      #--- j'arrete le deplacement delta
      tel$audace(telNo) radec stop $deltaDirection
   } else {
      tel$audace(telNo) correct $deltaDirection $deltaDelay
   }
}

#------------------------------------------------------------
## @brief parque la monture si elle a la propriété "hasPark"
#  @param   state : 1= park , 0=un-park
#
proc ::telescope::park { state } {

   if { [ ::confTel::getPluginProperty hasPark ] == "1" } {
      #--- j'appelle la procedure du telescope
      $::conf(telescope)::park $state
   }
}

::telescope::init

