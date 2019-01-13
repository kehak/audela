#
# Fichier : eqmod.tcl
# Description : Configuration de la monture EQMOD
# Auteur : Robert DELMAS
# Mise à jour $Id: eqmod.tcl 11699 2015-03-24 22:15:22Z alainklotz $
#

namespace eval ::eqmod {
   package provide eqmod 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] eqmod.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::eqmod::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libeqmod.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::eqmod::getPluginType]] "eqmod" "libeqmod.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(eqmod,install_1) v[package version eqmod]. $::caption(eqmod,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::eqmod::getPluginTitle { } {
   global caption

   return "$caption(eqmod,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::eqmod::getPluginHelp { } {
   return "eqmod.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::eqmod::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::eqmod::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::eqmod::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::eqmod::isReady { } {
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
#    Initialise les variables conf(eqmod,...)
#
proc ::eqmod::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture EQMOD
   if { ! [ info exists conf(eqmod,port) ] }        { set conf(eqmod,port)        "" }
   if { ! [ info exists conf(eqmod,tube_e_w) ] }    { set conf(eqmod,tube_e_w)    "-west" }
   if { ! [ info exists conf(eqmod,initpos) ] }     { set conf(eqmod,initpos)     "south" }
   if { ! [ info exists conf(eqmod,limiteEst) ] }   { set conf(eqmod,limiteEst)   "2" }
   if { ! [ info exists conf(eqmod,limiteOuest) ] } { set conf(eqmod,limiteOuest) "2" }
   if { ! [ info exists conf(eqmod,moteur_on) ] }   { set conf(eqmod,moteur_on)   "1" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::eqmod::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture EQMOD dans le tableau private(...)
   foreach varname [ list raquette eqmod,port eqmod,tube_e_w eqmod,initpos eqmod,limiteEst eqmod,limiteOuest eqmod,moteur_on ] {
      if { [ catch { set private($varname) [ set conf($varname) ] } m ] } {
         ::console::affiche_resultat "$varname: $m"
         switch $varname {
            eqmod,port        { set private($varname) "//./COM1" }
            eqmod,tube_e_w    { set private($varname) "-west" }
            eqmod,initpos     { set private($varname) "south" }
            eqmod,limiteEst   { set private($varname) "2" }
            eqmod,limiteOuest { set private($varname) "2" }
            eqmod,moteur_on   { set private($varname) "1" }
            raquette          { set private($varname) "0" }
         }
         ::console::affiche_resultat "$caption(eqmod,valeurDefaut) $private($varname)\n"
      }
   }
   set private(raquette) $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::eqmod::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture EQMOD dans le tableau conf(eqmod,...)
   set conf(eqmod,port)        $private(eqmod,port)
   set conf(eqmod,tube_e_w)    $private(eqmod,tube_e_w)
   set conf(eqmod,initpos)     $private(eqmod,initpos)
   set conf(eqmod,limiteEst)   $private(eqmod,limiteEst)
   set conf(eqmod,limiteOuest) $private(eqmod,limiteOuest)
   set conf(eqmod,moteur_on)   $private(eqmod,moteur_on)
   set conf(raquette)          $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture EQMOD
#
proc ::eqmod::fillConfigPage { frm } {
   variable private
   global caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(eqmod,port) == "" } {
      set conf(eqmod,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(eqmod,port) ] == -1 } {
      lappend list_connexion $conf(eqmod,port)
   }

   #--- confToWidget
   ::eqmod::confToWidget




   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised

   frame $frm.frame2 -borderwidth 0 -relief raised

   frame $frm.frame2c -borderwidth 0 -relief raised

   TitleFrame $frm.frame2d -borderwidth 2 -relief ridge -text "$caption(eqmod,retournement)"

   frame $frm.frame2b -borderwidth 0 -relief raised

   frame $frm.frame3 -borderwidth 0 -relief raised

   frame $frm.frame4 -borderwidth 0 -relief raised

   frame $frm.frame4b -borderwidth 0 -relief raised

   frame $frm.frame5 -borderwidth 0 -relief raised

   frame $frm.frame6 -borderwidth 0 -relief raised

   frame $frm.frame7 -borderwidth 0 -relief raised

   frame $frm.frame8 -borderwidth 0 -relief raised

   pack $frm.frame1 -side top -fill x
   pack $frm.frame2 -side top -fill x
   pack $frm.frame2c -side top -fill x
   pack $frm.frame2d -side top -fill x
   pack $frm.frame2b -side top -fill x
   pack $frm.frame3 -side top -fill x
   pack $frm.frame4 -side top -fill x
   pack $frm.frame4b -side top -fill x
   pack $frm.frame5 -side bottom -fill x -pady 2
   pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1
   pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1
   pack $frm.frame8 -in $frm.frame7 -side top -fill x

   #--- Definition du port
   label $frm.lab1 -text "$caption(eqmod,port)"
   pack $frm.lab1 -in $frm.frame6 -anchor center -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $private(eqmod,port) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(eqmod,port) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports et liaisons
   button $frm.configure -text "$caption(eqmod,configurer)" -relief raised \
      -command {
         ::confLink::run ::eqmod::private(eqmod,port) { serialport } \
            "- $caption(eqmod,controle) - $caption(eqmod,monture)"
      }
   pack $frm.configure -in $frm.frame6 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::eqmod::private(eqmod,port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame6 -anchor center -side left -padx 10 -pady 10

   #--- Les radiobuttons de configuration de la position initiale du tube par rapport au meridien
   label $frm.labConfTube -text "$caption(eqmod,config_tube)"
   pack $frm.labConfTube -in $frm.frame2 -anchor center -side left -padx 10 -pady 10
   radiobutton $frm.tube_West -text "$caption(eqmod,tube_ouest)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,tube_e_w) -value "-west"
   pack $frm.tube_West -in $frm.frame2 -anchor center -side right -padx 7 -pady 10
   radiobutton $frm.tube_East -text "$caption(eqmod,tube_est)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,tube_e_w) -value "-east"
   pack $frm.tube_East -in $frm.frame2 -anchor center -side right -padx 7 -pady 10

   #--- Les radiobuttons d'indication de la position reelle du tube a l'initialisation
   label $frm.labPosTube -text "$caption(eqmod,pos_tube)"
   pack $frm.labPosTube -in $frm.frame2c -anchor center -side left -padx 10 -pady 10
   radiobutton $frm.posWest -text "$caption(eqmod,ouest)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,initpos) -value "west"
   pack $frm.posWest -in $frm.frame2c -anchor center -side right -padx 7 -pady 10
   radiobutton $frm.posEast -text "$caption(eqmod,est)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,initpos) -value "east"
   pack $frm.posEast -in $frm.frame2c -anchor center -side right -padx 7 -pady 10
   radiobutton $frm.posNorth -text "$caption(eqmod,nord)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,initpos) -value "north"
   pack $frm.posNorth -in $frm.frame2c -anchor center -side right -padx 7 -pady 10
   radiobutton $frm.posSouth -text "$caption(eqmod,sud)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,initpos) -value "south"
   pack $frm.posSouth -in $frm.frame2c -anchor center -side right -padx 7 -pady 10
   radiobutton $frm.posNorthPole -text "$caption(eqmod,pole_nord)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,initpos) -value "north_pole"
   pack $frm.posNorthPole -in $frm.frame2c -anchor center -side right -padx 7 -pady 10
   radiobutton $frm.posSouthPole -text "$caption(eqmod,pole_sud)" \
      -highlightthickness 0 -variable ::eqmod::private(eqmod,initpos) -value "south_pole"
   pack $frm.posSouthPole -in $frm.frame2c -anchor center -side right -padx 7 -pady 10

   #--- Le label et les entry pour definir les limites est et ouest pour le retournement
   label $frm.labRetournement -text "$caption(eqmod,reference)"
   pack $frm.labRetournement -in [ $frm.frame2d getframe ] -anchor center -side left -padx 10 -pady 10
   label $frm.labLimiteEst -text "$caption(eqmod,limite_est)"
   pack $frm.labLimiteEst -in [ $frm.frame2d getframe ] -anchor center -side left -padx 0 -pady 10
   entry $frm.entLimiteEst -textvariable ::eqmod::private(eqmod,limiteEst) -width 4 -justify center
   pack $frm.entLimiteEst -in [ $frm.frame2d getframe ] -anchor n -side left -padx 10 -pady 10
   label $frm.labLimiteOuest -text "$caption(eqmod,limite_ouest)"
   pack $frm.labLimiteOuest -in [ $frm.frame2d getframe ] -anchor center -side left -padx 0 -pady 10
   entry $frm.entLimiteOuest -textvariable ::eqmod::private(eqmod,limiteOuest) -width 4 -justify center
   pack $frm.entLimiteOuest -in [ $frm.frame2d getframe ] -anchor n -side left -padx 10 -pady 10

   #--- Le checkbutton pour le demarrage du suivi sideral a l'init
   checkbutton $frm.moteur_on -text "$caption(eqmod,moteur_on)" -highlightthickness 0 -variable ::eqmod::private(eqmod,moteur_on)
   pack $frm.moteur_on -in $frm.frame2b -anchor center -side left -padx 10 -pady 10

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(eqmod,raquette_tel)" -highlightthickness 0 -variable ::eqmod::private(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

   #--- Affichage des coordonnees
#   label $frm.lab_coordHA -text "$caption(eqmod,angle_horaire) $caption(eqmod,N/A)"
#   pack $frm.lab_coordHA -in $frm.frame4 -anchor center -side left -padx 10 -pady 10

#   label $frm.lab_coordDEC -text "$caption(eqmod,DEC) $caption(eqmod,N/A)"
#   pack $frm.lab_coordDEC -in $frm.frame4 -anchor center -side right -padx 10 -pady 10

#   label $frm.lab_coordRA -text "$caption(eqmod,AD) $caption(eqmod,N/A)"
#   pack $frm.lab_coordRA -in $frm.frame4 -anchor center -side top -padx 10 -pady 10

#   label $frm.lab_MotorRA -text "$caption(eqmod,position_AD) $caption(eqmod,N/A)"
#   pack $frm.lab_MotorRA -in $frm.frame4b -anchor center -side left -padx 10 -pady 10

#   label $frm.lab_MotorDEC -text "$caption(eqmod,position_DEC) $caption(eqmod,N/A)"
#   pack $frm.lab_MotorDEC -in $frm.frame4b -anchor center -side right -padx 10 -pady 10

   #--- Site web officiel du EQMOD
   label $frm.lab103 -text "$caption(eqmod,titre_site_web)"
   pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame5 "$caption(eqmod,site_eqmod)" \
      "$caption(eqmod,site_eqmod)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Gestion du bouton actif/inactif
#   ::eqmod::confEQMOD

   #--- Affichage des positions moteurs si le telescope est deja operationnel
#   ::eqmod::dispCoord
}

#
# configureMonture
#    Configure la monture EQMOD en fonction des donnees contenues dans les variables conf(eqmod,...)
#
proc ::eqmod::configureMonture { } {
   variable private
   global caption conf confgene

   set catchResult [ catch {
      #--- Je cree la monture
      ::console::affiche_resultat "$caption(eqmod,positionMonture) $confgene(posobs,observateur,gps)\n"
      if { $conf(eqmod,moteur_on) == 1 } {
         set telNo [ tel::create eqmod $conf(eqmod,port) \
            $conf(eqmod,tube_e_w) \
            -point $conf(eqmod,initpos) \
            -gps $confgene(posobs,observateur,gps) \
            -startmotor \
         ]
      } else {
         set telNo [ tel::create eqmod $conf(eqmod,port) \
            $conf(eqmod,tube_e_w) \
            -point $conf(eqmod,initpos) \
            -gps $confgene(posobs,observateur,gps) \
         ]
      }
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- Je configure la monture pour les retournements
      set limiteEst   [ expr 24. - $conf(eqmod,limiteEst) ]h
      set limiteOuest $conf(eqmod,limiteOuest)h
      tel$telNo limits $limiteEst $limiteOuest
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(eqmod,port_eqmod) $caption(eqmod,2points) $conf(eqmod,port)\n"
      ::console::affiche_saut "\n"
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      # La ligne suivante cause un probleme et fait remonter une erreur (AK)
      # set linkNo [ ::confLink::create $conf(eqmod,port) "tel$telNo" "control" [ tel$telNo product ] ]
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::eqmod::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture EQMOD
#
proc ::eqmod::stop { } {
   variable private

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
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# dispCoord
#    Affichage des positions moteurs
#
proc ::eqmod::dispCoord { } {
   variable private
   global caption

   if { ! [ winfo exists $private(frm) ] || ! [ ::eqmod::isReady ] } {
      return
   }
   set radec [ tel$private(telNo) radec coord -equinox J2000.0 ]
   set hadec [ tel$private(telNo) hadec coord ]

   $private(frm).lab_coordHA configure -text "$caption(eqmod,angle_horaire) [ lindex $hadec 0 ]"
   $private(frm).lab_coordRA configure -text "$caption(eqmod,AD) [ lindex $radec 0 ]"
   $private(frm).lab_coordDEC configure -text "$caption(eqmod,DEC) [ lindex $radec 1 ]"

   $private(frm).lab_MotorRA configure -text "$caption(eqmod,position_AD) [ tel$private(telNo) putread :j1 ]"
   $private(frm).lab_MotorDEC configure -text "$caption(eqmod,position_DEC) [ tel$private(telNo) putread :j2 ]"

   after 500 ::eqmod::dispCoord
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
proc ::eqmod::getPluginProperty { propertyName } {
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
