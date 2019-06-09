#
# Fichier : inditel.tcl
# Description : Configuration des télescopes INDI
# Auteur : Damien BOUREILLE
# Mise à jour $Id: inditel.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::inditel {
   package provide inditel 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] inditel.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::inditel::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libinditel.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::inditel::getPluginType]] "inditel" "libinditel.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(inditel,installNewVersion) $sourceFileName [package version inditel] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::inditel::getPluginTitle { } {
   global caption

   return "$caption(inditel,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::inditel::getPluginHelp { } {
   return "inditel.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::inditel::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::inditel::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::inditel::getPluginDirectory { } {
   return "inditel"
}

# getTelNo
#    Retourne le numero de la monture
#
proc ::inditel::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::inditel::isReady { } {
   variable private

   if { $private(telNo) == "0" } {
      #--- Monture KO
      return 0
   } else {
      #--- Monture OK
      return 1
   }
}

#
# getSecondaryTelNo
#    Retourne le numero de la monture secondaire, sinon retourne "0"
#
proc ::inditel::getSecondaryTelNo { } {
   set result [ ::ouranos::getTelNo ]
   return $result
}

#
# initPlugin
#    Initialise les variables conf(indicam,...)
#
proc ::inditel::initPlugin { } {
   variable private
   global conf

   #--- Initialisation de variables
   set private(telNo)         "0"

   #--- Initialise les variables de la monture inditel
   
   if { ! [ info exists conf(inditel,host) ] }              { set conf(inditel,host)              "localhost" }
   if { ! [ info exists conf(inditel,port) ] }              { set conf(inditel,port)              "7624" }
   if { ! [ info exists conf(inditel,ouranos) ] }           { set conf(inditel,ouranos)           "0" }
   if { ! [ info exists conf(inditel,modele) ] }            { set conf(inditel,modele)            "LX200" }
   if { ! [ info exists conf(inditel,format) ] }            { set conf(inditel,format)            "1" }
   if { ! [ info exists conf(inditel,majDatePosGPS) ] }     { set conf(inditel,majDatePosGPS)     "1" }
   if { ! [ info exists conf(inditel,ite-lente_tempo) ] }   { set conf(inditel,ite-lente_tempo)   "10" }
   if { ! [ info exists conf(inditel,alphaGuidingSpeed) ] } { set conf(inditel,alphaGuidingSpeed) "3.0" }
   if { ! [ info exists conf(inditel,deltaGuidingSpeed) ] } { set conf(inditel,deltaGuidingSpeed) "3.0" }
}

   

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::inditel::confToWidget { } {
   variable widget
   global caption conf
   #--- Recupere la configuration de la monture inditel dans le tableau private(...)
   set private(port)              $conf(inditel,port)
   set private(ouranos)           $conf(inditel,ouranos)
   set private(modele)            $conf(inditel,modele)
   set private(format)            [ lindex "$caption(inditel,format_court_long)" $conf(inditel,format) ]
   set private(majDatePosGPS)     $conf(inditel,majDatePosGPS)
   set private(ite-lente_tempo)   $conf(inditel,ite-lente_tempo)
   set private(raquette)          $conf(raquette)
   set private(alphaGuidingSpeed) $conf(inditel,alphaGuidingSpeed)
   set private(deltaGuidingSpeed) $conf(inditel,deltaGuidingSpeed)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::inditel::widgetToConf {  } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture LX200 dans le tableau conf(inditel,...)
   set conf(inditel,port)              $private(port)
   set conf(inditel,ouranos)           $private(ouranos)
   set conf(inditel,modele)            $private(modele)
   set conf(inditel,format)            [ lsearch "$caption(inditel,format_court_long)" "$private(format)" ]
   set conf(inditel,majDatePosGPS)     $private(majDatePosGPS)
   set conf(inditel,ite-lente_tempo)   $private(ite-lente_tempo)
   set conf(raquette)                $private(raquette)
   set conf(inditel,alphaGuidingSpeed) $private(alphaGuidingSpeed)
   set conf(inditel,deltaGuidingSpeed) $private(deltaGuidingSpeed)
}

