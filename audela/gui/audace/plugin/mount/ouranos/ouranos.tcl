#
# Fichier : ouranos.tcl
# Description : Configuration de la monture Ouranos
# Auteur : Robert DELMAS
# Mise à jour $Id: ouranos.tcl 13617 2016-04-05 15:38:17Z robertdelmas $
#

namespace eval ::ouranos {
   package provide ouranos 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ouranos.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::ouranos::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libouranos.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::ouranos::getPluginType]] "ouranos" "libouranos.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(ouranos,install_1) v[package version ouranos]. $::caption(ouranos,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::ouranos::getPluginTitle { } {
   global caption

   return "$caption(ouranos,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::ouranos::getPluginHelp { } {
   return "ouranos.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::ouranos::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::ouranos::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::ouranos::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::ouranos::isReady { } {
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
#    Initialise les variables conf(ouranos,...)
#
proc ::ouranos::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo)   "0"
   set private(lecture) "0"
   set private(find)    "0"
   set private(dim)     "0"

   #--- Initialisation des variables de la monture Ouranos
   if { ! [ info exists conf(ouranos,port) ] }          { set conf(ouranos,port)         "" }
   if { ! [ info exists conf(ouranos,cod_ra) ] }        { set conf(ouranos,cod_ra)       "32768" }
   if { ! [ info exists conf(ouranos,cod_dec) ] }       { set conf(ouranos,cod_dec)      "32768" }
   if { ! [ info exists conf(ouranos,freq) ] }          { set conf(ouranos,freq)         "1" }
   if { ! [ info exists conf(ouranos,init) ] }          { set conf(ouranos,init)         "0" }
   if { ! [ info exists conf(ouranos,inv_ra) ] }        { set conf(ouranos,inv_ra)       "1" }
   if { ! [ info exists conf(ouranos,inv_dec) ] }       { set conf(ouranos,inv_dec)      "1" }
   if { ! [ info exists conf(ouranos,show_coord) ] }    { set conf(ouranos,show_coord)   "1" }
   if { ! [ info exists conf(ouranos,tjrsvisible) ] }   { set conf(ouranos,tjrsvisible)  "0" }

   #--- Initialisation des fenetres d'affichage des coordonnees AD et Dec.
   if { ! [ info exists conf(ouranos,geometry) ] }      { set conf(ouranos,geometry)     "200x70+646+240" }
   if { ! [ info exists conf(ouranos,X10,geometry) ] }  { set conf(ouranos,X10,geometry) "850x500+0+0" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ouranos::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Ouranos dans le tableau private(...)
   if { $private(lecture) == "0" } {
      ::ouranos::init_ouranos
   }
   set private(port)          $conf(ouranos,port)
   set private(wmgeometry)    $conf(ouranos,geometry)
   set private(wmgeometryX10) $conf(ouranos,X10,geometry)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ouranos::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Ouranos dans le tableau conf(ouranos,...)
   set conf(ouranos,cod_ra)     $private(cod_ra)
   set conf(ouranos,cod_dec)    $private(cod_dec)
   set conf(ouranos,freq)       $private(freq)
   set conf(ouranos,init)       $private(init)
   set conf(ouranos,inv_ra)     $private(inv_ra)
   set conf(ouranos,inv_dec)    $private(inv_dec)
   set conf(ouranos,port)       $private(port)
   set conf(ouranos,show_coord) $private(show_coord)
}

#
# recupPosDim
#    Permet de recuperer et de sauvegarder la position de la fenetre de configuration
#
proc ::ouranos::recupPosDim { } {
   variable private
   global conf

   if { [ winfo exists .tjrsvisible ] } {
      set private(wmgeometry) [ wm geometry .tjrsvisible ]
      set conf(ouranos,geometry) $private(wmgeometry)
   } elseif { [ winfo exists .tjrsvisibleX10 ] } {
      set private(wmgeometryX10) [ wm geometry .tjrsvisibleX10 ]
      set conf(ouranos,X10,geometry) $private(wmgeometryX10)
   }
}

