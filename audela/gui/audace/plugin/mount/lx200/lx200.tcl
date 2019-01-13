#
# Fichier : lx200.tcl
# Description : Configuration de la monture LX200
# Auteur : Robert DELMAS
# Mise à jour $Id: lx200.tcl 14405 2018-04-12 20:06:27Z robertdelmas $
#

namespace eval ::lx200 {
   package provide lx200 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] lx200.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::lx200::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace liblx200.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::lx200::getPluginType]] "lx200" "liblx200.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(lx200,install_1) v[package version lx200]. $::caption(lx200,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::lx200::getPluginTitle { } {
   global caption

   return "$caption(lx200,monture)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::lx200::getPluginHelp { } {
   return "lx200.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::lx200::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::lx200::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::lx200::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::lx200::isReady { } {
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
proc ::lx200::getSecondaryTelNo { } {
   set result [ ::ouranos::getTelNo ]
   return $result
}

#
# initPlugin
#    Initialise les variables conf(lx200,...)
#
proc ::lx200::initPlugin { } {
   variable private
   global conf

   #--- Initialisation de variables
   set private(telNo)         "0"

   #--- Initialise les variables de la monture LX200
   if { ! [ info exists conf(lx200,port) ] }              { set conf(lx200,port)              "" }
   if { ! [ info exists conf(lx200,ouranos) ] }           { set conf(lx200,ouranos)           "0" }
   if { ! [ info exists conf(lx200,modele) ] }            { set conf(lx200,modele)            "LX200" }
   if { ! [ info exists conf(lx200,format) ] }            { set conf(lx200,format)            "1" }
   if { ! [ info exists conf(lx200,majDatePosGPS) ] }     { set conf(lx200,majDatePosGPS)     "1" }
   if { ! [ info exists conf(lx200,ite-lente_tempo) ] }   { set conf(lx200,ite-lente_tempo)   "10" }
   if { ! [ info exists conf(lx200,alphaGuidingSpeed) ] } { set conf(lx200,alphaGuidingSpeed) "3.0" }
   if { ! [ info exists conf(lx200,deltaGuidingSpeed) ] } { set conf(lx200,deltaGuidingSpeed) "3.0" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::lx200::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture LX200 dans le tableau private(...)
   set private(port)              $conf(lx200,port)
   set private(ouranos)           $conf(lx200,ouranos)
   set private(modele)            $conf(lx200,modele)
   set private(format)            [ lindex "$caption(lx200,format_court_long)" $conf(lx200,format) ]
   set private(majDatePosGPS)     $conf(lx200,majDatePosGPS)
   set private(ite-lente_tempo)   $conf(lx200,ite-lente_tempo)
   set private(raquette)          $conf(raquette)
   set private(alphaGuidingSpeed) $conf(lx200,alphaGuidingSpeed)
   set private(deltaGuidingSpeed) $conf(lx200,deltaGuidingSpeed)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::lx200::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture LX200 dans le tableau conf(lx200,...)
   set conf(lx200,port)              $private(port)
   set conf(lx200,ouranos)           $private(ouranos)
   set conf(lx200,modele)            $private(modele)
   set conf(lx200,format)            [ lsearch "$caption(lx200,format_court_long)" "$private(format)" ]
   set conf(lx200,majDatePosGPS)     $private(majDatePosGPS)
   set conf(lx200,ite-lente_tempo)   $private(ite-lente_tempo)
   set conf(raquette)                $private(raquette)
   set conf(lx200,alphaGuidingSpeed) $private(alphaGuidingSpeed)
   set conf(lx200,deltaGuidingSpeed) $private(deltaGuidingSpeed)
}

#
# fillConfigPage
#    Interface de configuration de la monture LX200
#
proc ::lx200::fillConfigPage { frm } {
   variable private
   global audace caption conf

   #--- Initialise les variables locales
   set private(frm)          $frm
   set private(ite-lente_A0) "0"
   set private(ite-lente_A1) "0"

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(lx200,port) == "" } {
      set conf(lx200,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(lx200,port) ] == -1 } {
      lappend list_connexion $conf(lx200,port)
   }

   #--- confToWidget
   ::lx200::confToWidget

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
   label $frm.lab1 -text "$caption(lx200,port_liaison)"
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

   #--- Bouton de configuration des ports et liaisons
   button $frm.configure -text "$caption(lx200,configurer)" -relief raised \
      -command {
         ::confLink::run ::lx200::private(port) { serialport } \
            "- $caption(lx200,controle) - $caption(lx200,monture)"
      }
   pack $frm.configure -in $frm.frame8 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame8 -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton du fonctionnement coordonne LX200 (modele AudeCom) + Ouranos
   if { [glob -nocomplain -type f -join "$audace(rep_plugin)" mount ouranos pkgIndex.tcl ] == "" } {
      set private(ouranos) "0"
      checkbutton $frm.ouranos -text "$caption(lx200,ouranos)" -highlightthickness 0 \
         -variable ::lx200::private(ouranos) -state disabled
      pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
   } else {
      checkbutton $frm.ouranos -text "$caption(lx200,ouranos)" -highlightthickness 0 \
         -variable ::lx200::private(ouranos) -state normal
      pack $frm.ouranos -in $frm.frame9 -anchor center -side left -padx 10 -pady 8
   }

   #--- Definition du LX200 ou du clone
   label $frm.lab3 -text "$caption(lx200,modele)"
   pack $frm.lab3 -in $frm.frame10 -anchor center -side left -padx 10 -pady 10

   set list_combobox [ list $caption(lx200,modele_lx200) \
      $caption(lx200,modele_astro_physics) $caption(lx200,modele_audecom) \
      $caption(lx200,modele_skysensor) $caption(lx200,modele_gemini) \
      $caption(lx200,modele_ite-lente) $caption(lx200,modele_mel_bartels) \
      $caption(lx200,modele_fs2) ]
   ComboBox $frm.modele \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(modele) \
      -modifycmd { ::lx200::confModele } \
      -editable 0       \
      -values $list_combobox
   pack $frm.modele -in $frm.frame10 -anchor center -side right -padx 10 -pady 10

   #--- Definition du format des donnees transmises au LX200
   label $frm.lab2 -text "$caption(lx200,format)"
   pack $frm.lab2 -in $frm.frame11 -anchor center -side left -padx 10 -pady 10

   set list_combobox "$caption(lx200,format_court_long)"
   ComboBox $frm.formatradec \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::lx200::private(format) \
      -editable 0       \
      -values $list_combobox
   pack $frm.formatradec -in $frm.frame11 -anchor center -side right -padx 10 -pady 10

   #--- Le checkbutton pour la mise a jour de l'heure et de la position GPS du LX200
   checkbutton $frm.majDatePosGPS -text "$caption(lx200,maj_lx200)" \
      -highlightthickness 0 -variable ::lx200::private(majDatePosGPS) \
      -command "::lx200::majDatePosGPS"
   pack $frm.majDatePosGPS -in $frm.frame2 -anchor w -side top -padx 10 -pady 10

   #--- Frame des vitesses de guidage
   frame $frm.frame2.frameSpeed -borderwidth 0

      #--- Vitesse de rappel alpha
      label $frm.frame2.frameSpeed.labelAlpha -text "$caption(lx200,rappelAD)"
      entry $frm.frame2.frameSpeed.entryAlpha -textvariable ::lx200::private(alphaGuidingSpeed) -width 5 -justify right
      grid $frm.frame2.frameSpeed.labelAlpha  -row 0 -column 0 -sticky nw -ipadx 3
      grid $frm.frame2.frameSpeed.entryAlpha  -row 0 -column 1 -sticky nw -ipadx 3

      #--- Vitesse de rappel delta
      label $frm.frame2.frameSpeed.labelDelta -text "$caption(lx200,rappelDec)"
      entry $frm.frame2.frameSpeed.entryDelta -textvariable ::lx200::private(deltaGuidingSpeed) -width 5 -justify right
      grid $frm.frame2.frameSpeed.labelDelta  -row 1 -column 0 -sticky nw -ipadx 3
      grid $frm.frame2.frameSpeed.entryDelta  -row 1 -column 1 -sticky nw -ipadx 3

      #--- Information
      label $frm.frame2.frameSpeed.labelInformation -text "$caption(lx200,vitesseSiderale)"
      grid $frm.frame2.frameSpeed.labelInformation  -row 0 -column 2 -rowspan 2 -sticky ns -ipadx 3

      grid rowconfigure $frm.frame2.frameSpeed 0 -weight 0
      grid rowconfigure $frm.frame2.frameSpeed 1 -weight 0

      grid columnconfigure $frm.frame2.frameSpeed 0 -weight 0
      grid columnconfigure $frm.frame2.frameSpeed 1 -weight 0
      grid columnconfigure $frm.frame2.frameSpeed 2 -weight 1

   pack $frm.frame2.frameSpeed -in $frm.frame2 -anchor n -side left -padx 10 -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Entree de la tempo Ite-lente
   label $frm.lab4 -text "$caption(lx200,ite-lente_tempo)"
   pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   entry $frm.tempo -textvariable ::lx200::private(ite-lente_tempo) -justify center -width 5
   pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Bouton GO/Stop A0
   checkbutton $frm.ite-lente_A0 -text "$caption(lx200,ite-lente_A0,go)" -relief raised -indicatoron 0 \
      -variable ::lx200::private(ite-lente_A0) -state disabled \
      -command "::lx200::testIteLente ite-lente_A0"
   pack $frm.ite-lente_A0 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10

   #--- Bouton GO/Stop A1
   checkbutton $frm.ite-lente_A1 -text "$caption(lx200,ite-lente_A1,go)" -relief raised -indicatoron 0 \
      -variable ::lx200::private(ite-lente_A1) -state disabled \
      -command "::lx200::testIteLente ite-lente_A1"
   pack $frm.ite-lente_A1 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10

   #--- Bouton ACK
   button $frm.ite-lente_ack -text "$caption(lx200,ite-lente_ack)" -relief raised \
      -state disabled -command "::lx200::testIteLente ite-lente_ack"
   pack $frm.ite-lente_ack -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(lx200,raquette_tel)" \
      -highlightthickness 0 -variable ::lx200::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Bouton park
   button $frm.park -text "$caption(lx200,park)" -relief raised -command "::telescope::park 1" \
      -state disabled
   pack $frm.park -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Bouton unpark
   button $frm.unpark -text "$caption(lx200,unpark)" -relief raised -command "::telescope::park 0" \
      -state disabled
   pack $frm.unpark -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

   #--- Site web officiel du LX200
   label $frm.lab103 -text "$caption(lx200,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(lx200,site_web_ref)" \
      "$caption(lx200,site_web_ref)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion des boutons actifs/inactifs
   ::lx200::confLX200

   #--- Gestion de la tempo pour Ite-lente
   ::lx200::confModele
}

