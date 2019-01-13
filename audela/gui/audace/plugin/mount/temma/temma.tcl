#
# Fichier : temma.tcl
# Description : Fenetre de configuration pour le parametrage du suivi d'objets mobiles pour la monture Temma
# Auteur : Robert DELMAS et Raymond ZACHANTKE
# Mise à jour $Id: temma.tcl 13616 2016-04-05 15:34:15Z robertdelmas $
#

namespace eval ::temma {
   package provide temma 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] temma.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::temma::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libtemma.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::temma::getPluginType]] "temma" "libtemma.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(temma,install_1) v[package version temma]. $::caption(temma,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::temma::getPluginTitle { } {
   global caption

   return "$caption(temma,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::temma::getPluginHelp { } {
   return "temma.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::temma::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::temma::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::temma::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::temma::isReady { } {
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
#    Initialise les variables conf(temma,...)
#
proc ::temma::initPlugin { } {
   variable private
   global audace conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Charge le fichier auxiliaire
   uplevel #0 "source \"[ file join $audace(rep_plugin) mount temma temmaconfig.tcl ]\""

   #--- Initialise les variables de la monture Temma
   if { ! [ info exists conf(temma,port) ] }       { set conf(temma,port)       "" }
   if { ! [ info exists conf(temma,correc_AD) ] }  { set conf(temma,correc_AD)  "50" }
   if { ! [ info exists conf(temma,correc_Dec) ] } { set conf(temma,correc_Dec) "50" }
   if { ! [ info exists conf(temma,liaison) ] }    { set conf(temma,liaison)    "1" }
   if { ! [ info exists conf(temma,modele) ] }     { set conf(temma,modele)     "0" }
   if { ! [ info exists conf(temma,suivi_ad) ] }   { set conf(temma,suivi_ad)   "0" }
   if { ! [ info exists conf(temma,suivi_dec) ] }  { set conf(temma,suivi_dec)  "0" }
   if { ! [ info exists conf(temma,type) ] }       { set conf(temma,type)       "0" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::temma::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la monture Temma dans le tableau private(...)
   set private(port)       $conf(temma,port)
   set private(correc_AD)  $conf(temma,correc_AD)
   set private(correc_Dec) $conf(temma,correc_Dec)
   set private(liaison)    $conf(temma,liaison)
   set private(modele)     [ lindex "$caption(temma,modele_1) $caption(temma,modele_2) $caption(temma,modele_3)" $conf(temma,modele) ]
   set private(suivi_ad)   $conf(temma,suivi_ad)
   set private(suivi_dec)  $conf(temma,suivi_dec)
   set private(type)       $conf(temma,type) ; # 0=sideral, 1=comete, 2=solaire
   set private(raquette)   $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::temma::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la monture Temma dans le tableau conf(temma,...)
   set conf(temma,correc_AD)  $private(correc_AD)
   set conf(temma,correc_Dec) $private(correc_Dec)
   set conf(temma,liaison)    $private(liaison)
   set conf(temma,modele)     [ lsearch "$caption(temma,modele_1) $caption(temma,modele_2) $caption(temma,modele_3)" "$private(modele)" ]
   set conf(temma,port)       $private(port)
   set conf(temma,suivi_ad)   $private(suivi_ad)
   set conf(temma,suivi_dec)  $private(suivi_dec)
   set conf(temma,type)       $private(type)
   set conf(raquette)         $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture Temma
#
proc ::temma::fillConfigPage { frm } {
   variable private
   global audace caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(temma,port) == "" } {
      set conf(temma,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(temma,port) ] == -1 } {
      lappend list_connexion $conf(temma,port)
   }

   #--- confToWidget
   ::temma::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised ; #-- frame du port et du modele
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised ; #-- frame conteneur des frames 4 et 5
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised ; #-- frame de la position du telescope
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised ; #-- frame du réglage de la vitesse de correction
   pack $frm.frame4 -in $frm.frame2 -side left -fill x -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised ; #-- frame du réglage de la vitesse de correction
   pack $frm.frame5 -in $frm.frame2 -side left -fill x

   frame $frm.frame6 -borderwidth 0 -relief raised ; #-- frame du changement de position
   pack $frm.frame6 -side top -fill x

   frame $frm.frame8 -borderwidth 0 -relief raised ; #-- frame du choix de la raquette
   pack $frm.frame8 -side top -fill x

   frame $frm.frame9 -borderwidth 0 -relief raised ; #-- frame de l'url
   pack $frm.frame9 -side bottom -fill x -pady 2

   #--- Definition du port
   label $frm.lab1 -text "$caption(temma,port)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

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
   button $frm.configure -text "$caption(temma,configurer)" -relief raised \
      -command {
         ::confLink::run ::temma::private(port) { serialport } \
            "- $caption(temma,controle) - $caption(temma,monture)"
      }
   pack $frm.configure -in $frm.frame1 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::temma::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

   #--- Definition du modele Temma
   set list_combobox [ list $caption(temma,modele_1) $caption(temma,modele_2) \
      $caption(temma,modele_3) ]
   ComboBox $frm.modele \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::temma::private(modele) \
      -editable 0       \
      -values $list_combobox
   pack $frm.modele -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

   label $frm.lab2 -text "$caption(temma,modele)"
   pack $frm.lab2 -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

    #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
   checkbutton $frm.liaison -text "$caption(temma,liaison_AD_Dec)" -highlightthickness 0 \
      -variable ::temma::private(liaison) -command { ::temma::configCorrectionTemma }
   pack $frm.liaison -in $frm.frame4 -anchor center -side left -padx 10

   #--- Label de la correction en AD
   label $frm.lab3 -text "$caption(temma,correc_AD)"
   pack $frm.lab3 -in $frm.frame4 -anchor e -side top

   #--- Label de la correction en Dec
   label $frm.lab4 -text "$caption(temma,correc_Dec)"
   pack $frm.lab4 -in $frm.frame4 -anchor e -side top

   #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
   scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
      -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_AD) -width 10
   pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10
   bind $frm.correc_variantAD <ButtonRelease-1> {::temma::setCorrectionSpeed}

   #--- Reglage de la vitesse de correction en Dec. pour la vitesse normale (NS)
   scale $frm.correc_variantDec -from 10 -to 90 -length 210 -orient horizontal -showvalue true \
      -tickinterval 10 -borderwidth 2 -relief groove -variable ::temma::private(correc_Dec) -width 10

   #--- Configure les echelles de vitesse de correction lente d'AD et de Dec.
   ::temma::configCorrectionTemma

   #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
   label $frm.pos_tel -text "$caption(temma,position_telescope)"
   pack $frm.pos_tel -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
   pack $frm.pos_tel_ew -in $frm.frame3 -anchor center -side left -pady 10

   #--- Initialisation de l'instrument au zenith
   button $frm.init_zenith -text "$caption(temma,init_zenith)"
   pack $frm.init_zenith -in $frm.frame3 -anchor nw -side right -padx 10 -pady 10 -ipadx 10 -ipady 5

   #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
   label $frm.pos_tel_est -text "$caption(temma,change_position_telescope)"
   pack $frm.pos_tel_est -in $frm.frame6 -anchor center -side left -padx 10 -pady 5

   button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel)
   pack $frm.chg_pos_tel -in $frm.frame6 -anchor nw -side left -padx 10 -pady 10 -ipadx 10 -ipady 5

   #--- Bouton de controle de la vitesse de suivi
   button $frm.tracking -text "$caption(temma,ctl_mobile)" -state normal \
      -command { ::confTemmaMobile::run "$audace(base).confTemmaMobile" }
   pack $frm.tracking -in $frm.frame6 -anchor center -side right -padx 10 -pady 10 -ipadx 10 -ipady 5

   #--- Rafraichissement de la position du telescope par rapport a la monture
   if { [ ::temma::isReady ] == 1 } {
      #--- Affichage de la position du telescope
      ::telescope::monture_allemande
   }

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(temma,raquette_tel)" \
      -highlightthickness 0 -variable ::temma::private(raquette)
   pack $frm.raquette -in $frm.frame8 -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame8 -side left -padx 0 -pady 10

   #--- Site web officiel Temma et Takahashi
   label $frm.lab103 -text "$caption(temma,titre_site_web)"
   pack $frm.lab103 -in $frm.frame9 -side top -fill x -pady 2

  ### set labelName [ ::confTel::createUrlLabel $frm.frame9 "$caption(temma,site_temma)" \
  ###    "$caption(temma,site_temma)" ]
  ### pack $labelName -side top -fill x -pady 2

   #--- Lorsque "caption(temma,site_temma)" contiendra l'adresse web d'un site Temma
   #--- Il faudra supprimer les 4 lignes ci-dessous et decommenter les 3 lignes ci-dessus
   label $frm.labURL -text "$caption(temma,site_temma)" -fg $::color(blue)
   pack $frm.labURL -in $frm.frame9 -side top -fill x -pady 2
   bind $frm.labURL <Enter> "$frm.labURL configure -fg $::color(purple)"
   bind $frm.labURL <Leave> "$frm.labURL configure -fg $::color(blue)"

   #--- Gestion des boutons actifs/inactifs
   ::temma::confTemma
}

