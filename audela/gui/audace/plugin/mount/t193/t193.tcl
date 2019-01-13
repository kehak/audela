#
# Fichier : t193.tcl
# Description : Configuration de la monture du T193 de l'OHP
# Auteur : Michel PUJOL et Robert DELMAS
# Mise à jour $Id: t193.tcl 13616 2016-04-05 15:34:15Z robertdelmas $
#

namespace eval ::t193 {
   package provide t193 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] t193.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::t193::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libt193.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::t193::getPluginType]] "t193" "libt193.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(t193,install_1) v[package version t193]. $::caption(t193,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::t193::getPluginTitle { } {
   global caption

   return "$caption(t193,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::t193::getPluginHelp { } {
   return "t193.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::t193::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::t193::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::t193::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::t193::isReady { } {
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
#    Initialise les variables conf(t193,...)
#
proc ::t193::initPlugin { } {
   variable private
   global conf

   #--- configuration de la monture du T193 de l'OHP
   if { ! [ info exists conf(t193,portSerie) ] }                 { set conf(t193,portSerie)                 "" }
   if { ! [ info exists conf(t193,mode) ] }                      { set conf(t193,mode)                      "HP1000" }
   if { ! [ info exists conf(t193,nomCarte) ] }                  { set conf(t193,nomCarte)                  "Dev1" }
   if { ! [ info exists conf(t193,minDelay) ] }                  { set conf(t193,minDelay)                  "10" }
   if { ! [ info exists conf(t193,nomPortTelescope) ] }          { set conf(t193,nomPortTelescope)          "port0" }
   if { ! [ info exists conf(t193,nomPortAttenuateur) ] }        { set conf(t193,nomPortAttenuateur)        "port1" }
   #--- vitesses de guidage en arcseconde de degre par seconde de temps
   if { ! [ info exists conf(t193,alphaGuidingSpeed) ] }         { set conf(t193,alphaGuidingSpeed)         "3.0" }
   if { ! [ info exists conf(t193,deltaGuidingSpeed) ] }         { set conf(t193,deltaGuidingSpeed)         "3.0" }
   #--- configuration du mode Ethernet
   if { ! [ info exists conf(t193,hostEthernet) ] }              { set conf(t193,hostEthernet)              "192.168.128.157" }
   if { ! [ info exists conf(t193,telescopeCommandPort) ] }      { set conf(t193,telescopeCommandPort)      "5025" }
   if { ! [ info exists conf(t193,telescopeNotificationPort) ] } { set conf(t193,telescopeNotificationPort) "5026" }
   #--- duree de deplacement entre les 2 butees (mini et maxi) de l'attenuateur
   if { ! [ info exists conf(t193,dureeMaxAttenuateur) ] }       { set conf(t193,dureeMaxAttenuateur)       "16" }
   #--- modele de pointage
   if { ! [ info exists conf(t193,model,enabled) ] }             { set conf(t193,model,enabled)             "0" }
   if { ! [ info exists conf(t193,model,id) ] }                  { set conf(t193,model,id)                  "0" }

   #--- modification des valeurs par rapport ? la version precedente du 20/09/2009
   if { $::conf(t193,mode) == 0 } {
      set ::conf(t193,mode) "HP1000"
   }

   #--- Initialisation
   set private(telNo)       "0"
   set private(frm)         ""
   set private(radecHandle) ""      ; # identifiant du canal de lecture
   set private(radecLoop)   0       ; # boucle de lecture de radec desactivee par defaut
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::t193::confToWidget { } {
   variable widget
   global conf

   #--- Recupere la configuration de la monture du T193 de l'OHP dans le tableau private(...)
   set widget(portSerie)                 $conf(t193,portSerie)
   set widget(mode)                      $conf(t193,mode)
   set widget(nomCarte)                  $conf(t193,nomCarte)
   set widget(minDelay)                  $conf(t193,minDelay)
   set widget(nomPortTelescope)          $conf(t193,nomPortTelescope)
   set widget(nomPortAttenuateur)        $conf(t193,nomPortAttenuateur)
   set widget(alphaGuidingSpeed)         $conf(t193,alphaGuidingSpeed)
   set widget(deltaGuidingSpeed)         $conf(t193,deltaGuidingSpeed)
   set widget(hostEthernet)              $conf(t193,hostEthernet)
   set widget(telescopeCommandPort)      $conf(t193,telescopeCommandPort)
   set widget(telescopeNotificationPort) $conf(t193,telescopeNotificationPort)
   set widget(dureeMaxAttenuateur)       $conf(t193,dureeMaxAttenuateur)
   set widget(model,enabled)             $conf(t193,model,enabled)
   set widget(model,id)                  $conf(t193,model,id)
   set widget(model,date)                ""

   set widget(raquette)                  $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::t193::widgetToConf { } {
   variable widget
   global conf

   #--- Memorise la configuration de la monture du T193 de l'OHP dans le tableau conf(t193,...)
   set conf(t193,portSerie)                 $widget(portSerie)
   set conf(t193,mode)                      $widget(mode)
   set conf(t193,nomCarte)                  $widget(nomCarte)
   set conf(t193,minDelay)                  $widget(minDelay)
   set conf(t193,nomPortTelescope)          $widget(nomPortTelescope)
   set conf(t193,nomPortAttenuateur)        $widget(nomPortAttenuateur)
   set conf(t193,alphaGuidingSpeed)         $widget(alphaGuidingSpeed)
   set conf(t193,deltaGuidingSpeed)         $widget(deltaGuidingSpeed)
   set conf(t193,hostEthernet)              $widget(hostEthernet)
   set conf(t193,telescopeCommandPort)      $widget(telescopeCommandPort)
   set conf(t193,telescopeNotificationPort) $widget(telescopeNotificationPort)
   set conf(t193,dureeMaxAttenuateur)       $widget(dureeMaxAttenuateur)
   set conf(t193,model,enabled)             $widget(model,enabled)
   set conf(t193,model,id)                  $widget(model,id)

   set conf(raquette)                       $widget(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture du T193 de l'OHP
#
proc ::t193::fillConfigPage { frm } {
   variable widget
   variable private
   global audace caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(t193,portSerie) == "" } {
      set conf(t193,portSerie) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(t193,portSerie) ] == -1 } {
      lappend list_connexion $conf(t193,portSerie)
   }

   #--- confToWidget
   ::t193::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   TitleFrame $frm.mode -borderwidth 2 -relief ridge -text $caption(t193,mode)
   pack $frm.mode -side top -fill x

   TitleFrame $frm.carteUSB -borderwidth 2 -relief ridge -text $caption(t193,carteUSB)
   pack $frm.carteUSB -side top -fill x

   TitleFrame $frm.ethernet -borderwidth 2 -relief ridge -text $caption(t193,ethernet)
      #--- Definition du host Ethernet
      label $frm.labhost -text $caption(t193,host)
      pack $frm.labhost -in [ $frm.ethernet getframe ] -anchor n -side left -padx 2 -pady 2
      #--- Entry du host Ethernet
      entry $frm.host -textvariable ::t193::widget(hostEthernet) -width 15 -justify center
      pack $frm.host -in [ $frm.ethernet getframe ] -anchor n -side left -padx 2 -pady 2

      #--- Definition du port Ethernet de commande
      label $frm.labportCommand -text $caption(t193,portCommand)
      pack $frm.labportCommand -in [ $frm.ethernet getframe ] -anchor n -side left -padx 2 -pady 2
      #--- Entry du port Ethernet de commande
      entry $frm.portCommand -textvariable ::t193::widget(telescopeCommandPort) -width 7 -justify center
      pack $frm.portCommand -in [ $frm.ethernet getframe ] -anchor n -side left -padx 2 -pady 2

      #--- Definition du port Ethernet de notification
      label $frm.labportNotification -text $caption(t193,portNotification)
      pack $frm.labportNotification -in [ $frm.ethernet getframe ] -anchor n -side left -padx 2 -pady 2
      #--- Entry du port Ethernet de notification
      entry $frm.portNotification -textvariable ::t193::widget(telescopeNotificationPort) -width 7 -justify center
      pack $frm.portNotification -in [ $frm.ethernet getframe ] -anchor n -side left -padx 2 -pady 2

   pack $frm.ethernet -side top -fill x

   TitleFrame $frm.attenuateur -borderwidth 2 -relief ridge -text $::caption(t193,attenuateur)
      #--- Definition du nom de la carte USB-6501 et de son port
      label $frm.attenuateur.label -text $caption(t193,nom_carte)
      pack $frm.attenuateur.label -in [$frm.attenuateur getframe] -anchor n -side left -padx 2 -pady 2
      #--- Entry du nom de la carte USB-6501
      entry $frm.attenuateur.nomCarte -textvariable ::t193::widget(nomCarte) -width 15 -justify left
      pack $frm.attenuateur.nomCarte -in [$frm.attenuateur getframe] -anchor n -side left -padx 2 -pady 2
   pack $frm.attenuateur -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -in [ $frm.carteUSB getframe ] -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -in [ $frm.carteUSB getframe ] -side top -fill x

   #--- Definition du port serie
   label $frm.lab4 -text "$caption(t193,port)"
   pack $frm.lab4 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $widget(portSerie) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(portSerie) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports
   button $frm.configure -text "$caption(t193,configurer)" -relief raised \
      -command {
         ::confLink::run ::t193::widget(portSerie) { serialport } \
            "- $caption(t193,controle) - $caption(t193,monture)"
      }
   pack $frm.configure -in $frm.frame3 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port
   ComboBox $frm.portSerie \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::t193::widget(portSerie) \
      -editable 0       \
      -values $list_connexion
   pack $frm.portSerie -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

   #--- Mode carte USB National Instruments
   radiobutton $frm.mode.radio0 -anchor nw -highlightthickness 0 \
      -text "$caption(t193,carteUSB)" -value "HP1000" -variable ::t193::widget(mode) \
      -command { ::t193::configureConfigPage }
   pack $frm.mode.radio0 -in [ $frm.mode getframe ] -anchor n -side left -padx 10 -pady 0

   #--- Mode Ethernet (interface de controle OHP)
   radiobutton $frm.mode.radio1 -anchor nw -highlightthickness 0 \
      -text "$caption(t193,ethernet)" -value "ETHERNET" -variable ::t193::widget(mode) \
      -command { ::t193::configureConfigPage }
   pack $frm.mode.radio1 -in [ $frm.mode getframe ] -anchor n -side left -padx 10 -pady 0

   #--- Definition du nom de la carte USB-6501 et de son port
   label $frm.lab2 -text "$caption(t193,nom_carte)"
   pack $frm.lab2 -in $frm.frame4 -anchor n -side left -padx 10 -pady 5

   #--- Entry du nom de la carte USB-6501 et de son port
   entry $frm.nomCarte -textvariable ::t193::widget(nomCarte) -width 15 -justify left
   pack $frm.nomCarte -in $frm.frame4 -anchor n -side left -padx 10 -pady 5

   #--- Entry de la longueur de l'impulsion minimale
   entry $frm.minDelay -textvariable ::t193::widget(minDelay) -width 5 -justify left
   pack $frm.minDelay -in $frm.frame4 -anchor n -side right -padx 10 -pady 5

   #--- Definition de la longueur de l'impulsion minimale
   label $frm.lab3 -text "$caption(t193,minDelay)"
   pack $frm.lab3 -in $frm.frame4 -anchor n -side right -padx 0 -pady 5

   #--- Frame des vitesses
   frame $frm.frame3.speed -borderwidth 0

      #--- Vitesse de rappel alpha
      label $frm.frame3.speed.labelAlpha -text "$caption(t193,rappelAlpha)"
      entry $frm.frame3.speed.entryAlpha -textvariable ::t193::widget(alphaGuidingSpeed) \
         -width 5 -justify left
      grid $frm.frame3.speed.labelAlpha  -row 0 -column 0 -ipadx 3
      grid $frm.frame3.speed.entryAlpha  -row 0 -column 1 -ipadx 3

      #--- Vitesse de rappel delta
      label $frm.frame3.speed.labelDelta -text "$caption(t193,rappelDelta)"
      entry $frm.frame3.speed.entryDelta -textvariable ::t193::widget(deltaGuidingSpeed) \
         -width 5 -justify left
      grid $frm.frame3.speed.labelDelta  -row 1 -column 0 -ipadx 3
      grid $frm.frame3.speed.entryDelta  -row 1 -column 1 -ipadx 3

      grid rowconfigure $frm.frame3.speed 0 -weight 0
      grid rowconfigure $frm.frame3.speed 1 -weight 1

      grid columnconfigure $frm.frame3.speed 1 -weight 0
      grid columnconfigure $frm.frame3.speed 2 -weight 1

   pack $frm.frame3.speed -in $frm.frame3 -anchor n -side right -pady 5 -ipadx 5 -ipady 1 -expand 0

   #--- boutons de tests (test mouvement, test radec, test attenuateurs),
   frame $frm.frame5 -borderwidth 0 -relief raised
      #--- J'affiche les boutons N, S, E et O
      TitleFrame $frm.test1 -borderwidth 2 -relief ridge -text "$caption(t193,raquette)"

         #--- J'affiche le bouton E
         button $frm.test1.est -text "$caption(t193,est)" -relief ridge -width 2
         grid $frm.test1.est -in [ $frm.test1 getframe ] -row 1 -column 1 -ipadx 5

         #--- J'affiche le bouton N
         button $frm.test1.nord -text "$caption(t193,nord)" -relief ridge -width 2
         grid $frm.test1.nord -in [ $frm.test1 getframe ] -row 0 -column 2 -ipadx 5

         #--- J'affiche le bouton S
         button $frm.test1.sud -text "$caption(t193,sud)" -relief ridge -width 2
         grid $frm.test1.sud -in [ $frm.test1 getframe ] -row 2 -column 2 -ipadx 5

         #--- J'affiche le bouton O
         button $frm.test1.ouest -text "$caption(t193,ouest)" -relief ridge -width 2
         grid $frm.test1.ouest -in [ $frm.test1 getframe ] -row 1 -column 3 -ipadx 5

         grid rowconfigure [ $frm.test1 getframe ] 0 -minsize 25 -weight 0
         grid rowconfigure [ $frm.test1 getframe ] 1 -minsize 25 -weight 0
         grid rowconfigure [ $frm.test1 getframe ] 2 -minsize 25 -weight 0

         grid columnconfigure [ $frm.test1 getframe ] 1 -minsize 40 -weight 0
         grid columnconfigure [ $frm.test1 getframe ] 2 -minsize 40 -weight 0
         grid columnconfigure [ $frm.test1 getframe ] 3 -minsize 40 -weight 0

         #--- Actions des boutons E, N, S et O
         bind $frm.test1.est <ButtonPress-1>     "::t193::moveTelescop e press"
         bind $frm.test1.est <ButtonRelease-1>   "::t193::moveTelescop e release"
         bind $frm.test1.nord <ButtonPress-1>    "::t193::moveTelescop n press"
         bind $frm.test1.nord <ButtonRelease-1>  "::t193::moveTelescop n release"
         bind $frm.test1.sud <ButtonPress-1>     "::t193::moveTelescop s press"
         bind $frm.test1.sud <ButtonRelease-1>   "::t193::moveTelescop s release"
         bind $frm.test1.ouest <ButtonPress-1>   "::t193::moveTelescop w press"
         bind $frm.test1.ouest <ButtonRelease-1> "::t193::moveTelescop w release"

      pack $frm.test1 -in $frm.frame5 -side left -anchor w -fill y -pady 5 -expand 1

      #--- J'affiche le bouton pour la lecture des coordonnees AD et Dec.
      TitleFrame $frm.test2 -borderwidth 2 -relief ridge -text "$caption(t193,coordonnees)"

         #--- J'affiche le label pour l'AD
         label $frm.test2.labAD -text $caption(t193,AD)
         grid $frm.test2.labAD -in [ $frm.test2 getframe ] -row 0 -column 1

         #--- J'affiche l'entry de l'AD
         entry $frm.test2.entryAD -textvariable audace(telescope,getra) -width 15 \
            -justify center -state disabled
         grid $frm.test2.entryAD -in [ $frm.test2 getframe ] -row 1 -column 1

         #--- J'affiche le label pour la Dec.
         label $frm.test2.labDec -text $caption(t193,Dec)
         grid $frm.test2.labDec -in [ $frm.test2 getframe ] -row 0 -column 2

         #--- J'affiche l'entry de la Dec.
         entry $frm.test2.entryDec -textvariable audace(telescope,getdec) -width 15 \
            -justify center -state disabled
         grid $frm.test2.entryDec -in [ $frm.test2 getframe ] -row 1 -column 2

         grid rowconfigure [ $frm.test2 getframe ] 0 -minsize 30 -weight 0
         grid rowconfigure [ $frm.test2 getframe ] 2 -minsize 30 -weight 0

      pack $frm.test2 -in $frm.frame5 -side left -anchor w -fill y -pady 5 -expand 1

      #--- J'affiche les boutons - et + de l'attenuateur
      TitleFrame $frm.test3 -borderwidth 2 -relief ridge -text "$caption(t193,attenuateur)"

         #--- J'affiche le label pour la duree du deplacement
         label $frm.test3.attenuateur -text $caption(t193,duree)
         grid $frm.test3.attenuateur -in [ $frm.test3 getframe ] -row 0 -column 1

         #--- J'affiche l'entry de la duree du deplacement
         entry $frm.test3.entryDuree -textvariable ::t193::widget(dureeMaxAttenuateur) -width 5 \
            -justify left
         grid $frm.test3.entryDuree -in [ $frm.test3 getframe ] -row 0 -column 2

         #--- J'affiche le bouton -
         button $frm.test3.attenuateur- -text "$caption(t193,attenuateur-)" -relief ridge -width 2
         grid $frm.test3.attenuateur- -in [ $frm.test3 getframe ] -row 1 -column 1 -ipadx 5

         #--- J'affiche le bouton +
         button $frm.test3.attenuateur+ -text "$caption(t193,attenuateur+)" -relief ridge -width 2
         grid $frm.test3.attenuateur+ -in [ $frm.test3 getframe ] -row 1 -column 2 -ipadx 5

         #--- J'affiche l'entry de la position de l'attenuateur
         entry $frm.test3.entryPosition -textvariable ::t193::private(position) \
            -justify center -state disabled
         grid $frm.test3.entryPosition -in [ $frm.test3 getframe ] -row 2 -column 1 -columnspan 2 \
            -sticky ew

         grid rowconfigure [ $frm.test3 getframe ] 0 -minsize 25 -weight 0
         grid rowconfigure [ $frm.test3 getframe ] 1 -minsize 25 -weight 0
         grid rowconfigure [ $frm.test3 getframe ] 2 -minsize 25 -weight 0

         grid columnconfigure [ $frm.test3 getframe ] 1 -minsize 40 -weight 0
         grid columnconfigure [ $frm.test3 getframe ] 2 -minsize 40 -weight 0

         #--- Actions des boutons - et + de l'attenuateur
         bind $frm.test3.attenuateur- <ButtonPress-1>   "::t193::moveFilter -"
         bind $frm.test3.attenuateur- <ButtonRelease-1> "::t193::stopFilter"
         bind $frm.test3.attenuateur+ <ButtonPress-1>   "::t193::moveFilter +"
         bind $frm.test3.attenuateur+ <ButtonRelease-1> "::t193::stopFilter"

      pack $frm.test3 -in $frm.frame5 -side left -anchor w -fill y -pady 5 -expand 1
   pack $frm.frame5 -side top -fill x

   #--- choix raquette et traces
   frame $frm.pad -borderwidth 0 -relief raised
      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(t193,raquette_tel)" \
         -highlightthickness 0 -variable ::t193::widget(raquette)
      pack $frm.raquette -in $frm.pad -anchor center -side left -padx 10 -pady 10

      #--- Frame raquette
      ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
      pack $frm.nom_raquette -in $frm.pad -anchor center -side left -padx 0 -pady 10
   pack $frm.pad -side top -fill x -pady 2

   #--- Site web officiel du T193 de l'OHP
   frame $frm.website -borderwidth 0 -relief raised
      label $frm.webSiteLabel -text "$caption(t193,titre_site_web)"
      pack  $frm.webSiteLabel -in $frm.website -side top -fill x -pady 2

      set webSiteUrl [ ::confTel::createUrlLabel $frm.website "$caption(t193,site_t193)" \
         "$caption(t193,site_t193)" ]
      pack $webSiteUrl -side top -fill x -pady 2
   pack $frm.website -side top -fill x -pady 2

   #--- Configuration des boutons de test
   ::t193::configureConfigPage

}

#
# configureMonture
#    Configure la monture du T193 de l'OHP en fonction des donnees contenues dans les variables conf(t193,...)
#
proc ::t193::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      switch $::conf(t193,mode) {
         "HP1000" {
            #--- Je cree la monture
            set telNo [ tel::create t193 HP1000 \
               -usbCardName $::conf(t193,nomCarte) \
               -usbTelescopPort $::conf(t193,nomPortTelescope) \
               -usbFilterPort   $::conf(t193,nomPortAttenuateur) \
               -northRelay 0 \
               -southRelay 1 \
               -estRelay   2 \
               -westRelay  3 \
               -enabledRelay 4 \
               -decreaseFilterRelay 0 \
               -increaseFilterRelay 1 \
               -minDetectorFilterInput 2 \
               -maxDetectorFilterInput 3 \
               -filterMaxDelay $::conf(t193,dureeMaxAttenuateur) \
            ]
            #--- Je parametre le delai mini le HP1000
            tel$telNo radec mindelay $::conf(t193,minDelay)
            #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
            set linkNo [ ::confLink::create $conf(t193,portSerie) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
            #--- je lance la lecture de radec en boucle sur le port com
            set private(radecHandle) [open $conf(t193,portSerie) "r+" ]
            fconfigure $private(radecHandle) -mode "19200,n,8,1" -buffering none -blocking 0
            set private(readLoop) 1
            #--- j'intialise les coordonnees
            set ::audace(telescope,getra) "00h00m00.00s"
            set ::audace(telescope,getdec) "00d00m00"
            #--- je lance la lecture periodique des coordonnees
            ::t193::readRadec
            #--- J'affiche un message d'information dans la Console
            ::console::affiche_entete "$caption(t193,port_t193) $caption(t193,2points) $conf(t193,portSerie)\n"
            ::console::affiche_entete "$caption(t193,nom_carte) $caption(t193,2points) $conf(t193,nomCarte)\n"
            ::console::affiche_saut "\n"
         }
         "ETHERNET" {
            #--- Je cree la monture
            set telNo [ tel::create t193 ETHERNET \
               -usbCardName $::conf(t193,nomCarte) \
               -ethernetHost $::conf(t193,hostEthernet) \
               -telescopeCommandPort $::conf(t193,telescopeCommandPort) \
               -telescopeNotificationPort $::conf(t193,telescopeNotificationPort) \
               -usbFilterPort $::conf(t193,nomPortAttenuateur) \
               -decreaseFilterRelay 0 \
               -increaseFilterRelay 1 \
               -minDetectorFilterInput 2 \
               -maxDetectorFilterInput 3 \
               -filterMaxDelay $::conf(t193,dureeMaxAttenuateur) \
            ]
             #--- J'affiche un message d'information dans la Console
             ::console::affiche_entete "$caption(t193,port_t193) $caption(t193,2points) $conf(t193,portSerie)\n"
             ::console::affiche_entete "$caption(t193,host) $caption(t193,2points) $conf(t193,hostEthernet) $caption(t193,portCommand) $caption(t193,2points) $::conf(t193,telescopeCommandPort) $caption(t193,portNotification) $caption(t193,2points) $::conf(t193,telescopeNotificationPort)\n"
             ::console::affiche_saut "\n"
         }
         "REMOTE" {
            #--- Je cree la monture
            set telNo [ tel::create t193 REMOTE \
               -remoteHost $::conf(t193,hostRemote) \
               -remotePort $::conf(t193,portRemote) \
            ]
         }
      }
      #--- Je configure la position geographique du telescope
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      #--- format : tel$telno home GPS long e|w lat alt
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)

       #--- Je configure le modele de pointage
      if { $::conf(t193,model,enabled) == 1 } {
         set modelId $::conf(t193,model,id)
         tel$telNo radec model -enabled 1 \
            -symbols $::conf(confTel,model,$modelId,symbols) \
            -coefficients $::conf(confTel,model,$modelId,coefficients)
      } else {
         #tel$telNo radec model -enabled 0
      }

      #--- Je memorise le numero du telescope
      set private(telNo) $telNo
      #--- Configuration des boutons de test
      ::t193::configureConfigPage

   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::t193::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture du T193 de l'OHP
#
proc ::t193::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   switch $::conf(t193,mode) {
     "HP1000" {
         #--- j'arrete la boucle de lecture de radec
         set private(testhp) 0
         if { $private(radecHandle) != "" } {
            close $private(radecHandle)
            set private(radecHandle) ""
         }

         #--- Je memorise le port pour ensuite supprimer le link
         set telPort [ tel$private(telNo) port ]
         #--- J'arrete la monture
         tel::delete $private(telNo)
         #--- J'arrete le link
         ::confLink::delete $telPort "tel$private(telNo)" "control"
      }
      "ETHERNET" {
         #--- J'arrete la monture
         tel::delete $private(telNo)
      }
      "REMOTE" {
         #--- J'arrete la monture
         tel::delete $private(telNo)
      }
   }
   #--- Remise a zero du numero de monture
   set private(telNo) "0"

   #--- Configuration des boutons de test
   ::t193::configureConfigPage
}

# configureConfigPage
#   Autorise/Interdit les widgets de test
#
proc ::t193::configureConfigPage { } {
   variable private
   variable widget

   if { [ winfo exists $private(frm) ] } {
      if { $widget(mode) == "HP1000" } {
         pack forget $private(frm).ethernet
         pack forget $private(frm).attenuateur
         pack $private(frm).carteUSB -side top -fill x -after $private(frm).mode
      } elseif { $widget(mode) == "ETHERNET" } {
         pack forget $private(frm).carteUSB
         pack $private(frm).ethernet -side top -fill x -after $private(frm).mode
         pack $private(frm).attenuateur -side top -fill x -after $private(frm).ethernet
      }
      if { [ ::t193::isReady ] == 1 } {
         #--- J'active les boutons de l'interface
         $private(frm).test1.est configure -state normal
         $private(frm).test1.nord configure -state normal
         $private(frm).test1.sud configure -state normal
         $private(frm).test1.ouest configure -state normal
         $private(frm).test3.entryDuree configure -state normal
         $private(frm).test3.attenuateur- configure -state normal
         $private(frm).test3.attenuateur+ configure -state normal
      } else {
         #--- Je desactive les boutons de l'interface
         $private(frm).test1.est configure -state disabled
         $private(frm).test1.nord configure -state disabled
         $private(frm).test1.sud configure -state disabled
         $private(frm).test1.ouest configure -state disabled
         $private(frm).test3.entryDuree configure -state disabled
         $private(frm).test3.attenuateur- configure -state disabled
         $private(frm).test3.attenuateur+ configure -state disabled
      }
   }
}

#
# moveTelescop
#    Actionne les mouvements du telescope
#
proc ::t193::moveTelescop { direction state } {
   variable private

   if { $private(telNo) == "0" } {
      return
   }

   if { $state == "press" } {
      ::telescope::move $direction
   } else {
      ::telescope::stop $direction
   }
}

#
# moveFilter
#    Actionne le filtre attenuateur
#
proc ::t193::moveFilter { direction } {
   variable private

   if { [ ::tel::list ] != "" } {
      tel$private(telNo) filter move $direction
   }
}

#
# stopFilter
#    Arrete le filtre attenuateur et lit sa position
#
proc ::t193::stopFilter { } {
   variable private

   if { [ ::tel::list ] != "" } {
      tel$private(telNo) filter stop
      set private(position) [ tel$private(telNo) filter coord ]
   }
}

#------------------------------------------------------------------------------
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
#------------------------------------------------------------------------------
proc ::t193::getPluginProperty { propertyName } {
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
      hasMatch                { return 0 }
      hasManualMotion         { return 1 }
      hasControlSuivi         { return 1 }
      hasMotionWhile          {
         if {$::conf(t193,mode) == "ETHERNET"} {
            #--- les corrections sont demandees avec une distance en arseconde
            return 2
         } else {
            #--- les corrections sont demandees avec une duree en seconde
            return 1
         }
      }
      hasModel                { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
      guidingSpeed            { return [list $::conf(t193,alphaGuidingSpeed) $::conf(t193,deltaGuidingSpeed) ] }
   }
}

#------------------------------------------------------------
# readRadec
#    lit les coordonnees toutes les 2 secondes sur le port serie du HP1000
#
#    "06h 23m 36.73s / +44d 35' 29'' /   -1d"
#------------------------------------------------------------
proc ::t193::readRadec { } {
   variable private

   if { $private(readLoop) == 1 && $private(radecHandle) != "" } {
      set data [read -nonewline $private(radecHandle)]
      set data [split $data "\n" ]
      if { $data != "" } {
        ### ::console::disp "::t193::readRadec data=$data \n"
         #--- je recupere le dernier message (au cas ou il en aurait plusieurs qui se seraient accumul?s)
         set data [lindex $data end]
         set ah ""
         set am ""
         set as ""
         set dd ""
         set dm ""
         set ds ""
         set ba ""
         set nbVar [scan $data "%dh %dm %fs / %dd %d' %d'' /   %dd" ah am as dd dm ds ba]
         if { $nbVar == 7 || $nbVar == 6} {
            set ::audace(telescope,getra)  [format "%02dh%02dm%05.2fs" $ah $am $as]
            set ::audace(telescope,getdec) [format "%02dd%02d\'%02d\"" $dd $dm $ds]
         } else {
           ### ::console::affiche_erreur " ::t193::readRadec nombre de valeurs lues=$nbVar different de 7. Data=$data\n"
           ### ::console::affiche_erreur " ::t193::readRadec alpha=$ah m=$am s=$as delta=$dd m=$dm s=$ds angle=$ba\n"
         }
     }
      after 2000 ::t193::readRadec
   }
}

#------------------------------------------------------------
# getRadec
#    lit les coordonnees toutes les 2 secondes
#
#    "06h 23m 36.73s / +44d 35' 29'' /   -1d"
#------------------------------------------------------------
proc ::t193::getRadec { } {
   variable private

}

#------------------------------------------------------------
# onEnableModel
#    active ou desactive le modele de pointage
#
#------------------------------------------------------------
proc ::t193::onEnableModel { } {
   variable private
   variable widget

   if { $widget(model,enabled) == 0 } {
      $private(frm).model.modelList configure -state disabled
      $private(frm).model.configure configure -state disabled
   } else {
      $private(frm).model.modelList configure -state normal
      $private(frm).model.configure configure -state normal
   }
}

#------------------------------------------------------------
# onSelectModel
#    selectionne le modele de pointage
#
# @param tkCombo combobox contenant la liste des noms des modeles

#------------------------------------------------------------
proc ::t193::onSelectModel { tkCombo } {
   variable widget

   #--- je recupere l'identifiant du modele correspondant la ligne selectionne dans la combobox
   set modelId [::confTel::getModelIdentifiant [$tkCombo get]]
   if { $modelId != "" } {
      #--- j'ajoute les parametres manquants (en cas d'evolution de la liste des attributs d'un modele)
      if { [info exists ::conf(confTel,model,$modelId,name)] == 0 }         { set ::conf(confTel,model,$modelId,name)         $modelId }
      if { [info exists ::conf(confTel,model,$modelId,symbols)] == 0 }      { set ::conf(confTel,model,$modelId,symbols)      "" }
      if { [info exists ::conf(confTel,model,$modelId,coefficients)] == 0 } { set ::conf(confTel,model,$modelId,coefficients) "" }

      set widget(model,id)   $modelId
      set widget(model,date) $::conf(confTel,model,$modelId,date)
   }
}

