#
# Fichier : telscript.tcl
# Description : Configuration de la monture TelScript
# Auteur : Alain KLOTZ
# Mise à jour $Id: telscript.tcl 12466 2015-12-28 15:41:40Z robertdelmas $
#

namespace eval ::telscript {
   package provide telscript 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] telscript.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::telscript::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libtelscript.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::telscript::getPluginType]] "telscript" "libtelscript.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libeteltcl.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::telscript::getPluginType]] "telscript" "libeteltcl.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(telscript,install_1) v[package version telscript]. $::caption(telscript,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::telscript::getPluginTitle { } {
   global caption

   return "$caption(telscript,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::telscript::getPluginHelp { } {
   return "telscript.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::telscript::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::telscript::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::telscript::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::telscript::isReady { } {
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
#    Initialise les variables conf(telscript,...)
#
proc ::telscript::initPlugin { } {
   variable private
   global audace conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture TelScript
   if { ! [ info exists conf(telscript,script) ] }  { set conf(telscript,script)  [ file join $audace(rep_plugin) mount telscript telscript_template_equatorial.tcl ] }
   if { ! [ info exists conf(telscript,telname) ] } { set conf(telscript,telname) "mount_name" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::telscript::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture TelScript dans le tableau private(...)
   set private(script)   $conf(telscript,script)
   set private(telname)  $conf(telscript,telname)
   set private(raquette) $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::telscript::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture TelScript dans le tableau conf(telscript,...)
   set conf(telscript,script)  $private(script)
   set conf(telscript,telname) $private(telname)
   set conf(raquette)          $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture TelScript
#
proc ::telscript::fillConfigPage { frm } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::telscript::confToWidget

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

   #--- Definition du script de configuration
   label $frm.lab1 -text "$caption(telscript,script)"
   pack $frm.lab1 -in $frm.frame2 -anchor center -side left -padx 10 -pady 10

   #--- Entry du script de configuration
   entry $frm.chemin -width 80 -textvariable ::telscript::private(script)
   pack $frm.chemin -in $frm.frame2 -anchor center -side left -padx 10

   #--- Bouton parcourir
   button $frm.explore -text "$caption(telscript,parcourir)" -width 1 -command "::telscript::explore"
   pack $frm.explore -in $frm.frame2 -side left -padx 10 -pady 5 -ipady 5

   #--- Definition du nom de la monture
   label $frm.lab2 -text "$caption(telscript,telname)"
   pack $frm.lab2 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

   #--- Entry du nom de la monture
   entry $frm.nom -textvariable ::telscript::private(telname) -width 25 -justify center
   pack $frm.nom -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

   #--- Bouton pour ouvrir l'interface graphique de debug du T940
   button $frm.debug -text "$caption(telscript,debug)" -relief raised -command "source \"$private(script)\";telscript_gui"
   pack $frm.debug -in $frm.frame3 -anchor n -side left -ipadx 10 -ipady 5 -expand true

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(telscript,raquette_tel)" \
      -highlightthickness 0 -variable ::telscript::private(raquette)
   pack $frm.raquette -in $frm.frame4 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame4 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du TelScript
   label $frm.lab103 -text "$caption(telscript,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(telscript,site_telscript)" \
      "$caption(telscript,site_telscript)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::telscript::confTelScript
}

#
# configureMonture
#    Configure la monture TelScript en fonction des donnees contenues dans les variables conf(telscript,...)
#
proc ::telscript::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create telscript Port -script $conf(telscript,script) -telname $conf(telscript,telname) ]
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(telscript,script) $caption(telscript,2points) $conf(telscript,script)\n"
      ::console::affiche_entete "$caption(telscript,telname) $caption(telscript,2points) $conf(telscript,telname)\n"
      ::console::affiche_saut "\n"
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Gestion du bouton actif/inactif
      ::telscript::confTelScript
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::telscript::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture TelScript
#
proc ::telscript::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::telscript::confTelScriptInactif
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# explore
#    Procedure pour designer les fichiers de configuration
#
proc ::telscript::explore { } {
   variable private
   global audace

   #--- Ouvre la fenetre de choix des scripts
   set fenetre "$audace(base)"
   set private(script) [ ::tkutil::box_load $fenetre [ file join $audace(rep_plugin) mount telscript ] $audace(bufNo) "3" ]
}

#
# confTelScript
# Permet d'activer ou de desactiver le bouton
#
proc ::telscript::confTelScript { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::telscript::isReady ] == 1 } {
            if { ( [ file tail $private(script) ] == "telscript_etel.tcl" ) && ( $private(telname) == "t940" ) } {
               #--- Bouton pour ouvrir l'interface graphique de debug du T940
               $frm.debug configure -state normal
            }
         } else {
            #--- Bouton pour ouvrir l'interface graphique de debug du T940
            $frm.debug configure -state disabled
         }
      }
   }
}

#
# confTelScriptInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::telscript::confTelScriptInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Bouton pour ouvrir l'interface graphique de debug du T940
         $frm.debug configure -state disabled
         #--- Fermeture de l'interface graphique de debug du T940 si elle existe
         if [ winfo exists .etel ] {
            destroy .etel
         }
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
proc ::telscript::getPluginProperty { propertyName } {
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

