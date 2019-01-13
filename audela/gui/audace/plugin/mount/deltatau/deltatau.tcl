#
# Fichier : deltatau.tcl
# Description : Configuration de la monture Delta Tau
# Auteur : Alain KLOTZ
# Mise à jour $Id: deltatau.tcl 14429 2018-05-30 22:21:34Z alainklotz $
#

namespace eval ::deltatau {
   package provide deltatau 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] deltatau.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::deltatau::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libdeltatau.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::deltatau::getPluginType]] "deltatau" "libdeltatau.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace Pmac.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::deltatau::getPluginType]] "deltatau" "Pmac.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(deltatau,install_1) v[package version deltatau]. $::caption(deltatau,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::deltatau::getPluginTitle { } {
   global caption

   return "$caption(deltatau,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::deltatau::getPluginHelp { } {
   return "deltatau.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::deltatau::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::deltatau::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::deltatau::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::deltatau::isReady { } {
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
#    Initialise les variables conf(deltatau,...)
#
proc ::deltatau::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture Delta Tau
   if { ! [ info exists conf(deltatau,mode) ] } { set conf(deltatau,mode) "0" }
   if { ! [ info exists conf(deltatau,telname) ] } { set conf(deltatau,telname) "0" }
   if { ! [ info exists conf(deltatau,host) ] } { set conf(deltatau,host) "127.0.0.1" }
   if { ! [ info exists conf(deltatau,port) ] } { set conf(deltatau,port) "1025" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::deltatau::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Delta Tau dans le tableau private(...)
   if { $::tcl_platform(os) == "Linux" } {
      #set private(mode) "Umac"
      set private(mode) [ lindex "Umac Pmac" $conf(deltatau,mode) ]
   } else {
      set private(mode) [ lindex "Umac Pmac" $conf(deltatau,mode) ]
   }
   set private(telname)  $conf(deltatau,telname)
   set private(host)     $conf(deltatau,host)
   set private(port)     $conf(deltatau,port)
   set private(raquette) $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::deltatau::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Delta Tau dans le tableau conf(deltatau,...)
   if { $::tcl_platform(os) == "Linux" } {
      #set conf(deltatau,mode) "0"
      set conf(deltatau,mode) [ lsearch "Umac Pmac" "$private(mode)" ]
   } else {
      set conf(deltatau,mode) [ lsearch "Umac Pmac" "$private(mode)" ]
   }
   set conf(deltatau,telname) $private(telname)
   set conf(deltatau,host)    $private(host)
   set conf(deltatau,port)    $private(port)
   set conf(raquette)         $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture Delta Tau
#
proc ::deltatau::fillConfigPage { frm } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Depend de la plateforme
   if { $::tcl_platform(os) == "Linux" } {
      set list_combobox "Umac"
   } else {
      set list_combobox "Umac Pmac"
   }
   set list_telname_combobox "tch tca"

   #--- confToWidget
   ::deltatau::confToWidget

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

   #--- Definition du mode des donnees transmises au Delta Tau
   label $frm.lab1 -text "$caption(deltatau,mode)"
   pack $frm.lab1 -in $frm.frame2 -anchor center -side left -padx 10 -pady 10

   ComboBox $frm.mode        \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken         \
      -borderwidth 1         \
      -textvariable ::deltatau::private(mode) \
      -editable 0            \
      -values $list_combobox \
      -modifycmd "::deltatau::configurePort"
   pack $frm.mode -in $frm.frame2 -anchor center -side left -padx 30 -pady 10

   #--- Definition du nom du telescope pilote par Delta Tau
   label $frm.lab1b -text "$caption(deltatau,telname)"
   pack $frm.lab1b -in $frm.frame2 -anchor center -side left -padx 10 -pady 10

   ComboBox $frm.telname        \
      -width [ ::tkutil::lgEntryComboBox $list_telname_combobox ] \
      -height [ llength $list_telname_combobox ] \
      -relief sunken         \
      -borderwidth 1         \
      -textvariable ::deltatau::private(telname) \
      -editable 0            \
      -values $list_telname_combobox \
      -modifycmd "::deltatau::configureTelname"
   pack $frm.telname -in $frm.frame2 -anchor center -side left -padx 30 -pady 10

   #--- Definition du host
   label $frm.lab2 -text "$caption(deltatau,host)"
   pack $frm.lab2 -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Entry du host
   entry $frm.host -textvariable ::deltatau::private(host) -width 15 -justify center
   pack $frm.host -in $frm.frame6 -anchor n -side left -padx 10 -pady 10

   #--- Definition du port
   label $frm.lab3 -text "$caption(deltatau,port)"
   pack $frm.lab3 -in $frm.frame7 -anchor n -side left -padx 10 -pady 10

   #--- Entry du port
   entry $frm.port -textvariable ::deltatau::private(port) -width 7 -justify center
   pack $frm.port -in $frm.frame7 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(deltatau,raquette_tel)" \
      -highlightthickness 0 -variable ::deltatau::private(raquette)
   pack $frm.raquette -in $frm.frame4 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame4 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du Delta Tau
   label $frm.lab103 -text "$caption(deltatau,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(deltatau,site_deltatau)" \
      "$caption(deltatau,site_deltatau)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion des widgets pour le mode Umac
   ::deltatau::configurePort
   ::deltatau::configureTelname
}

#
# configurePort
#    Configure le host et le port
#
proc ::deltatau::configurePort { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $private(mode) == "Umac" } {
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
# configureTelname
#    Configure le nom du telescope
#
proc ::deltatau::configureTelname { } {
   variable private
}

#
# configureMonture
#    Configure la monture Delta Tau en fonction des donnees contenues dans les variables conf(deltatau,...)
#
proc ::deltatau::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      if { $conf(deltatau,mode) == "1" } {
         #--- Mode Pmac
         set telNo [ tel::create deltatau PCI -type pmac -telname $conf(deltatau,telname)]
      } else {
         #--- Mode Umac
         set telNo [ tel::create deltatau Ethernet -type umac -ip $conf(deltatau,host) -port $conf(deltatau,port) -telname $conf(deltatau,telname)]
      }
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'affiche un message d'information dans la Console
      if { $conf(deltatau,mode) == "1" } {
         #--- Mode Pmac
         ::console::affiche_entete "$caption(deltatau,port_deltatau) $caption(deltatau,2points) PCI\n"
         ::console::affiche_entete "$caption(deltatau,mode) $caption(deltatau,2points) Pmac\n"
         ::console::affiche_saut "\n"
      } else {
         #--- Mode Umac
         ::console::affiche_entete "$caption(deltatau,port_deltatau) $caption(deltatau,2points) Ethernet\n"
         ::console::affiche_entete "$caption(deltatau,mode) $caption(deltatau,2points) Umac\n"
         ::console::affiche_entete "$caption(deltatau,host) $caption(deltatau,2points) $conf(deltatau,host)\n"
         ::console::affiche_entete "$caption(deltatau,port) $caption(deltatau,2points) $conf(deltatau,port)\n"
         ::console::affiche_saut "\n"
      }
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::deltatau::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture Delta Tau
#
proc ::deltatau::stop { } {
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
proc ::deltatau::getPluginProperty { propertyName } {
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