#
# configureMonture
#    Configure la monture Temma en fonction des donnees contenues dans les variables conf(temma,...)
#
proc ::temma::configureMonture { } {
   variable private
   global audace caption conf

   set catchResult [ catch {
      #--- Je cree la monture et j'envoie les coordonnees de l'observatoire
      #--- La commande "create" de Temma doit toujours avoir l'argument "_home"
      set telNo [ tel::create temma $conf(temma,port) -home $audace(posobs,observateur,gps) ]
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $audace(posobs,observateur,gps)
      tel$telNo home name $conf(posobs,nom_observatoire)
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- Lit le modele
      if { $conf(temma,modele) == "0" } {
         set private(modele) $caption(temma,modele_1)
      } elseif { $conf(temma,modele) == "1" } {
         set private(modele) $caption(temma,modele_2)
      } else {
         set private(modele) $caption(temma,modele_3)
      }
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(temma,port_temma) ($private(modele)) \
         $caption(temma,2points) $conf(temma,port)\n"
      #--- Lit et affiche la version du Temma
      set version [ tel$telNo firmware ]
      ::console::affiche_entete "$caption(temma,version) $version\n"
      ::console::affiche_saut "\n"
      #--- Interroge et recoit la latitude
      set latitude_temma [ tel$telNo getlatitude ]
      #--- Mise en forme de la latitude pour affichage dans la Console
      if {$latitude_temma > 0} {
         set hemisphere N
      } else {
         set hemisphere S
      }
      set latitude_temma [ mc_angle2dms [expr { abs($latitude_temma) }] 90 nozero 1 auto list ]
      lassign  [ mc_angle2dms $latitude_temma 90 nozero 1 auto list ] deg min sec
      set latitude_temma [format "%s %i° %02i' %02.2f\"" $hemisphere $deg $min $sec]
      #--- Affichage de la latitude
      ::console::affiche_entete "$caption(temma,init_module)\n"
      ::console::affiche_entete "$caption(temma,latitude) $latitude_temma\n\n"
      #--- Prise en compte des encodeurs
      tel$telNo encoder "1"
      #--- Force la mise en marche des moteurs
      tel$telNo radec motor on
      #--- Correction de la vitesse de derive en ad et en dec (cometes) en 24h
      if { $conf(temma,type) == "0" } {
         tel$telNo driftspeed 0 0
         ::console::affiche_resultat "$caption(temma,mobile_etoile)\n\n"
      } elseif { $conf(temma,type) == "1" } {
         tel$telNo driftspeed $conf(temma,suivi_ad) $conf(temma,suivi_dec)
         lassign [ tel$telNo driftspeed ] drift_ra drift_dec
         ::console::affiche_resultat "$caption(temma,mobile_comete)\n\n"
         ::console::affiche_resultat "$caption(temma,mobile_ad) $caption(temma,2points) $drift_ra\n"
         ::console::affiche_resultat "$caption(temma,mobile_dec) $caption(temma,2points) $drift_dec\n"
      } elseif { $conf(temma,type) == "2" } {
         tel$telNo solartracking
         ::console::affiche_resultat "$caption(temma,mobile_soleil)\n\n"
      }
      #--   fixe la temporisarion a 100 ms
      tel$telNo tempo 100
      #--- Prise en compte des corrections de la vitesse normale en AD et en Dec.
      if { $conf(temma,liaison) == "1" } {
         set correc_Dec $conf(temma,correc_AD)
      } else {
         set correc_Dec $conf(temma,correc_Dec)
      }
      lassign [tel$telNo correctionspeed $conf(temma,correc_AD) $correc_Dec ] cor_AD cor_Dec
      ::console::affiche_resultat "$caption(temma,correc_AD) $caption(temma,2points) $cor_AD\n"
      ::console::affiche_resultat "$caption(temma,correc_Dec) $caption(temma,2points) $cor_Dec\n"
      #--- Affichage de la position du telescope
      if { [ ::temma::isReady ] == 1 } {
         ::telescope::monture_allemande
      }
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(temma,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Gestion des boutons actifs/inactifs
      ::temma::confTemma
      ::temma::configCorrectionTemma
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::temma::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
#------------------------------------------------------------
# stop
#    Arrete la monture Temma
#    Commande du bouton "Arreter"
#------------------------------------------------------------
proc ::temma::stop { } {
   variable private

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Gestion du bouton actif/inactif
   ::temma::confTemmaInactif

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

#------------------------------------------------------------
# confTemmaInactif
#  Desactive le bouton de changement de la position
#  Lancee par ::temm::stop
#------------------------------------------------------------
proc ::temma::confTemmaInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::temma::isReady ] == 1 } {
            #--- Initialise les variables comme a l'origine : indefinis
            set ::audace(pos_tel_ew)  ""
            set ::audace(chg_pos_tel) ""
            #--- Boutons de la monture inactifs
            $frm.init_zenith configure -state disabled
            $frm.chg_pos_tel configure -state disabled
         }
      }
   }
}

