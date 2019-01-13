#
# Fichier : mcmt.tcl
# Description : Configuration de la monture MCMT
# Auteur : Alain KLOTZ
# Mise à jour $Id: mcmt.tcl 14405 2018-04-12 20:06:27Z robertdelmas $
#

namespace eval ::mcmt {
   package provide mcmt 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] mcmt.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::mcmt::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libmcmt.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::mcmt::getPluginType]] "mcmt" "libmcmt.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(mcmt,install_1) v[package version mcmt]. $::caption(mcmt,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::mcmt::getPluginTitle { } {
   global caption

   return "$caption(mcmt,monture)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::mcmt::getPluginHelp { } {
   return "mcmt.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::mcmt::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::mcmt::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::mcmt::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::mcmt::isReady { } {
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
#    Initialise les variables conf(mcmt,...)
#
proc ::mcmt::initPlugin { } {
   variable private
   global conf

   #--- Initialisation de variables
   set private(telNo)         "0"

   #--- Initialise les variables de la monture mcmt
   if { ! [ info exists conf(mcmt,port) ] }      { set conf(mcmt,port)      "" }
   if { ! [ info exists conf(mcmt,majPosGPS) ] } { set conf(mcmt,majPosGPS) "1" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::mcmt::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture mcmt dans le tableau private(...)
   set private(port)      $conf(mcmt,port)
   set private(majPosGPS) $conf(mcmt,majPosGPS)
   set private(raquette)  $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::mcmt::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture mcmt dans le tableau conf(mcmt,...)
   set conf(mcmt,port)      $private(port)
   set conf(mcmt,majPosGPS) $private(majPosGPS)
   set conf(raquette)       $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture mcmt
#
proc ::mcmt::fillConfigPage { frm } {
   variable private
   global audace caption conf

   #--- Initialise les variables locales
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(mcmt,port) == "" } {
      set conf(mcmt,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(mcmt,port) ] == -1 } {
      lappend list_connexion $conf(mcmt,port)
   }

   #--- confToWidget
   ::mcmt::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill x

   frame $frm.frame4a -borderwidth 0 -relief raised
   pack $frm.frame4a -side top -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side bottom -fill x -pady 2

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame6 -side top -fill x

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame6 -side top -fill x

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame7 -side top -fill x

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame7 -side top -fill x

   #--- Definition du port
   label $frm.lab1 -text "$caption(mcmt,port_liaison)"
   pack $frm.lab1 -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $private(port) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports
   button $frm.configure -text "$caption(mcmt,configurer)" -relief raised \
      -command {
         ::confLink::run ::mcmt::private(port) { serialport } \
            "- $caption(mcmt,controle) - $caption(mcmt,monture)"
      }
   pack $frm.configure -in $frm.frame8 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::mcmt::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton pour la mise a jour de la position GPS du MCMT
   checkbutton $frm.majPosGPS -text "$caption(mcmt,maj_mcmt)" \
      -highlightthickness 0 -variable ::mcmt::private(majPosGPS) \
      -command "::mcmt::majPosGPS"
   pack $frm.majPosGPS -in $frm.frame2 -anchor w -side left -padx 10 -pady 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(mcmt,raquette_tel)" \
      -highlightthickness 0 -variable ::mcmt::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Bouton park
   button $frm.park -text "$caption(mcmt,park)" -relief raised -command "::telescope::park 1" \
      -state disabled
   pack $frm.park -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Bouton unpark
   button $frm.unpark -text "$caption(mcmt,unpark)" -relief raised -command "::telescope::park 0" \
      -state disabled
   pack $frm.unpark -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Site web officiel du mcmt
   label $frm.lab103 -text "$caption(mcmt,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(mcmt,site_web_ref)" \
      "$caption(mcmt,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::mcmt::confMcmt
}

#
# configureMonture
#    Configure la monture mcmt en fonction des donnees contenues dans les variables conf(mcmt,...)
#
proc ::mcmt::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create mcmt $conf(mcmt,port) -name mcmt ]
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(mcmt,port_mcmt) $caption(mcmt,2points) $conf(mcmt,port)\n"
      ::console::affiche_saut "\n"
      #--- Je configure la position geographique de la monture et le nom de l'observatoire
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      if { $conf(mcmt,majPosGPS) == "1" } {
         tel$telNo home $::audace(posobs,observateur,gps)
         tel$telNo home name $::conf(posobs,nom_observatoire)
      }
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(mcmt,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Traces dans la Console
      #-- inactivée car cette fonction n'existe pas
      #::mcmt::tracesConsole
      #--- Gestion des boutons actifs/inactifs
      ::mcmt::confMcmt
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::mcmt::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture mcmt
#
proc ::mcmt::stop { } {
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
   ::mcmt::confMcmt
}

#
# confMcmt
# Permet d'activer ou de desactiver les boutons
#
proc ::mcmt::confMcmt { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::mcmt::isReady ] == 1 } {
            #--- Bouton park actif
            $frm.park configure -state normal
            #--- Bouton unpark actif
            $frm.unpark configure -state normal
         } else {
            #--- Bouton park inactif
            $frm.park configure -state disabled
            #--- Bouton unpark inactif
            $frm.unpark configure -state disabled
         }
      }
   }
}

#
# majPosGPS
#    Met a jour la position GPS dans le MCMT
#
proc ::mcmt::majPosGPS { } {
   variable private

   if { $private(telNo) == "0" } {
      return
   }

   if { $private(majPosGPS)== "1" } {
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
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::mcmt::getPluginProperty { propertyName } {
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
      hasControlSuivi         { return 1 }
      hasModel                { return 0 }
      hasPark                 { return 1 }
      hasUnpark               { return 1 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

#------------------------------------------------------------
# park
#    parque/deparque la monture
#
# Parametres :
#    state : 1 = park , 0 = unpark
# Return :
#    rien
#------------------------------------------------------------
proc ::mcmt::park { state } {
   variable private

   if { $state == 1 } {
      #--- je parque la monture

   } elseif { $state == 0 } {
      #--- je deparque la monture

   }
}

