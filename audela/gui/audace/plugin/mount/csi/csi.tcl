#
# Fichier : csi.tcl
# Description : Configuration de la monture Clear Sky Institute
# Auteur : Alain KLOTZ
# Mise à jour $Id: csi.tcl 9962 2013-08-16 16:24:12Z robertdelmas $
#

namespace eval ::csi {
   package provide csi 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] csi.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::csi::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libcsi.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::csi::getPluginType]] "csi" "libcsi.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(csi,install_1) v[package version csi]. $::caption(csi,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::csi::getPluginTitle { } {
   global caption

   return "$caption(csi,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::csi::getPluginHelp { } {
   return "csi.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::csi::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::csi::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::csi::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::csi::isReady { } {
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
#    Initialise les variables conf(csi,...)
#
proc ::csi::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture CSI
   if { ! [ info exists conf(csi,mode) ] } { set conf(csi,mode) "0" }
   if { ! [ info exists conf(csi,host) ] } { set conf(csi,host) "127.0.0.1" }
   if { ! [ info exists conf(csi,port) ] } { set conf(csi,port) "51717" }
   if { ! [ info exists conf(csi,moteur_on) ] }   { set conf(csi,moteur_on)   "1" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::csi::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture CSI dans le tableau private(...)
   if { $::tcl_platform(os) == "Linux" } {
      set private(mode) "CSI"
   } else {
      set private(mode) [ lindex "CSI" $conf(csi,mode) ]
   }
   set private(host)     $conf(csi,host)
   set private(port)     $conf(csi,port)
   set private(raquette) $conf(raquette)
   set private(csi,moteur_on) $conf(csi,moteur_on)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::csi::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture CSI dans le tableau conf(csi,...)
   if { $::tcl_platform(os) == "Linux" } {
      set conf(csi,mode) "0"
   } else {
      set conf(csi,mode) [ lsearch "CSI" "$private(mode)" ]
   }
   set conf(csi,host) $private(host)
   set conf(csi,port) $private(port)
   set conf(raquette)      $private(raquette)
   set conf(csi,moteur_on)   $private(csi,moteur_on)
}

#
# fillConfigPage
#    Interface de configuration de la monture CSI
#
proc ::csi::fillConfigPage { frm } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Depend de la plateforme
   if { $::tcl_platform(os) == "Linux" } {
      set list_combobox "CSI"
   } else {
      set list_combobox "CSI"
   }

   #--- confToWidget
   ::csi::confToWidget

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
   pack $frm.frame5 -side bottom -fill x -pady 2

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame3 -side left -fill both -expand 1

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame3 -side left -fill both -expand 1

   #--- Definition du mode des donnees transmises au CSI
   label $frm.lab1 -text "$caption(csi,mode)"
   pack $frm.lab1 -in $frm.frame2 -anchor center -side left -padx 10 -pady 10

   ComboBox $frm.mode        \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken         \
      -borderwidth 1         \
      -textvariable ::csi::private(mode) \
      -editable 0            \
      -values $list_combobox \
      -modifycmd "::csi::configurePort"
   pack $frm.mode -in $frm.frame2 -anchor center -side left -padx 30 -pady 10

   #--- Definition du host
   label $frm.lab2 -text "$caption(csi,host)"
   pack $frm.lab2 -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Entry du host
   entry $frm.host -textvariable ::csi::private(host) -width 15 -justify center
   pack $frm.host -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Definition du port
   label $frm.lab3 -text "$caption(csi,port)"
   pack $frm.lab3 -in $frm.frame7 -anchor n -side left -padx 10 -pady 10

   #--- Entry du port
   entry $frm.port -textvariable ::csi::private(port) -width 7 -justify center
   pack $frm.port -in $frm.frame7 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton pour le demarrage du suivi sideral a l'init
   checkbutton $frm.moteur_on -text "$caption(csi,moteur_on)" -highlightthickness 0 -variable ::csi::private(csi,moteur_on)
   pack $frm.moteur_on -in $frm.frame2 -anchor center -side left -padx 10 -pady 10
   
   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(csi,raquette_tel)" \
      -highlightthickness 0 -variable ::csi::private(raquette)
   pack $frm.raquette -in $frm.frame4 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame4 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du CSI
   label $frm.lab103 -text "$caption(csi,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(csi,site_csi)" \
      "$caption(csi,site_csi)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion des widgets pour le mode CSI
   ::csi::configurePort
}

#
# configurePort
#    Configure le host et le port
#
proc ::csi::configurePort { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $private(mode) == "CSI" } {
            $frm.host configure -state normal
            $frm.port configure -state normal
         } else {
            $frm.host configure -state disabled
            $frm.port configure -state disabled
         }
      }
   }
}

#
# configureMonture
#    Configure la monture CSI en fonction des donnees contenues dans les variables conf(csi,...)
#
proc ::csi::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      if { $conf(csi,mode) == "0" } {
         #--- Mode CSI
         if { $conf(csi,moteur_on) == 1 } {
            set telNo [ tel::create csi Ethernet -type CSI -ip $conf(csi,host) -port $conf(csi,port) -startmotor]
         } else {
            set telNo [ tel::create csi Ethernet -type CSI -ip $conf(csi,host) -port $conf(csi,port) ]
         }
      }
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'affiche un message d'information dans la Console
      if { $conf(csi,mode) == "0" } {
         #--- Mode CSI
         ::console::affiche_entete "$caption(csi,port_csi) $caption(csi,2points) Ethernet\n"
         ::console::affiche_entete "$caption(csi,mode) $caption(csi,2points) CSI\n"
         ::console::affiche_saut "\n"
      }
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::csi::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture CSI
#
proc ::csi::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- J'arrete la monture
   tel::delete $private(telNo)
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
proc ::csi::getPluginProperty { propertyName } {
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
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