#
# fillConfigPage
#    Interface de configuration de la monture Ouranos
#
proc ::ouranos::fillConfigPage { frm } {
   variable private
   global caption color conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(ouranos,port) == "" } {
      set conf(ouranos,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(ouranos,port) ] == -1 } {
      lappend list_connexion $conf(ouranos,port)
   }

   #--- confToWidget
   ::ouranos::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 1

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x -expand 0

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill both -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side top -fill both -expand 1

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -side bottom -fill x -pady 2

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame2 -side left -fill both -expand 1

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame2 -side left -fill both -expand 1

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame2 -side left -fill both -expand 1 -pady 17

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame3 -side left -fill both -expand 1

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame3 -side left -fill both -expand 1

   frame $frm.frame12 -borderwidth 0 -relief raised
   pack $frm.frame12 -in $frm.frame7 -side top -fill both -expand 1

   frame $frm.frame13 -borderwidth 0 -relief raised
   pack $frm.frame13 -in $frm.frame7 -side top -fill both -expand 1

   frame $frm.frame14 -borderwidth 0 -relief raised
   pack $frm.frame14 -in $frm.frame8 -side top -fill both -expand 1

   frame $frm.frame15 -borderwidth 0 -relief raised
   pack $frm.frame15 -in $frm.frame8 -side top -fill both -expand 1

   #--- Definition du port
   label $frm.lab1 -text "$caption(ouranos,port)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

   entry $frm.status -textvariable ::ouranos::private(status) -width 4 -justify center -bg $color(red)
   pack $frm.status -in $frm.frame1 -anchor center -side left -padx 0 -pady 5

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
   button $frm.configure -text "$caption(ouranos,configurer)" -relief raised \
      -command {
         ::confLink::run ::ouranos::private(port) { serialport } \
            "- $caption(ouranos,controle) - $caption(ouranos,monture)"
      }
   pack $frm.configure -in $frm.frame1 -anchor n -side left -padx 10 -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable ::ouranos::private(port) \
      -editable 0     \
      -values $list_connexion
   pack $frm.port -in $frm.frame1 -anchor center -side left -padx 0 -pady 5

   #--- Selection affichage toujours visibles ou non
   checkbutton $frm.visible -text "$caption(ouranos,raquette)" -highlightthickness 0 \
      -variable ::ouranos::private(tjrsvisible) -onvalue 1 -offvalue 0 \
      -command { ::ouranos::tjrsVisible }
   pack $frm.visible -in $frm.frame1 -anchor center -side right -padx 13 -pady 5

   #--- Definition des unites de l'affichage (pas encodeurs ou coordonnees)
   checkbutton $frm.unites -text "$caption(ouranos,unites)" -highlightthickness 0 \
      -variable ::ouranos::private(show_coord) -onvalue 1 -offvalue 0 \
      -command { ::ouranos::show1 }
   pack $frm.unites -in $frm.frame1 -anchor center -side right -padx 0 -pady 5

   #--- Informations concernant le codeur RA
   label $frm.ra -text "$caption(ouranos,res_codeur)"
   pack $frm.ra -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

   #--- Valeur des pas encodeurs RA pour 1 tour
   entry $frm.codRA -textvariable ::ouranos::private(cod_ra) -justify center -width 7
   pack $frm.codRA -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

   #--- Definition de l'inversion de RA
   checkbutton $frm.invra -text "$caption(ouranos,inv)" -highlightthickness 0 \
      -variable ::ouranos::private(inv_ra) -onvalue -1 -offvalue 1
   pack $frm.invra -in $frm.frame14 -anchor center -side left -padx 10 -pady 5

   #--- Label pour les coordonnees RA
   label  $frm.encRA -text "$caption(ouranos,ra)"
   pack $frm.encRA -in $frm.frame14 -anchor center -side right -padx 10 -pady 5

   #--- Fenetre de lecture de RA
   label $frm.coordRA -textvariable ::ouranos::private(coord_ra) -justify left -width 12
   pack $frm.coordRA -in $frm.frame9 -anchor center -side top -padx 10 -pady 5

   #--- Informations concernant le codeur DEC
   label $frm.dec -text "$caption(ouranos,res_codeur)"
   pack $frm.dec -in $frm.frame13 -anchor center -side left -padx 10 -pady 5

   #--- Valeur des pas encodeurs DEC pour 1 tour
   entry $frm.codDEC -textvariable ::ouranos::private(cod_dec) -justify center -width 7
   pack $frm.codDEC -in $frm.frame13 -anchor center -side left -padx 10 -pady 5

   #--- Definition de l'inversion de DEC
   checkbutton $frm.invdec -text "$caption(ouranos,inv)" -highlightthickness 0 \
      -variable ::ouranos::private(inv_dec) -onvalue -1 -offvalue 1
   pack $frm.invdec -in $frm.frame15 -anchor center -side left -padx 10 -pady 5

   #--- Label pour les coordonnees DEC
   label $frm.encDEC -text "$caption(ouranos,dec)"
   pack $frm.encDEC -in $frm.frame15 -anchor center -side right -padx 10 -pady 5

   #--- Fenetre de lecture de DEC
   label $frm.coordDEC -textvariable ::ouranos::private(coord_dec) -justify left -width 12
   pack $frm.coordDEC -in $frm.frame9 -anchor center -side bottom -padx 10 -pady 5

   #--- Definition de l'initialisation DEC
   radiobutton $frm.dec90 -text "$caption(ouranos,init1)" -highlightthickness 0 \
      -indicatoron 1 -variable ::ouranos::private(init) -value 90 -command { }
   pack $frm.dec90 -in $frm.frame10 -anchor w -side top -padx 5 -pady 5

   radiobutton $frm.dec0 -text "$caption(ouranos,init2)" -highlightthickness 0 \
      -indicatoron 1 -variable ::ouranos::private(init) -value 0 -command { }
   pack $frm.dec0 -in $frm.frame10 -anchor w -side top -padx 5 -pady 5

   radiobutton $frm.dec-90 -text "$caption(ouranos,init3)" -highlightthickness 0 \
      -indicatoron 1 -variable ::ouranos::private(init) -value -90 -command { }
   pack $frm.dec-90 -in $frm.frame10 -anchor w -side top -padx 5 -pady 5

   #--- Les boutons de commande
   if { [ ::ouranos::isReady ] == 1 } {
      button $frm.but_init -text "$caption(ouranos,reglage)"  -width 7 -relief raised -state normal \
         -command { ::ouranos::find_res }
      pack $frm.but_init -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
      button $frm.but_close -text "$caption(ouranos,stop)" -width 6 -relief raised -state normal \
         -command { ::ouranos::close_com }
      pack $frm.but_close -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
      button $frm.but_read -text "$caption(ouranos,lire)" -width 6 -relief raised -state normal \
         -command { ::ouranos::go_ouranos }
      pack $frm.but_read -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
   } else {
      button $frm.but_init -text "$caption(ouranos,reglage)"  -width 7 -relief raised -state disabled
      pack $frm.but_init -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
      button $frm.but_close -text "$caption(ouranos,stop)" -width 6 -relief raised -state disabled
      pack $frm.but_close -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
      button $frm.but_read -text "$caption(ouranos,lire)" -width 6 -relief raised -state disabled
      pack $frm.but_read -in $frm.frame11 -anchor center -side left -padx 15 -pady 5 -ipady 5
   }

   #--- Definition de la frequence de lecture
   label  $frm.title1 -text "$caption(ouranos,seconde)"
   pack $frm.title1 -in $frm.frame11 -anchor center -side right -padx 5 -pady 5

   entry $frm.freq -textvariable ::ouranos::private(freq) -justify center -width 5
   pack $frm.freq -in $frm.frame11 -anchor center -side right -padx 5 -pady 5

   label  $frm.title -text "$caption(ouranos,frequence)"
   pack $frm.title -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

   #--- Site web officiel d'Ouranos
   label $frm.lab103 -text "$caption(ouranos,titre_site_web)"
   pack $frm.lab103 -in $frm.frame6 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame6 "$caption(ouranos,site_ouranos)" \
      "$caption(ouranos,site_ouranos)" ]
   pack $labelName -side top -fill x -pady 2

   #---
   if [ winfo exists .tjrsvisible ] {
      set private(tjrsvisible) "1"
   }
   if { $private(lecture) == "1" } {
      #--- Traitement graphique du bouton 'Lire'
      $frm.but_read configure -text "$caption(ouranos,lire)" -relief groove -state disabled
      #--- Traitement graphique du bouton 'Regler'
      $frm.but_init configure -text "$caption(ouranos,reglage)" -state disabled
   }
}

