#
# Fichier : dfm.tcl
# Description : Configuration de la monture DFM
# Auteur : Robert DELMAS
# Mise à jour $Id: dfm.tcl 9942 2013-08-10 08:48:42Z robertdelmas $
#

namespace eval ::dfm {
   package provide dfm 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] dfm.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::dfm::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libdfm.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dfm::getPluginType]] "dfm" "libdfm.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(dfm,install_1) v[package version dfm]. $::caption(dfm,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::dfm::getPluginTitle { } {
   global caption

   return "$caption(dfm,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::dfm::getPluginHelp { } {
   return "dfm.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::dfm::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::dfm::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::dfm::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::dfm::isReady { } {
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
# initPlugin
#    Initialise les variables conf(dfm,...)
#
proc ::dfm::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture DFM
   if { ! [ info exists conf(dfm,mode) ] }      { set conf(dfm,mode)      "0" }
   if { ! [ info exists conf(dfm,host) ] }      { set conf(dfm,host)      "127.0.0.1" }
   if { ! [ info exists conf(dfm,port) ] }      { set conf(dfm,port)      "5003" }
   if { ! [ info exists conf(dfm,portSerie) ] } { set conf(dfm,portSerie) "" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::dfm::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture DFM dans le tableau private(...)
   set private(mode)      [ lindex "TCP EXCOM" $conf(dfm,mode) ]
   set private(host)      $conf(dfm,host)
   set private(port)      $conf(dfm,port)
   set private(portSerie) $conf(dfm,portSerie)
   set private(raquette)  $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::dfm::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture DFM dans le tableau conf(dfm,...)
   set conf(dfm,mode)      [ lsearch "TCP EXCOM" "$private(mode)" ]
   set conf(dfm,host)      $private(host)
   set conf(dfm,port)      $private(port)
   set conf(dfm,portSerie) $private(portSerie)
   set conf(raquette)      $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture DFM
#
proc ::dfm::fillConfigPage { frm } {
   variable private
   global caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(dfm,portSerie) == "" } {
      set conf(dfm,portSerie) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(dfm,portSerie) ] == -1 } {
      lappend list_connexion $conf(dfm,portSerie)
   }

   #--- confToWidget
   ::dfm::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side top -fill x

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -side bottom -fill x -pady 2

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame3 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame3 -side left -fill both -expand 1

   #--- Definition du mode des donnees transmises au DFM
   label $frm.lab1 -text "$caption(dfm,mode)"
   pack $frm.lab1 -in $frm.frame2 -anchor center -side left -padx 10 -pady 10

   set list_combobox "TCP EXCOM"

   ComboBox $frm.mode        \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken         \
      -borderwidth 1         \
      -textvariable ::dfm::private(mode) \
      -editable 0            \
      -values $list_combobox \
      -modifycmd "::dfm::configurePort"
   pack $frm.mode -in $frm.frame2 -anchor center -side left -padx 30 -pady 10

   #--- Definition du host
   label $frm.lab2 -text "$caption(dfm,host)"
   pack $frm.lab2 -in $frm.frame7 -anchor n -side left -padx 10 -pady 10

   #--- Entry du host
   entry $frm.host -textvariable ::dfm::private(host) -width 15 -justify center
   pack $frm.host -in $frm.frame7 -anchor n -side left -padx 10 -pady 10

   #--- Definition du port
   label $frm.lab3 -text "$caption(dfm,port)"
   pack $frm.lab3 -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Entry du port
   entry $frm.port -textvariable ::dfm::private(port) -width 7 -justify center
   pack $frm.port -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Definition du port serie
   label $frm.lab4 -text "$caption(dfm,port)"
   pack $frm.lab4 -in $frm.frame4 -anchor n -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $private(portSerie) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(portSerie) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports
   button $frm.configure -text "$caption(dfm,configurer)" -relief raised \
      -command {
         ::confLink::run ::dfm::private(portSerie) { serialport } \
            "- $caption(dfm,controle) - $caption(dfm,monture)"
      }
   pack $frm.configure -in $frm.frame4 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port
   ComboBox $frm.portSerie \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::dfm::private(portSerie) \
      -editable 0       \
      -values $list_connexion
   pack $frm.portSerie -in $frm.frame4 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(dfm,raquette_tel)" \
      -highlightthickness 0 -variable ::dfm::private(raquette)
   pack $frm.raquette -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame5 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du DFM
   label $frm.lab103 -text "$caption(dfm,titre_site_web)"
   pack $frm.lab103 -in $frm.frame6 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame6 "$caption(dfm,site_dfm)" \
      "$caption(dfm,site_dfm)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion des widgets pour le mode TCP ou EXCOM
   ::dfm::configurePort
}

#
# configurePort
#    Configure le host et les ports
#
proc ::dfm::configurePort { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $private(mode) == "TCP" } {
            $frm.host configure -state normal
            $frm.port configure -state normal
            $frm.configure configure -state disabled
            $frm.portSerie configure -state disabled
         } else {
            $frm.host configure -state disabled
            $frm.port configure -state disabled
            $frm.configure configure -state normal
            $frm.portSerie configure -state normal
         }
      }
   }
}

#
# configureMonture
#    Configure la monture DFM en fonction des donnees contenues dans les variables conf(dfm,...)
#
proc ::dfm::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      if { $conf(dfm,mode) == "0" } {
         #--- Mode TCP
         set telNo [ tel::create dfm TCP -ip $conf(dfm,host) -port $conf(dfm,port) ]
      } else {
         #--- Mode EXCOM
         set telNo [ tel::create dfm $conf(dfm,portSerie) ]
      }
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'affiche un message d'information dans la Console
      if { $conf(dfm,mode) == "0" } {
         #--- Mode TCP
         ::console::affiche_entete "$caption(dfm,port_dfm) $caption(dfm,2points) Ethernet\n"
         ::console::affiche_entete "$caption(dfm,mode) $caption(dfm,2points) TCP\n"
         ::console::affiche_entete "$caption(dfm,host) $caption(dfm,2points) $conf(dfm,host)\n"
         ::console::affiche_entete "$caption(dfm,port) $caption(dfm,2points) $conf(dfm,port)\n"
         ::console::affiche_saut "\n"
      } else {
         #--- Mode EXCOM
         ::console::affiche_entete "$caption(dfm,port_dfm) $caption(dfm,2points) $conf(dfm,portSerie)\n"
         ::console::affiche_entete "$caption(dfm,mode) $caption(dfm,2points) EXCOM\n"
         ::console::affiche_saut "\n"
      }
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      if { $conf(dfm,mode) == "1" } {
         #--- Mode EXCOM
         set linkNo [ ::confLink::create $conf(dfm,portSerie) "tel$telNo" "control" [ tel$telNo product ] -noopen  ]
      }
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::dfm::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture DFM
#
proc ::dfm::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Je memorise le port
   if { $conf(dfm,mode) == "1" } {
      #--- Mode EXCOM
      set telPort [ tel$private(telNo) port ]
   }
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
   if { $conf(dfm,mode) == "1" } {
      #--- Mode EXCOM
      ::confLink::delete $telPort "tel$private(telNo)" "control"
   }
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
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
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::dfm::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              { return 0 }
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
      hasControlSuivi         { return 0 }
      hasModel                { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