#
# fillConfigPage
#    Interface de configuration de la camera indicam
#
proc ::inditel::fillConfigPage { frm } {
   variable private
   variable widget
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::inditel::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Je recupere la liste des télescopes
      
	set list_combobox ""
	lappend list_combobox "Telescope Simulator"
	   
   #--- Frame de la configuration du port
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Definition du port
      label $frm.frame1.lab1 -text "$caption(inditel,device)"
      pack $frm.frame1.lab1 -anchor center -side left -padx 10

      #--- Choix du port ou de la liaison
      ComboBox $frm.frame1.device \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::indicam::widget(device) \
         -values $list_combobox \
         
      pack $frm.frame1.device -anchor center -side left -padx 10

      #--- Frame pour la definition de l'IP et port du serveur INDI
      frame $frm.frame1.address -borderwidth 0 -relief raised

         #--- Frame pour la definition de l'IP INDI
         frame $frm.frame1.address.ethernet -borderwidth 0 -relief flat

            #--- Definition du host pour une connexion Ethernet
            label $frm.frame1.address.ethernet.lab2 -text "$caption(inditel,host)"
            pack  $frm.frame1.address.ethernet.lab2 -anchor center -side left -padx 10

            entry $frm.frame1.address.ethernet.host -width 18 -textvariable ::inditel::widget(host)
            pack  $frm.frame1.address.ethernet.host -anchor center -side right -padx 10

         pack $frm.frame1.address.ethernet -anchor center -side top -padx 10 -fill both -expand 1

      pack $frm.frame1.address -anchor center -side right -padx 2

#--- Frame pour la definition du port INDI
         frame $frm.frame1.address.port -borderwidth 0 -relief flat

            #--- Definition du port INDI
            label $frm.frame1.address.port.label -text "$caption(inditel,port)" \
               -highlightthickness 0 
            pack  $frm.frame1.address.port.label -anchor center -side left -padx 10

            entry $frm.frame1.address.port.entry -width 18 -textvariable ::inditel::widget(port)
            pack  $frm.frame1.address.port.entry -anchor center -side right -padx 10

         pack $frm.frame1.address.port -anchor center -side top -padx 10 -fill both -expand 1

         
   pack $frm.frame1 -side top -fill both -expand 1

   
   
      #--- Frame du site web officiel de la indicam
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(inditel,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(inditel,site_web_ref)" \
         "$caption(inditel,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureMonture
#    Configure la monture LX200 en fonction des donnees contenues dans les variables conf(inditel,...)
#
proc ::inditel::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      switch [::confLink::getLinkNamespace $conf(inditel,port)] {
         serialport {
            #--- Je cree la monture
            set telNo [ tel::create inditel $conf(inditel,port) -name $conf(inditel,modele) ]
            #--- J'affiche un message d'information dans la Console
            ::console::affiche_entete "$caption(inditel,port_inditel) ($conf(inditel,modele))\
               $caption(inditel,2points) $conf(inditel,port)\n"
            ::console::affiche_saut "\n"
            #--- Cas particulier du modele Ite-lente
            if { $conf(inditel,modele) == "Ite-lente" } {
               tel$telNo tempo $conf(inditel,ite-lente_tempo)
            }
         }
      }
      #--- Je configure la position geographique de la monture et le nom de l'observatoire
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      if { $conf(inditel,majDatePosGPS) == "1" } {
         tel$telNo date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
         tel$telNo home $::audace(posobs,observateur,gps)
         tel$telNo home name $::conf(posobs,nom_observatoire)
      }
      #--- Je choisis le format des coordonnees AD et Dec.
      if { $conf(inditel,format) == "0" } {
         tel$telNo longformat off
      } else {
         tel$telNo longformat on
      }
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(inditel,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Traces dans la Console
      #-- inactivée car cette fonction n'existe pas
      #::inditel::tracesConsole
      #--- Gestion des boutons actifs/inactifs
      ::inditel::confLX200

      #--- Si connexion des codeurs Ouranos demandee en tant que monture secondaire
      if { $conf(inditel,ouranos) == "1" } {
         #--- Je copie les parametres Ouranos dans conf()
         ::ouranos::widgetToConf
         #--- Je configure la monture secondaire Ouranos
         ::ouranos::configureMonture
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::inditel::stop
      if { $conf(inditel,ouranos) == "1" } {
         ::ouranos::stop
      }
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture LX200
#
proc ::inditel::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Je desactive le rafraichissement automatique des coordonnees AD et Dec.
   tel$private(telNo) radec survey 0
   #--- Je memorise le port
   set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
    ::confLink::delete $telPort "tel$private(telNo)" "control"
   set private(telNo) "0"

   #--- Gestion des boutons actifs/inactifs
   ::inditel::confLX200

   #--- Deconnexion des codeurs Ouranos si la monture secondaire existe
   if { $conf(inditel,ouranos) == "1" } {
      ::ouranos::stop
   }
}

#
# confLX200
# Permet d'activer ou de desactiver les boutons
#
proc ::inditel::confLX200 { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::inditel::isReady ] == 1 } {
            #--- Cas des modeles qui ont la fonction "park"
            if { [ ::confTel::getPluginProperty hasPark ] == "1" } {
               #--- Bouton park actif
               $frm.park configure -state normal
            }
            #--- Cas des modeles qui ont la fonction "unpark"
            if { [ ::confTel::getPluginProperty hasUnpark ] == "1" } {
               #--- Bouton unpark actif
               $frm.unpark configure -state normal
            }
            #--- Cas du modele Ite-Lente
            if { $private(modele) == "$caption(inditel,modele_ite-lente)" } {
               $frm.ite-lente_A0 configure -state normal
               $frm.ite-lente_A1 configure -state normal
               $frm.ite-lente_ack configure -state normal
            }
         } else {
            #--- Bouton park inactif
            $frm.park configure -state disabled
            #--- Bouton unpark inactif
            $frm.unpark configure -state disabled
            #--- Boutons du modele Ite-Lente
            if { [ winfo exists $frm.ite-lente_A0 ] } {
               $frm.ite-lente_A0 configure -state disabled
               $frm.ite-lente_A1 configure -state disabled
               $frm.ite-lente_ack configure -state disabled
            }
         }
      }
   }
}

