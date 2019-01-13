#
# Fichier : ascom.tcl
# Description : Configuration de la monture ASCOM
# Auteur : Michel PUJOL et Robert DELMAS
# Mise à jour $Id: ascom.tcl 12153 2015-07-03 20:14:08Z robertdelmas $
#

namespace eval ::ascom {
   package provide ascom 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ascom.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::ascom::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libascom.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::ascom::getPluginType]] "ascom" "libascom.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(ascom,install_1) v[package version ascom]. $::caption(ascom,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::ascom::getPluginTitle { } {
   global caption

   return "$caption(ascom,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::ascom::getPluginHelp { } {
   return "ascom.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::ascom::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::ascom::getPluginOS { } {
   return [ list Windows ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::ascom::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::ascom::isReady { } {
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
#    Initialise les variables conf(ascom,...)
#
proc ::ascom::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture ASCOM
   if { ! [ info exists conf(ascom,modele) ] } { set conf(ascom,modele) "" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ascom::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture ASCOM dans le tableau private(...)
   set private(modele)   $conf(ascom,modele)
   set private(raquette) $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ascom::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture ASCOM dans le tableau conf(ascom,...)
   set conf(ascom,modele) $private(modele)
   set conf(raquette)     $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture ASCOM
#
proc ::ascom::fillConfigPage { frm } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm)             $frm
   set private(ascomDriverName) ""

   #--- confToWidget
   ::ascom::confToWidget

   #--- Plugins ASCOM installes sur le PC
   package require registry
   set private(ascomDriverNameList) ""
   set private(ascomDriverKeyList)  ""

   #--- je chercher les plugins ASCOM 6.0
   set catchError [ catch {
      set keyList [ ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers" ]
   }]
   if { $catchError == 0 } {
      foreach key $keyList {
         if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers\\$key" "" } name ] == 0 } {
            lappend private(ascomDriverNameList) $name
            lappend private(ascomDriverKeyList)  $key
         }
      }
   }

   #--- Je verifie le contenu de la liste
   if { [llength $private(ascomDriverNameList) ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      set index [ lsearch -exact $private(ascomDriverKeyList) $private(modele) ]
      if { $index == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(modele)          [lindex $private(ascomDriverKeyList) 0]
         set private(ascomDriverName) [lindex $private(ascomDriverNameList) 0]
      } else {
         set private(ascomDriverName) [lindex $private(ascomDriverNameList) $index]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
      set private(modele)          ""
      set private(ascomDriverName) ""
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 0

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side bottom -fill x -pady 2

  #--- Definition du plugin
   label $frm.lab1 -text "$caption(ascom,driver)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

   ComboBox $frm.driver \
      -width [ ::tkutil::lgEntryComboBox $private(ascomDriverNameList) ] \
      -height [ llength $private(ascomDriverNameList) ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::ascom::private(ascomDriverName) \
      -modifycmd ::ascom::onSelectDriver \
      -values $private(ascomDriverNameList)
   pack $frm.driver -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

   #--- Bouton de configuration du plugin
   button $frm.configure -text "$caption(ascom,configurer)" -relief raised \
      -command "::ascom::displayDriverSetupDialog"
   pack $frm.configure -in $frm.frame1 -anchor center -side left -pady 10 -ipadx 10 -ipady 5

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(ascom,raquette_tel)" \
      -highlightthickness 0 -variable ::ascom::private(raquette)
   pack $frm.raquette -in $frm.frame2 -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame2 -side left -padx 0 -pady 10

   #--- Site web officiel des plugins ASCOM
   label $frm.lab103 -text "$caption(ascom,titre_site_web)"
   pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame3 "$caption(ascom,site_web_ref)" \
      "$caption(ascom,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2
}

#
# configureMonture
#    Configure la monture ASCOM en fonction des donnees contenues dans les variables conf(ascom,...)
#
proc ::ascom::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create ascom $conf(ascom,modele) ]
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(ascom,driver) $caption(ascom,2points) [tel$telNo name]\n"
      ::console::affiche_saut "\n"
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
     ### set linkNo [ ::confLink::create $conf(ascom,port) "tel$telNo" "control" [ tel$telNo product ] ]
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::ascom::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture ASCOM
#
proc ::ascom::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Je desactive le rafraichissement automatique des coordonnees AD et Dec.
   tel$private(telNo) radec survey 0
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# onSelectDriver
#    copie la cle du driver choisi dans la variable private(modele)
#s
proc ::ascom::onSelectDriver { } {
   variable private

   set index           [ $private(frm).driver getvalue ]
   set private(modele) [ lindex $private(ascomDriverKeyList) $index ]
}

#
# displayDriverSetupDialog
#    affiche la fenetre de configuration
#    fournie par le driver de la monture
#
proc ::ascom::displayDriverSetupDialog { } {
   variable private

   if { [ ::ascom::isReady ] == 1 } {
      #--- le telescope est deja connecte
      tel$private(telNo) setup
   } else {
      #--- le telescope n'est pas connecte
      if { $private(modele) != "" } {
         load [file join $::audela_start_dir libascom.dll]
         ascom setup $::ascom::private(modele)
      }
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
proc ::ascom::getPluginProperty { propertyName } {
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
      hasModel                { return 1 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