#
# configureMonture
#    Configure la monture LX200 en fonction des donnees contenues dans les variables conf(lx200,...)
#
proc ::lx200::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      switch [::confLink::getLinkNamespace $conf(lx200,port)] {
         serialport {
            #--- Je cree la monture
            set telNo [ tel::create lx200 $conf(lx200,port) -name $conf(lx200,modele) ]
            #--- J'affiche un message d'information dans la Console
            ::console::affiche_entete "$caption(lx200,port_lx200) ($conf(lx200,modele))\
               $caption(lx200,2points) $conf(lx200,port)\n"
            ::console::affiche_saut "\n"
            #--- Cas particulier du modele Ite-lente
            if { $conf(lx200,modele) == "Ite-lente" } {
               tel$telNo tempo $conf(lx200,ite-lente_tempo)
            }
         }
      }
      #--- Je configure la position geographique de la monture et le nom de l'observatoire
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      if { $conf(lx200,majDatePosGPS) == "1" } {
         tel$telNo date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
         tel$telNo home $::audace(posobs,observateur,gps)
         tel$telNo home name $::conf(posobs,nom_observatoire)
      }
      #--- Je choisis le format des coordonnees AD et Dec.
      if { $conf(lx200,format) == "0" } {
         tel$telNo longformat off
      } else {
         tel$telNo longformat on
      }
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(lx200,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Traces dans la Console
      #-- inactivée car cette fonction n'existe pas
      #::lx200::tracesConsole
      #--- Gestion des boutons actifs/inactifs
      ::lx200::confLX200

      #--- Si connexion des codeurs Ouranos demandee en tant que monture secondaire
      if { $conf(lx200,ouranos) == "1" } {
         #--- Je copie les parametres Ouranos dans conf()
         ::ouranos::widgetToConf
         #--- Je configure la monture secondaire Ouranos
         ::ouranos::configureMonture
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::lx200::stop
      if { $conf(lx200,ouranos) == "1" } {
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
proc ::lx200::stop { } {
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
   ::lx200::confLX200

   #--- Deconnexion des codeurs Ouranos si la monture secondaire existe
   if { $conf(lx200,ouranos) == "1" } {
      ::ouranos::stop
   }
}

#
# confLX200
# Permet d'activer ou de desactiver les boutons
#
proc ::lx200::confLX200 { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::lx200::isReady ] == 1 } {
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
            if { $private(modele) == "$caption(lx200,modele_ite-lente)" } {
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
proc ::lx200::confModele { } {
   variable private
   global audace caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Cas du modele IteLente
         if { $private(modele) == "$caption(lx200,modele_ite-lente)" } {
            if { ! [ winfo exists $frm.lab4 ] } {
               #--- Label de la tempo Ite-lente
               label $frm.lab4 -text "$caption(lx200,ite-lente_tempo)"
               pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
            }
            if { ! [ winfo exists $frm.tempo ] } {
               #--- Entree de la tempo Ite-lente
               entry $frm.tempo -textvariable ::lx200::private(ite-lente_tempo) -justify center -width 5
               pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
               #--- Bouton GO/Stop A0
               checkbutton $frm.ite-lente_A0 -text "$caption(lx200,ite-lente_A0,go)" -relief raised -indicatoron 0 \
                  -variable ::lx200::private(ite-lente_A0) -state disabled \
                  -command "::lx200::testIteLente ite-lente_A0"
               pack $frm.ite-lente_A0 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
               #--- Bouton GO/Stop A1
               checkbutton $frm.ite-lente_A1 -text "$caption(lx200,ite-lente_A1,go)" -relief raised -indicatoron 0 \
                  -variable ::lx200::private(ite-lente_A1) -state disabled \
                  -command "::lx200::testIteLente ite-lente_A1"
               pack $frm.ite-lente_A1 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
               #--- Bouton ACK
               button $frm.ite-lente_ack -text "$caption(lx200,ite-lente_ack)" -relief raised \
                  -state disabled -command "::lx200::testIteLente ite-lente_ack"
               pack $frm.ite-lente_ack -in $frm.frame4a -anchor center -side left -padx 10 -pady 10 -ipadx 10
            }
         } else {
            destroy $frm.lab4 ; destroy $frm.tempo
            destroy $frm.ite-lente_A0 ; destroy $frm.ite-lente_A1 ; destroy $frm.ite-lente_ack
         }
         #--- Cas du modele AudeCom
         if { $private(modele) == "$caption(lx200,modele_audecom)" } {
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
         if {  $private(modele) == $::caption(lx200,modele_lx200)
            || $private(modele) == $::caption(lx200,modele_lx200_gps)
            || $private(modele) == $::caption(lx200,modele_skysensor)
            || $private(modele) == $::caption(lx200,modele_gemini)
            || $private(modele) == $::caption(lx200,modele_astro_physics)} {
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
proc ::lx200::testIteLente { buttonName } {
   variable private
   global caption

   switch $buttonName {
      ite-lente_A0 {
         if { $private($buttonName) == "1" } {
            tel$private(telNo) command "#:Xa+#" none
            $private(frm).$buttonName configure -text $caption(lx200,$buttonName,stop)
         } else {
            tel$private(telNo) command "#:Xa-#" none
            $private(frm).$buttonName configure -text $caption(lx200,$buttonName,go)
         }
      }
      ite-lente_A1 {
         if { $private($buttonName) == "1" } {
            tel$private(telNo) command "#:Xb+#" none
            $private(frm).$buttonName configure -text $caption(lx200,$buttonName,stop)
         } else {
            tel$private(telNo) command "#:Xb-#" none
            $private(frm).$buttonName configure -text $caption(lx200,$buttonName,go)
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
proc ::lx200::majDatePosGPS { } {
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
proc ::lx200::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              {
         if { $::conf(lx200,modele) == "$::caption(lx200,modele_audecom)" } {
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
         if { $::conf(lx200,modele) == "$::caption(lx200,modele_ite-lente)" } {
            return 1
         } else {
            return 0
         }
      }
      hasPark                 {
         if {  $::conf(lx200,modele) == $::caption(lx200,modele_lx200)
            || $::conf(lx200,modele) == $::caption(lx200,modele_lx200_gps)
            || $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUnpark               {
         if { $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      hasUpdateDate           {
         if {  $::conf(lx200,modele) == $::caption(lx200,modele_lx200)
            || $::conf(lx200,modele) == $::caption(lx200,modele_lx200_gps)
            || $::conf(lx200,modele) == $::caption(lx200,modele_skysensor)
            || $::conf(lx200,modele) == $::caption(lx200,modele_gemini)
            || $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
            return 1
         } else {
            return 0
         }
      }
      backlash                { return 0 }
      guidingSpeed            { return [list $::conf(lx200,alphaGuidingSpeed) $::conf(lx200,deltaGuidingSpeed) ] }
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
proc ::lx200::park { state } {
   variable private

   if {  $::conf(lx200,modele) == $::caption(lx200,modele_lx200)
      || $::conf(lx200,modele) == $::caption(lx200,modele_lx200_gps)} {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":hP#" none
      } elseif { $state == 0 } {
         #--- je ne fais rien car Meade n'a pas la fonction un-park
      }
   } elseif { $::conf(lx200,modele) == $::caption(lx200,modele_astro_physics)} {
      if { $state == 1 } {
         #--- je parque la monture
         tel$private(telNo) command ":KA#" none
      } elseif { $state == 0 } {
         #--- j'envoie l'heure courante
         tel$::lx200::private(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
         #--- je de-parque la monture
         tel$private(telNo) command ":PO#" none
      }
   }
}

proc ::lx200::move { direction rate } {
   global conf caption
   variable private

   if {$conf(lx200,modele) != $caption(lx200,modele_astro_physics)} {
      # Cas normal, le driver va faire le necessaire */
      tel$private(telNo) radec move $direction $rate
   } else {
      # Cas Astrophysics (a base de GTOCP3)
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