#
# configureMonture
#    Configure la monture Ouranos en fonction des donnees contenues dans les variables conf(ouranos,...)
#
proc ::ouranos::configureMonture { } {
   variable private
   global audace caption conf

   set catchResult [ catch {
      #--- Initialisation
      set conf(raquette) "0"
      #--- Je cree la monture
      set telNo [ tel::create ouranos $conf(ouranos,port) -resol_ra $conf(ouranos,cod_ra) \
         -resol_dec $conf(ouranos,cod_dec) -initial_dec $conf(ouranos,init) ]
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- J'initialise le sens de rotation des codeurs
      tel$telNo invert $conf(ouranos,inv_ra) $conf(ouranos,inv_dec)
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(ouranos,port_ouranos) $caption(ouranos,2points)\
         $conf(ouranos,port)\n"
      ::console::affiche_entete "$caption(ouranos,res_codeurs)\n"
      ::console::affiche_entete "$caption(ouranos,ra) $caption(ouranos,2points)\
         $conf(ouranos,cod_ra) $caption(ouranos,pas) $caption(ouranos,et) $caption(ouranos,dec)\
         $caption(ouranos,2points) $conf(ouranos,cod_dec) $caption(ouranos,pas)\n"
      ::console::affiche_saut "\n"
      #--- Je nettoye l'affichage les codeurs
      set private(coord_ra)  ""
      set private(coord_dec) ""
      #--- J'affiche le statut du port
      set private(status) $caption(ouranos,on)
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(ouranos,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Gestion des boutons actifs/inactifs
      ::ouranos::confOuranos

      #--- Si Ouranos est une monture secondaire, c'est AudeCom qui specifie l'utilisation de la raquette
      if { [ ::telescope::getSecondaryTelNo ] != "0" } {
         set conf(raquette) $::audecom::private(raquette)
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::ouranos::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture Ouranos
#
proc ::ouranos::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::ouranos::confOuranosInactif

   #--- Fermeture de la communication
   ::ouranos::close_com

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
# init_ouranos
# Initialisation de variables
#
proc ::ouranos::init_ouranos { } {
   variable private
   global caption conf

   #--- Initialisation de l'affichage du statut
   set private(status)      $caption(ouranos,off)

   #--- Initialisation de variables
   set private(cod_ra)      $conf(ouranos,cod_ra)
   set private(cod_dec)     $conf(ouranos,cod_dec)
   set private(freq)        $conf(ouranos,freq)
   set private(init)        $conf(ouranos,init)
   set private(inv_ra)      $conf(ouranos,inv_ra)
   set private(inv_dec)     $conf(ouranos,inv_dec)
   set private(show_coord)  $conf(ouranos,show_coord)
   set private(tjrsvisible) $conf(ouranos,tjrsvisible)
}

#
# find_res
# Recherche la resolution des 2 codeurs
#
proc ::ouranos::find_res { } {
   variable private

   #--- Effacement des fenetres auxiliaires
   set private(tjrsvisible) "0"
   if { [ winfo exists .tjrsvisible ] } {
      destroy .tjrsvisible
   } elseif { [ winfo exists .tjrsvisibleX10 ] } {
      destroy .tjrsvisibleX10
   }

   #--- Initialisation de variables
   set frm                            $private(frm)
   set private(lecture)               "1"
   set private(find)                  "1"
   set private(init)       "0"
   set private(inv_ra)     "1"
   set private(inv_dec)    "1"
   set private(show_coord) "0"

   #--- Traitement graphique des boutons 'Lire' et 'Regler' et des checkbuttons
   $frm.but_read configure -state disabled
   $frm.but_init configure -relief groove -state disabled
   $frm.unites configure -state disabled
   $frm.visible configure -state disabled
   $frm.invra configure -state disabled
   $frm.invdec configure -state disabled

   #--- Initialisation des sens de rotation des codeurs
   tel$private(telNo) invert $private(inv_ra) $private(inv_dec)

   #--- Initialisation du microcontroleur de l'interface
   #--- Commande equivalente aux 2 commandes suivantes :
   #--- R 65536 65536
   #--- I 0 0
   tel$private(telNo) adjust

   #--- Lecture et affichage des coordonnees
   ::ouranos::read_coord
}

#
# close_com
# Ferme le port serie s'il n'est pas deja ferme
#
proc ::ouranos::close_com { } {
   variable private
   global caption conf

   #--- Initialisation de variables
   set private(lecture) "0"
   set private(find)    "0"
   #--- Effacement des fenetres auxiliaires
   set private(tjrsvisible) "0"
   if { [ winfo exists .tjrsvisible ] } {
      destroy .tjrsvisible
   } elseif { [ winfo exists .tjrsvisibleX10 ] } {
      destroy .tjrsvisibleX10
   }
   #--- Traitement des autres widgets
   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Traitement graphique des boutons 'Lire' et 'Regler' et des checkbuttons
         $frm.but_init configure -relief raised -state disabled
         $frm.but_close configure -state disabled
         $frm.but_read configure -relief raised -state disabled
         $frm.unites configure -state normal
         $frm.visible configure -state normal
         $frm.invra configure -state normal
         $frm.invdec configure -state normal
      }
   }
   #--- Effacement des coordonnees AD et Dec.
   set private(coord_ra)  ""
   set private(coord_dec) ""
   #--- Fermeture du port et affichage du statut
   set private(status) $caption(ouranos,off)
   ::console::affiche_entete "$caption(ouranos,port_ouranos) ($conf(ouranos,port))\
      $caption(ouranos,2points) $caption(ouranos,ferme)\n\n"
}

#
# go_ouranos
# Lance la lecture des 2 codeurs
#
proc ::ouranos::go_ouranos { } {
   variable private

   #--- Initialisation de variables
   set frm $private(frm)
   set private(lecture) "1"
   #--- Traitement graphique des boutons 'Lire' et 'Regler'
   $frm.but_read configure -relief groove -state disabled
   $frm.but_init configure -state disabled
   #--- Lecture et affichage des coordonnees
   ::ouranos::read_coord
}

#
# read_coord
# Lecture des 2 codeurs et affichage des positions
#
proc ::ouranos::read_coord { } {
   variable private
   global caption

   #--- Affichage dans l'onglet Ouranos
   if { $private(find) == "0" } {
      ::ouranos::show1
   } else {
      ::ouranos::show2
   }
   #--- Affichage dans la boite auxiliaire
   if { $private(tjrsvisible) == "1" } {
      if { [ winfo exists .tjrsvisible ] } {
         .tjrsvisible.lab1 configure -text "$caption(ouranos,ad1) $private(coord_ra)"
         .tjrsvisible.lab2 configure -text "$caption(ouranos,dec1) $private(coord_dec)"
      }
      if { [ winfo exists .tjrsvisibleX10 ] } {
         .tjrsvisibleX10.lab1 configure -text "$caption(ouranos,ad1)\n$private(coord_ra)"
         .tjrsvisibleX10.lab2 configure -text "$caption(ouranos,dec1)\n$private(coord_dec)"
      }
   } else {
      destroy .tjrsvisible
      destroy .tjrsvisibleX10
   }
   #--- Et on recommence...
   if { $private(lecture) == "1" } {
      after [ expr $private(freq)*1000 ] ::ouranos::read_coord
   } else {
      #--- Effacement des coordonnees AD et Dec.
      set private(coord_ra)  ""
      set private(coord_dec) ""
   }
}

#
# show1
# Affichage en mode lecture (pas codeurs ou coordonnees)
#
proc ::ouranos::show1 { } {
   variable private
   global audace caption

   if { $private(telNo) == "0" } {
      return
   }
   if { $private(lecture) == "0" } {
      #--- Coordonnees AD et Dec. invisibles
      set private(coord_ra)  ""
      set private(coord_dec) ""
      return
   }
   if { $private(show_coord) == "0" } {
      #--- Affichage en mode pas codeurs
      set pas_encod [ tel$private(telNo) nbticks ]
      set private(coord_ra)  "[ lindex $pas_encod 0 ] $caption(ouranos,pas)"
      set private(coord_dec) "[ lindex $pas_encod 1 ] $caption(ouranos,pas)"
   } else {
      if { [ ::telescope::getSecondaryTelNo ] == "0" } {
         #--- Affichage en mode coordonnees pour la monture principale
         ::telescope::afficheCoord
         set private(coord_ra)  $audace(telescope,getra)
         set private(coord_dec) $audace(telescope,getdec)
      } else {
         #--- Affichage en mode coordonnees pour la monture secondaire
         set radec [ tel$private(telNo) radec coord -equinox J2000.0 ]
         set private(coord_ra)  [ lindex $radec 0 ]
         set private(coord_dec) [ lindex $radec 1 ]
      }
   }
}

#
# show2
# Affichage des pas codeurs en mode reglage
#
proc ::ouranos::show2 { } {
   variable private

   if { $private(telNo) == "0" } {
      return
   }
   set coords [ tel$private(telNo) nbticks ]

   set dec_enc [ format "%g" [ lindex $coords 1 ] ]
   set ra_enc  [ format "%g" [ lindex $coords 0 ] ]
   set dec_enc [ expr $private(inv_dec)*$dec_enc ]
   set ra_enc  [ expr $private(inv_ra)*$ra_enc ]
   if { [ expr abs($dec_enc)-32768 ] > "0" } {
      set dec_enc [ expr 65536-[ expr abs($dec_enc) ] ]
      set private(inv_dec) "-1"
   }
   if { [ expr abs($ra_enc)-32768 ] > "0" } {
      set ra_enc [ expr 65536-[ expr abs($ra_enc) ] ]
      set private(inv_ra) "-1"
   }
   set private(cod_dec) $dec_enc
   set private(cod_ra)  $ra_enc
}

#
# tjrsVisible
# Affichage visible des coordonnees ou des pas en petit
#
proc ::ouranos::tjrsVisible { } {
   variable private
   global audace caption color conf

   if { $private(tjrsvisible) == "0" } {
      if { [ winfo exists .tjrsvisible ] } {
         destroy .tjrsvisible
      } elseif { [ winfo exists .tjrsvisibleX10 ] } {
         destroy .tjrsvisibleX10
      }
   } else {
      set private(dim) "0"
      if { [ winfo exists .tjrsvisible ] } {
         destroy .tjrsvisible
      }
      toplevel .tjrsvisible -bg $color(blue_pad)
      wm transient .tjrsvisible $audace(base)
      wm resizable .tjrsvisible 0 0
      wm title .tjrsvisible "$caption(ouranos,pos_tel)"
      wm protocol .tjrsvisible WM_DELETE_WINDOW {
         ::ouranos::recupPosDim
         set ::ouranos::private(tjrsvisible) "0"
         destroy .tjrsvisible
      }
      wm geometry .tjrsvisible $private(wmgeometry)

      #--- Cree l'affichage d'AD et Dec
      label .tjrsvisible.lab1 -borderwidth 1 -anchor w -fg $color(white) -bg $color(blue_pad)
      pack .tjrsvisible.lab1 -padx 10 -pady 2
      label .tjrsvisible.lab2 -borderwidth 1 -anchor w -fg $color(white) -bg $color(blue_pad)
      pack .tjrsvisible.lab2 -padx 10 -pady 2

      #--- Bouton radio x1
      radiobutton .tjrsvisible.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -fg $color(white) -bg $color(blue_pad) -text "$caption(ouranos,x1)" \
         -activeforeground $color(white) -activebackground $color(blue_pad) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad)\
         -variable ::ouranos::private(dim) -value 0 \
         -command {
            destroy .tjrsvisibleX10
            ::ouranos::tjrsVisible
         }
      pack .tjrsvisible.rad0 -padx 20 -pady 2 -side left
      #--- Bouton radio x10
      radiobutton .tjrsvisible.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -fg $color(white) -bg $color(blue_pad) -text "$caption(ouranos,x5)" \
         -activeforeground $color(white) -activebackground $color(blue_pad) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad)\
         -variable ::ouranos::private(dim) -value 1 \
         -command {
            destroy .tjrsvisible
            ::ouranos::tjrsVisibleX10
         }
      pack .tjrsvisible.rad1 -padx 20 -pady 2 -side right
      #--- La fenetre est active
      focus .tjrsvisible
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .tjrsvisible <Key-F1> { ::console::GiveFocus }
   }
}

#
# tjrsVisibleX10
# Affichage visible des coordonnees ou des pas en gros
#
proc ::ouranos::tjrsVisibleX10 { } {
   variable private
   global audace caption color conf

   if { $private(tjrsvisible) == "0" } {
      if { [ winfo exists .tjrsvisibleX10 ] } {
         destroy .tjrsvisibleX10
      } elseif { [ winfo exists .tjrsvisible ] } {
            destroy .tjrsvisible
      }
   } else {
      if { [ winfo exists .tjrsvisibleX10 ] } {
         destroy .tjrsvisibleX10
      }
      toplevel .tjrsvisibleX10 -bg $color(blue_pad)
      wm transient .tjrsvisibleX10 $audace(base)
      wm resizable .tjrsvisibleX10 0 0
      wm title .tjrsvisibleX10 "$caption(ouranos,pos_tel)"
      wm protocol .tjrsvisibleX10 WM_DELETE_WINDOW {
         ::ouranos::recupPosDim
         set ::ouranos::private(tjrsvisible) "0"
         destroy .tjrsvisibleX10
      }
      wm geometry .tjrsvisibleX10 $private(wmgeometryX10)

      #--- Cree l'affichage d'AD et Dec
      label .tjrsvisibleX10.lab1 -borderwidth 1 -anchor w -font {verdana 60 bold} \
         -fg $color(white) -bg $color(blue_pad)
      pack .tjrsvisibleX10.lab1 -padx 10 -pady 2
      label .tjrsvisibleX10.lab2 -borderwidth 1 -anchor w -font {verdana 60 bold} \
         -fg $color(white) -bg $color(blue_pad)
      pack .tjrsvisibleX10.lab2 -padx 10 -pady 2

      #--- Bouton radio x1
      radiobutton .tjrsvisibleX10.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -font {verdana 30 bold} -text "$caption(ouranos,:5)" -value 0 -variable ::ouranos::private(dim) \
         -fg $color(white) -bg $color(blue_pad) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -activeforeground $color(white) -activebackground $color(blue_pad) \
         -command {
            destroy .tjrsvisibleX10
            ::ouranos::tjrsVisible
         }
      pack .tjrsvisibleX10.rad0 -padx 100 -pady 10 -side left
      #--- Bouton radio x10
      radiobutton .tjrsvisibleX10.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -font {verdana 30 bold} -text "$caption(ouranos,x1)" -value 1 -variable ::ouranos::private(dim) \
         -fg $color(white) -bg $color(blue_pad) \
         -selectcolor $color(blue_pad) -highlightbackground $color(blue_pad) \
         -activeforeground $color(white) -activebackground $color(blue_pad) \
         -command {
            destroy .tjrsvisible
            ::ouranos::tjrsVisibleX10
         }
      pack .tjrsvisibleX10.rad1 -padx 100 -pady 10 -side right
      #--- La fenetre est active
      focus .tjrsvisibleX10
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .tjrsvisibleX10 <Key-F1> { ::console::GiveFocus }
   }
}
#
# confOuranos
# Permet d'activer ou de desactiver les boutons 'Regler', 'Stopper' et 'Lire'
#
proc ::ouranos::confOuranos { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::ouranos::isReady ] == 1 } {
            #--- Boutons de la monture actifs
            $frm.but_init configure -relief raised -state normal -command { ::ouranos::find_res }
            $frm.but_close configure -relief raised -state normal -command { ::ouranos::close_com }
            $frm.but_read configure -relief raised -state normal -command { ::ouranos::go_ouranos }
         } else {
            #--- Boutons de la monture inactifs
            $frm.but_init configure -state disabled
            $frm.but_close configure -state disabled
            $frm.but_read configure -state disabled
         }
      }
   }
}

#
# confOuranosInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::ouranos::confOuranosInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::ouranos::isReady ] == 1 } {
            #--- Boutons de la monture inactifs
            $frm.but_init configure -state disabled
            $frm.but_close configure -state disabled
            $frm.but_read configure -state disabled
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
proc ::ouranos::getPluginProperty { propertyName } {
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
      hasGoto                 { return 0 }
      hasMatch                { return 1 }
      hasManualMotion         { return 0 }
      hasControlSuivi         { return 0 }
      hasModel                { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
   }
}