#
# confModele
# Permet d'activer ou de desactiver les champs lies au modele
#
proc ::inditel::confModele { } {
   variable private
   global audace caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Cas du modele IteLente
         if { $private(modele) == "$caption(inditel,modele_ite-lente)" } {
            if { ! [ winfo exists $frm.lab4 ] } {
               #--- Label de la tempo Ite-lente
               label $frm.lab4 -text "$caption(inditel,ite-lente_tempo)"
               pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
            }
            if { ! [ winfo exists $frm.tempo ] } {
               #--- Entree de la tempo Ite-lente
               entry $frm.tempo -textvariable ::inditel::private(ite-lente_tempo) -justify center -width 5
               pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
               #--- Bouton GO/Stop A0
               checkbutton $frm.ite-lente_A0 -text "$caption(inditel,ite-lente_A0,go)" -relief raised -indicatoron 0 \
                  -variable ::inditel::private(ite-lente_A0) -state disabled \
                  -command "::inditel::testIteLente ite-lente_A0"
               pack $frm.ite-lente_A0 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
               #--- Bouton GO/Stop A1
               checkbutton $frm.ite-lente_A1 -text "$caption(inditel,ite-lente_A1,go)" -relief raised -indicatoron 0 \
                  -variable ::inditel::private(ite-lente_A1) -state disabled \
                  -command "::inditel::testIteLente ite-lente_A1"
               pack $frm.ite-lente_A1 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
               #--- Bouton ACK
               button $frm.ite-lente_ack -text "$caption(inditel,ite-lente_ack)" -relief raised \
                  -state disabled -command "::inditel::testIteLente ite-lente_ack"
               pack $frm.ite-lente_ack -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
            }
         } else {
            destroy $frm.lab4 ; destroy $frm.tempo
            destroy $frm.ite-lente_A0 ; destroy $frm.ite-lente_A1 ; destroy $frm.ite-lente_ack
         }
         #--- Cas du modele AudeCom
         if { $private(modele) == "$caption(inditel,modele_audecom)" } {
            if { [glob -nocomplain -type f -join "$audace(rep_plugin)" mount ouranos pkgIndex.tcl ] == "" } {
               set private(ouranos) "0"
               $frm.ouranos configure -state disabled
               pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
            } else {
               $frm.ouranos configure -state normal
            }
         } else {
            set private(ouranos) "0"
            $frm.ouranos configure -state disabled
         }
         #--- Cas des modeles acceptant la mise a jour de la date et de la position GPS de la monture
         if {  $private(modele) == $::caption(inditel,modele_inditel)
            || $private(modele) == $::caption(inditel,modele_inditel_gps)
            || $private(modele) == $::caption(inditel,modele_skysensor)
            || $private(modele) == $::caption(inditel,modele_gemini)
            || $private(modele) == $::caption(inditel,modele_astro_physics)} {
            $frm.majDatePosGPS configure -state normal
         } else {
            $frm.majDatePosGPS configure -state disabled
         }
      }
   }
}

#
# testIteLente
#    Envoie les commandes A0, A1 et ACK
#
proc ::inditel::testIteLente { buttonName } {
   variable private
   global caption

   switch $buttonName {
      ite-lente_A0 {
         if { $private($buttonName) == "1" } {
            tel$private(telNo) command "#:Xa+#" none
            $private(frm).$buttonName configure -text $caption(inditel,$buttonName,stop)
         } else {
            tel$private(telNo) command "#:Xa-#" none
            $private(frm).$buttonName configure -text $caption(inditel,$buttonName,go)
         }
      }
      ite-lente_A1 {
         if { $private($buttonName) == "1" } {
            tel$private(telNo) command "#:Xb+#" none
            $private(frm).$buttonName configure -text $caption(inditel,$buttonName,stop)
         } else {
            tel$private(telNo) command "#:Xb-#" none
            $private(frm).$buttonName configure -text $caption(inditel,$buttonName,go)
         }
      }
      ite-lente_ack {
         tel$private(telNo) command "\x06" ok
      }
   }
}