#------------------------------------------------------------
# confTemma
#  Active ou Desactive les boutons
#------------------------------------------------------------
proc ::temma::confTemma { } {
   variable private
   global audace

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::temma::isReady ] == 1 } {
            #--- Boutons de la monture actifs
            $frm.init_zenith configure -state normal -command {
               tel$::temma::private(telNo) initzenith
               ::telescope::afficheCoord
            }
            $frm.chg_pos_tel configure -state normal -textvariable audace(chg_pos_tel) -command {
               set pos_tel [ tel$::temma::private(telNo) german ]
               if { $pos_tel == "E" } {
                  tel$::temma::private(telNo) german W
               } elseif { $pos_tel == "W" } {
                  tel$::temma::private(telNo) german E
               }
               ::telescope::monture_allemande
            }
         } else {
            #--- Boutons de la monture inactifs
            $frm.init_zenith configure -state disabled
            $frm.chg_pos_tel configure -text "  ?  " -state disabled

         }
      }
   }
}

#------------------------------------------------------------
# configCorrectionTemma
#  Affiche une ou deux echelles de reglage de la vitesse normale de correction
#  Commande du checkbutton "Correction AD et DEC liees"
#------------------------------------------------------------
proc ::temma::configCorrectionTemma { } {
   variable private
   global conf caption

   if {[info exists private(frm)] ==0} {return}

   set frm $private(frm)

   if { $private(liaison) != "1" } {

      pack $frm.correc_variantDec -in $frm.frame5 -side top -padx 10

      $frm.lab3 configure -pady 20
      $frm.lab4 configure -pady 20

      #--  Bindings
      bind $frm.correc_variantDec <ButtonRelease-1> {::temma::setCorrectionSpeed}

      #--- Pas de liaison des corrections en AD et en Dec.
      set private(correc_Dec) $conf(temma,correc_Dec)

   } else {

      pack forget $frm.correc_variantDec
      bind $frm.correc_variantDec <ButtonRelease-1> {}

      $frm.lab3 configure -pady 7
      $frm.lab4 configure -pady 7

      #--- Liaison des corrections en AD et en Dec.
      set private(correc_Dec) $private(correc_AD)

   }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
# setCorrectionSpeed
#  Modifie les reglages de vitesse de correction lente durant la connexion
#  Commande des echelles de reglages
#------------------------------------------------------------
proc ::temma::setCorrectionSpeed { args } {
   variable private
   global audace conf

   set conf(temma,correc_AD) $private(correc_AD)
   #--   correc_DEC = correc_AD si liaison
   if { $private(liaison) == "1" } {
      set private(correc_Dec) $private(correc_AD)
   }
   set conf(temma,correc_DEC) $private(correc_Dec)

   set telNo $audace(telNo)
   if {$telNo != 0} {
      tel$telNo correctionspeed $conf(temma,correc_AD) $conf(temma,correc_Dec)
   }
}

#------------------------------------------------------------
# getGuidingSpeed
#   Retourne les vitesses de correction theoriques
#   (en arseconde par seconde de temps)
#------------------------------------------------------------
proc ::temma::getGuidingSpeed { } {
   variable private

   set vitesse_siderale 15 ; #-- vitesse siderale en deg/heure ou en arsec/seconde de temps
   if {$private(correc_AD) < 10} {
      set coefAD "1"
   } elseif {$private(correc_AD) > 90} {
      set coefAD "100"
   } else {
      set coefAD "$private(correc_AD)"
   }
   set gsAD [expr { $vitesse_siderale*$coefAD/100. }]

   if {$private(correc_Dec) < 10} {
      set coefDec 1
   } elseif {$private(correc_Dec) > 90} {
      set coefDec 100
   } else {
      set coefDec $private(correc_Dec)
   }

   set gsDec [expr { $vitesse_siderale*$coefDec/100. }]

   return [list $gsAD $gsDec]
}

#------------------------------------------------------------
# computeSpeed
#    Edite les corections et les vitesses de correction reelles
#    (en arseconde par seconde de temps) dans la console
# Parametres : radec initial, radecfinal, durees de corrections en ms
#------------------------------------------------------------
proc ::temma::computeSpeed { radec0 radec1 alphaDelay deltaDelay } {

   lassign $radec0 ra0 dec0
   set ra0 [ mc_angle2deg $ra0 360 ]
   set dec0 [ mc_angle2deg $dec0 90 ]
   lassign $radec1 ra1 dec1
   set ra1 [ mc_angle2deg $ra1 360 ]
   set dec1 [ mc_angle2deg $dec1 90 ]
   set dra [expr { ($ra1-$ra0)*3600. }]
   set ddec [expr { ($dec1-$dec0)*3600. }]
   set raSpeed [expr { $dra*1000/$alphaDelay }]
   set decSpeed [expr { $ddec*1000/$deltaDelay }]
   set dra [format "%0.2f" $dra] ; #--   arcsec
   set ddec [format "%0.2f" $ddec] ; #--   arcsec
   set raSpeed [format "%0.2f" $raSpeed] ; #--   arcsec/sec
   set decSpeed [format "%0.2f" $decSpeed] ; #--   arcsec/sec

   ::console::disp "$dra arcsec $raSpeed arcsec/sec ; $ddec arcsec $decSpeed arcsec/sec\n"
   update
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
# isGermanMount           Retourne la possibilite d'etre une monture allemande
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
# guidingSpeed            Retourne la vitesse de correction AD et DEC en arcseconde par seconde de temps
#
proc ::temma::getPluginProperty { propertyName } {
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
      isGermanMount           { return 1 }
      hasCoordinates          { return 1 }
      hasGoto                 { return 1 }
      hasMatch                { return 1 }
      hasManualMotion         { return 1 }
      hasControlSuivi         {
         if { $::conf(temma,modele) == "2" } {
            return 1
         } else {
            return 0
         }
      }
      hasModel                { return 1 }
      hasMotionWhile          { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
      guidingSpeed            { return [::temma::getGuidingSpeed] }
   }
}