#
# majDatePosGPS
#    Met a jour la date et la position GPS dans le LX200
#
proc ::inditel::majDatePosGPS { } {
   variable private

   if { $private(telNo) == "0" } {
      return
   }

   if { $private(majDatePosGPS)== "1" } {
      tel$private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
      tel$private(telNo) home $::audace(posobs,observateur,gps)
      tel$private(telNo) home name $::conf(posobs,nom_observatoire)
   }
}

#
# getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# multiMount              Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
# name                    Retourne le modele de la monture
# product                 Retourne le nom du produit
# hasCoordinates          Retourne la possibilite d'afficher les coordonnees
# hasGoto                 Retourne la possibilite de faire un Goto
# hasMatch                Retourne la possibilite de faire un Match
# hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
# hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
# hasModel                Retourne la possibilite d'avoir plusieurs modeles pour le meme product
# hasMotionWhile          Retourne la possibilite d'avoir des deplacements cardinaux pendant une duree
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::inditel::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              {
         if { $::conf(inditel,modele) == "$::caption(inditel,modele_audecom)" } {
            return 1
         } else {
            return 0
         }
      }
      name                    {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) name ]
         } else {
            return ""
         }
      }
      product                 {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) product ]
         } else {
            return ""
         }
      }
      hasCoordinates          { return 1 }
      hasGoto                 { return 1 }
      hasMatch                { return 1 }
      hasManualMotion         { return 1 }
      hasControlSuivi         { return 1 }
      hasModel                { return 1 }
      hasMotionWhile          {
         if { $::conf(inditel,modele) == "$::caption(inditel,modele_ite-lente)" } {
            return 1
         } else {
            return 0
         }
      }
      hasPark                 {
         if {  $::conf(inditel,modele) == $::caption(inditel,modele_inditel)
            || $::conf(inditel,modele) == $::caption(inditel,modele_inditel_gps)
            || $::conf(inditel,modele) == $::caption(inditel,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUnpark               {
         if { $::conf(inditel,modele) == $::caption(inditel,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUpdateDate           {
         if {  $::conf(inditel,modele) == $::caption(inditel,modele_inditel)
            || $::conf(inditel,modele) == $::caption(inditel,modele_inditel_gps)
            || $::conf(inditel,modele) == $::caption(inditel,modele_skysensor)
            || $::conf(inditel,modele) == $::caption(inditel,modele_gemini)
            || $::conf(inditel,modele) == $::caption(inditel,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      backlash                { return 0 }
      guidingSpeed            { return [list $::conf(inditel,alphaGuidingSpeed) $::conf(inditel,deltaGuidingSpeed) ] }
   }
}

#------------------------------------------------------------
# park
#    parque la monture
#
# Parametres :
#    state : 1= park , 0=un-park
# Return :
#    rien
#------------------------------------------------------------
proc ::inditel::park { state } {
   variable private

   if {  $::conf(inditel,modele) == $::caption(inditel,modele_inditel)
      || $::conf(inditel,modele) == $::caption(inditel,modele_inditel_gps)} {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":hP#" none
      } elseif { $state == 0 } {
         #--- je ne fais rien car Meade n'a pas la fonction un-park
      }
   } elseif { $::conf(inditel,modele) == $::caption(inditel,modele_astro_physics)} {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":KA#" none
      } elseif { $state == 0 } {
         #--- j'envoie l'heure courante
         tel$::inditel::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
         #--- je de-parque la monture
         tel$private(telNo) command ":PO#" none
      }
   }
}

proc ::inditel::move { direction rate } {
   global conf caption
   variable private

   if {$conf(inditel,modele) != $caption(inditel,modele_astro_physics)} {
      # Cas normal, le driver va faire le necessaire */
      tel$private(telNo) radec move $direction $rate
   } else {
      
      # Commande de vitesse
      if {$rate < 0.33} {
         # x1
         tel$private(telNo) command ":RG2#" none
      } elseif {$rate < 0.66} {
         # x12
         tel$private(telNo) command ":RC0#" none
      } elseif {$rate < 1} {
         # x64
         tel$private(telNo) command ":RC1#" none
      } else {
         # x600
         tel$private(telNo) command ":RC2#" none
      }

      # Commande de mouvement NEWS
      set d [lindex [string toupper $direction] 0]
      if { $d == "N" } {
         tel$private(telNo) command ":Mn#" none
      } elseif { $d == "S" } {
         tel$private(telNo) command ":Ms#" none
      } elseif { $d == "E" } {
         tel$private(telNo) command ":Me#" none
      } elseif { $d == "W" } {
         tel$private(telNo) command ":Mw#" none
      } else {
         ::console::affiche_entete "AP command set : unknow direction"
      }
   }

}

