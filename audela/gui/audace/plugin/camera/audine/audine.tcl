#
# Fichier : audine.tcl
# Description : Configuration de la camera Audine
# Auteur : Robert DELMAS
# Mise à jour $Id: audine.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::audine {
   package provide audine 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] audine.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::audine::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libaudine.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audine::getPluginType]] "audine" "libaudine.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libquicka.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audine::getPluginType]] "audine" "libquicka.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace liboscadine.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audine::getPluginType]] "audine" "liboscadine.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libethernaude.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audine::getPluginType]] "audine" "libethernaude.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace CCD_Driver.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audine::getPluginType]] "audine" "CCD_Driver.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(audine,installNewVersion) $sourceFileName [package version audine] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::audine::getPluginTitle { } {
   global caption

   return "$caption(audine,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::audine::getPluginHelp { } {
   return "audine.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::audine::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::audine::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::audine::getPluginDirectory { } {
   return "audine"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::audine::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::audine::isReady { camItem } {
   variable private

   if { $private($camItem,camNo) == "0" } {
      #--- Camera KO
      return 0
   } else {
      #--- Camera OK
      return 1
   }
}

#
# initPlugin
#    Initialise les variables conf(audine,...)
#
proc ::audine::initPlugin { } {
   variable private
   global audace caption conf

   #--- Charge les fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine obtu_pierre.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine testaudine.tcl ]\""

   #--- Initialise les variables de la camera Audine
   if { ! [ info exists conf(audine,ampli_ccd) ] } { set conf(audine,ampli_ccd) "1" }
   if { ! [ info exists conf(audine,can) ] }       { set conf(audine,can)       "$caption(audine,can_ad976a)" }
   if { ! [ info exists conf(audine,ccd) ] }       { set conf(audine,ccd)       "$caption(audine,kaf400)" }
   if { ! [ info exists conf(audine,foncobtu) ] }  { set conf(audine,foncobtu)  "2" }
   if { ! [ info exists conf(audine,mirh) ] }      { set conf(audine,mirh)      "0" }
   if { ! [ info exists conf(audine,mirv) ] }      { set conf(audine,mirv)      "0" }
   if { ! [ info exists conf(audine,port) ] }      { set conf(audine,port)      "LPT1:" }
   if { ! [ info exists conf(audine,typeobtu) ] }  { set conf(audine,typeobtu)  "$caption(audine,obtu_audine)" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::audine::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Audine dans le tableau private(...)
   set private(ampli_ccd) [ lindex "$caption(audine,ampli_synchro) $caption(audine,ampli_toujours)" $conf(audine,ampli_ccd) ]
   set private(can)       $conf(audine,can)
   set private(ccd)       $conf(audine,ccd)
   set private(foncobtu)  [ lindex "$caption(audine,obtu_ouvert) $caption(audine,obtu_ferme) $caption(audine,obtu_synchro)" $conf(audine,foncobtu) ]
   set private(mirh)      $conf(audine,mirh)
   set private(mirv)      $conf(audine,mirv)
   set private(port)      $conf(audine,port)
   set private(typeobtu)  $conf(audine,typeobtu)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::audine::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Audine dans le tableau conf(audine,...)
   set conf(audine,ampli_ccd)            [ lsearch "$caption(audine,ampli_synchro) $caption(audine,ampli_toujours)" "$private(ampli_ccd)" ]
   set conf(audine,can)                  $private(can)
   set conf(audine,ccd)                  $private(ccd)
   set conf(audine,foncobtu)             [ lsearch "$caption(audine,obtu_ouvert) $caption(audine,obtu_ferme) $caption(audine,obtu_synchro)" "$private(foncobtu)" ]
   set conf(audine,mirh)                 $private(mirh)
   set conf(audine,mirv)                 $private(mirv)
   set conf(audine,port)                 $private(port)
   set conf(audine,typeobtu)             $private(typeobtu)
}

#
# fillConfigPage
#    Interface de configuration de la camera Audine
#
proc ::audine::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::audine::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Je constitue la liste des liaisons pour l'acquisition des images
   set list_combobox [ ::confLink::getLinkLabels { "parallelport" "quickaudine" "oscadine" "ethernaude" } ]

   #--- Je verifie le contenu de la liste
   if { [ llength $list_combobox ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [lsearch -exact $list_combobox $::audine::private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set ::audine::private(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame de la configuration du port, du format du CCD, du miroir en x et en y, de l'ampli du CCD et du modele du CAN
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame de la configuration du port et du format du CCD
      frame $frm.frame1.frame5 -borderwidth 0 -relief raised

         #--- Frame de la configuration du port
         frame $frm.frame1.frame5.frame10 -borderwidth 0 -relief raised

            #--- Definition du port
            label $frm.frame1.frame5.frame10.lab1 -text "$caption(audine,port_liaison)"
            pack $frm.frame1.frame5.frame10.lab1 -anchor center -side left -padx 10

            #--- Choix du port ou de la liaison
            ComboBox $frm.frame1.frame5.frame10.port \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::audine::private(port) \
               -values $list_combobox
            pack $frm.frame1.frame5.frame10.port -anchor center -side right -padx 10

            #--- Bouton de configuration des liaisons
            button $frm.frame1.frame5.frame10.configure -text "$caption(audine,configurer)" -relief raised \
               -command {
                  ::confLink::run ::audine::private(port) \
                     { "parallelport" "quickaudine" "oscadine" "ethernaude" } \
                     "- $caption(audine,acquisition) - $caption(audine,camera)"
               }
            pack $frm.frame1.frame5.frame10.configure -side right -pady 10 -ipadx 10 -ipady 1 -expand true

         pack $frm.frame1.frame5.frame10 -side top -fill both -expand 1

         #--- Frame du choix du format du CCD
         frame $frm.frame1.frame5.frame11 -borderwidth 0 -relief raised

            #--- Definition du format du CCD
            label $frm.frame1.frame5.frame11.lab2 -text "$caption(audine,format_ccd)"
            pack $frm.frame1.frame5.frame11.lab2 -anchor center -side left -padx 10

            set list_combobox [ list $caption(audine,kaf400) $caption(audine,kaf1600) $caption(audine,kaf3200) ]
            ComboBox $frm.frame1.frame5.frame11.ccd \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::audine::private(ccd) \
               -values $list_combobox
            pack $frm.frame1.frame5.frame11.ccd -anchor center -side right -padx 10

         pack $frm.frame1.frame5.frame11 -side top -fill both -expand 1

      pack $frm.frame1.frame5 -side left -fill both -expand 1

      #--- Frame du miroir en x et en y
      frame $frm.frame1.frame6 -borderwidth 0 -relief raised

         #--- Frame du miroir en x
         frame $frm.frame1.frame6.frame12 -borderwidth 0 -relief raised

            checkbutton $frm.frame1.frame6.frame12.mirx -text "$caption(audine,miroir_x)" -highlightthickness 0 \
               -variable ::audine::private(mirh)
            pack $frm.frame1.frame6.frame12.mirx -anchor center -side left -padx 20

         pack $frm.frame1.frame6.frame12 -side top -fill both -expand 1

         #--- Frame du miroir en y
         frame $frm.frame1.frame6.frame13 -borderwidth 0 -relief raised

            checkbutton $frm.frame1.frame6.frame13.miry -text "$caption(audine,miroir_y)" -highlightthickness 0 \
               -variable ::audine::private(mirv)
            pack $frm.frame1.frame6.frame13.miry -anchor center -side left -padx 20

         pack $frm.frame1.frame6.frame13 -side top -fill both -expand 1

      pack $frm.frame1.frame6 -side left -fill both -expand 1

      #--- Frame du fonctionnement de l'ampli du CCD et du modele du CAN
      frame $frm.frame1.frame7 -borderwidth 0 -relief raised

         #--- Frame du fonctionnement de l'ampli du CCD
         frame $frm.frame1.frame7.frame14 -borderwidth 0 -relief raised

            #--- Fonctionnement de l'ampli du CCD
            label $frm.frame1.frame7.frame14.lab3 -text "$caption(audine,ampli_ccd)"
            pack $frm.frame1.frame7.frame14.lab3 -anchor center -side left -padx 10

            set list_combobox [ list $caption(audine,ampli_synchro) $caption(audine,ampli_toujours) ]
            ComboBox $frm.frame1.frame7.frame14.ampli_ccd \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::audine::private(ampli_ccd) \
               -values $list_combobox
             pack $frm.frame1.frame7.frame14.ampli_ccd -anchor center -side right -padx 10

         pack $frm.frame1.frame7.frame14 -side top -fill both -expand 1

         #--- Frame du modele du CAN
         frame $frm.frame1.frame7.frame15 -borderwidth 0 -relief raised

            #--- Choix du modele du CAN
            label $frm.frame1.frame7.frame15.lab4 -text "$caption(audine,modele_can)"
            pack $frm.frame1.frame7.frame15.lab4 -anchor center -side left -padx 10

            set list_combobox [ list $caption(audine,can_ad976a) $caption(audine,can_ltc1605) ]
            ComboBox $frm.frame1.frame7.frame15.can \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::audine::private(can) \
               -values $list_combobox
            pack $frm.frame1.frame7.frame15.can -anchor center -side right -padx 10

         pack $frm.frame1.frame7.frame15 -side top -fill both -expand 1

      pack $frm.frame1.frame7 -side left -fill both -expand 1

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du type et du fonctionnement de l'obturateur, et frame vide (intercalaire)
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Frame du type et du fonctionnement de l'obturateur
      frame $frm.frame2.frame8 -borderwidth 0 -relief raised

         #--- Frame du type d'obturateur
         frame $frm.frame2.frame8.frame16 -borderwidth 0 -relief raised

            #--- Definition du type d'obturateur
            label $frm.frame2.frame8.frame16.lab5 -text "$caption(audine,type_obtu)"
            pack $frm.frame2.frame8.frame16.lab5 -anchor center -side left -padx 10

            set list_combobox [ list $caption(audine,obtu_audine) $caption(audine,obtu_audine-) \
               $caption(audine,obtu_i2c) $caption(audine,obtu_thierry) ]
            ComboBox $frm.frame2.frame8.frame16.typeobtu \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::audine::private(typeobtu) \
               -values $list_combobox
            pack $frm.frame2.frame8.frame16.typeobtu -anchor center -side right -padx 10

         pack $frm.frame2.frame8.frame16 -side top -fill both -expand 1

         #--- Frame du fonctionnement de l'obturateur
         frame $frm.frame2.frame8.frame17 -borderwidth 0 -relief raised

            #--- Fonctionnement de l'obturateur
            label $frm.frame2.frame8.frame17.lab6 -text "$caption(audine,fonc_obtu)"
            pack $frm.frame2.frame8.frame17.lab6 -anchor center -side left -padx 10

            set list_combobox [ list $caption(audine,obtu_ouvert) $caption(audine,obtu_ferme) $caption(audine,obtu_synchro) ]
            set ::audine::private(list_foncobtu) $list_combobox
            ComboBox $frm.frame2.frame8.frame17.foncobtu \
               -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
               -height [ llength $list_combobox ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::audine::private(foncobtu) \
               -values $list_combobox
            pack $frm.frame2.frame8.frame17.foncobtu -anchor center -side right -padx 10

         pack $frm.frame2.frame8.frame17 -side top -fill both -expand 1

      pack $frm.frame2.frame8 -side left -fill both -expand 1

      #--- Frame vide (intercaliare)
      frame $frm.frame2.frame9 -borderwidth 0 -relief raised
      pack $frm.frame2.frame9 -side left -fill both -expand 1 -padx 80

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame du bouton de test d'une Audine en fabrication
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Bouton de test d'une Audine en fabrication
      button $frm.frame3.test -text "$caption(audine,test_fab_audine)" -relief raised
      pack $frm.frame3.test -side top -pady 10 -ipadx 10 -ipady 5 -expand true

   pack $frm.frame3 -side top -fill x

   #--- Frame du site web officiel de l'Audine
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(audine,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(audine,site_web_ref)" \
         "$caption(audine,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion du bouton actif/inactif
   ::audine::confAudine $camItem

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera Audine en fonction des donnees contenues dans les variables conf(audine,...)
#
proc ::audine::configureCamera { camItem bufNo } {
   variable private
   global audace caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je configure le CCCD
      if { [ string range $conf(audine,ccd) 0 4 ] == "kaf16" } {
         set ccd "kaf1602"
      } elseif { [ string range $conf(audine,ccd) 0 4 ] == "kaf32" } {
         set ccd "kaf3200"
      } else {
         set ccd "kaf401"
      }
      #--- Je cree la camera en fonction de la liaison choisie
      switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
         parallelport {
            #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
            set linkNo [ ::confLink::create $conf(audine,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
            #--- Je cree la camera
            if { [ catch { set camNo [ cam::create audine $conf(audine,port) \
                                          -log_file [::confCam::getLogFileName $camItem] \
                                          -log_level [::confCam::getLogLevel $camItem] \
                                          -name Audine -ccd $ccd ] } catchError ] == 1 } {
               if { [ string first "sufficient privileges to access parallel port" $catchError ] != -1 } {
                  error "" "" "NotRoot"
               } else {
                  error $catchError
               }
            }
            #--- Je configure le nom du CAN utilise
            cam$camNo cantype $conf(audine,can)
         }
         quickaudine {
            #--- Je cree la camera
            set camNo [ cam::create quicka $conf(audine,port) \
               -log_file [::confCam::getLogFileName $camItem] \
               -log_level [::confCam::getLogLevel $camItem] \
               -name Audine -ccd $ccd \
            ]
            #--- Je configure le delai avant la lecture du CCD
            cam$camNo delayshutter $conf(quickaudine,delayshutter)
            #--- Je configure la vitesse de lecture de chaque pixel
            cam$camNo speed $conf(quickaudine,canspeed)
            #--- Je cree la liaison utilisee par la camera pour l'acquisition
            set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "" ]
         }
         oscadine {
            #--- Je cree la camera
            set camNo [ cam::create oscadine $conf(audine,port) \
               -log_file [::confCam::getLogFileName $camItem] \
               -log_level [::confCam::getLogLevel $camItem] \
               -name Audine \
               -ccd $ccd \
               -ledsettings $conf(oscadine,ledsettings) \
               -overscansettings $conf(oscadine,overscansettings) \
            ]
            #--- Je cree la liaison utilisee par la camera pour l'acquisition
            # set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "" ]
         }
         ethernaude {
            #--- Je verifie si la camera 500 du tutorial EthernAude est connectee, si oui je la deconnecte
            foreach camera [ ::cam::list ] {
               if { $camera == "500" } {
                  tuto_exit
               }
            }
            #--- Je configure la vitesse de lecture de chaque pixel
            set eth_canspeed "0"
            set eth_canspeed [ expr round(($conf(ethernaude,canspeed)-7.11)/(39.51-7.11)*30.) ]
            if { $eth_canspeed < "0" } { set eth_canspeed "0" }
            if { $eth_canspeed > "100" } { set eth_canspeed "100" }
            #--- Je parametre le type de l'obturateur
            if { [ string range $conf(audine,typeobtu) 0 5 ] == "audine" } {
               #--- L'EthernAude inverse le fonctionnement de l'obturateur par rapport au
               #--- port parallele, on retablit donc ici un fonctionnement identique
               if { [ string index $conf(audine,typeobtu) 7 ] == "-" } {
                  set shutterinvert "0"
               } else {
                  set shutterinvert "1"
               }
            }
            #--- Je gere le mode debug ou non de l'EthernAude
            if { $conf(ethernaude,debug) == "0" } {
               #--- Je cree la camera
               set camNo [ cam::create ethernaude $conf(audine,port) \
                  -ip $conf(ethernaude,host) \
                  -canspeed $eth_canspeed \
                  -name Audine \
                  -shutterinvert $shutterinvert \
                  -log_file [::confCam::getLogFileName $camItem] \
                  -log_level [::confCam::getLogLevel $camItem] \
               ]
            } else {
               #--- Je cree la camera
               set camNo [ cam::create ethernaude $conf(audine,port) \
                  -ip $conf(ethernaude,host) \
                  -canspeed $eth_canspeed \
                  -name Audine \
                  -shutterinvert $shutterinvert -debug_eth \
                  -log_file [::confCam::getLogFileName $camItem] \
                  -log_level [::confCam::getLogLevel $camItem] \
               ]
            }
            #--- Je cree la liaison utilisee par la camera pour l'acquisition
            set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "" ]
         }
         default {
            error "$conf(audine,port) driver not found."
         }
      }
      #--- J'affiche un message d'information dans la Console
      console::affiche_entete "$caption(audine,camera) ([ cam$camNo ccd ])\n"
      console::affiche_entete "$caption(audine,port_liaison)\
         ([ ::[ ::confLink::getLinkNamespace $conf(audine,port) ]::getPluginTitle ])\
         $caption(audine,2points) $conf(audine,port)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(audine,mirh)
      cam$camNo mirrorv $conf(audine,mirv)
      #--- Je parametre le mode de fonctionnement de l'obturateur
      switch -exact -- $conf(audine,foncobtu) {
         0 { cam$camNo shutter "opened" }
         1 { cam$camNo shutter "closed" }
         2 { cam$camNo shutter "synchro" }
      }
      #--- Je parametre le type de l'obturateur
      #--- (sauf pour l'EthernAude qui est commande par l'option -shutterinvert)
      if { [ ::confLink::getLinkNamespace $conf(audine,port) ] != "ethernaude" } {
         if { $conf(audine,typeobtu) == "$caption(audine,obtu_audine-)" } {
            cam$camNo shuttertype audine reverse
         } elseif { $conf(audine,typeobtu) == "$caption(audine,obtu_audine)" } {
            cam$camNo shuttertype audine
         } elseif { $conf(audine,typeobtu) == "$caption(audine,obtu_i2c)" } {
            cam$camNo shuttertype audine
         } elseif { $conf(audine,typeobtu) == "$caption(audine,obtu_thierry)" } {
            set ::confcolor(obtu_pierre) "1"
            ::Obtu_Pierre::run $camNo
            cam$camNo shuttertype thierry
        }
      }
      #--- Je parametre le fonctionnement de l'ampli du CCD
      #--- (uniquement pour le port parallele et la QuickAudine)
      if { [ ::confLink::getLinkNamespace $conf(audine,port) ] == "parallelport" } {
         switch -exact -- $conf(audine,ampli_ccd) {
            0 { cam$camNo ampli "synchro" }
            1 { cam$camNo ampli "on" }
            2 { cam$camNo ampli "off" }
         }
      } elseif { [ ::confLink::getLinkNamespace $conf(audine,port) ] == "quickaudine" } {
         switch -exact -- $conf(audine,ampli_ccd) {
            0 { cam$camNo ampli "synchro" }
            1 { cam$camNo ampli "on" }
            2 { cam$camNo ampli "off" }
         }
      }
      #--- Gestion du bouton actif/inactif
      ::audine::confAudine $camItem
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::audine::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera Audine
#
proc ::audine::stop { camItem } {
   variable private
   global audace conf

   #--- Gestion du bouton actif/inactif
   ::audine::confAudineInactif $camItem

   #--- Si la fenetre 'Test pour la fabrication de la camera' est affichee, je la ferme
   if { [ winfo exists $audace(base).testAudine ] } {
      ::testAudine::fermer
   }

   #--- Si la fenetre 'Alimentation AlAudine avec port I2C' est affichee, je la ferme
   if { [ winfo exists $audace(base).alimAlAudineNT ] } {
      ::AlAudineNT::fermer
   }

   #--- Si la fenetre 'Coordonnees GPS de l'observateur' est affichee, je la ferme
   if { [ winfo exists $audace(base).eventAudeGPS ] } {
      ::eventAudeGPS::fermer
   }

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(audine,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# confAudine
# Permet d'activer ou de desactiver le bouton Tests pour la fabrication de la camera Audine
#
proc ::audine::confAudine { camItem } {
   variable private
   global audace

   #--- Si la fenetre Test pour la fabrication de la camera est affichee, je la ferme
   if { [ winfo exists $audace(base).testAudine ] } {
      ::testAudine::fermer
   }

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::audine::isReady $camItem ] == 1 && \
            [ ::confLink::getLinkNamespace $::audine::private(port) ] == "parallelport" } {
            #--- Bouton Tests pour la fabrication de la camera actif
            $frm.frame3.test configure -state normal
            $frm.frame3.test configure -command "::testAudine::run $::audace(base).testAudine $camItem"
         } else {
            #--- Bouton Tests pour la fabrication de la camera inactif
            $frm.frame3.test configure -state disabled
         }
      }
   }
}

#
# confAudineInactif
#    Permet de desactiver le bouton a l'arret de la Audine
#
proc ::audine::confAudineInactif { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::audine::isReady $camItem ] == 1 && \
            [ ::confLink::getLinkNamespace $::audine::private(port) ] == "parallelport" } {
            #--- Bouton Tests pour la fabrication de la camera inactif
            $frm.frame3.test configure -state disabled
         }
      }
   }
}

#
# setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::audine::setTempCCD { camItem } {
   global conf

   if { ! [ info exists conf(alaudine_nt,temp_ccd_souhaite) ] } {
      ::AlAudineNT::initConf
   }
   return $conf(alaudine_nt,temp_ccd_souhaite)
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::audine::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(audine,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      0  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "opened"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(audine,obtu_ouvert)
      }
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(audine,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(audine,obtu_synchro)
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
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# dynamic :          Retourne la liste de la dynamique haute et basse
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasTempSensor      Retourne l'existence du capteur de temperature (1 : Oui, 0 : Non)
# hasSetTemp         Retourne l'existence d'une consigne de temperature (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::audine::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
            "quickaudine"  { return [ list 1x1 2x2 3x3 4x4 ] }
            "oscadine"     { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
            "ethernaude"   { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
         }
      }
      binningXListScan {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ] }
            "quickaudine"  { return [ list "" ] }
            "oscadine"     { return [ list "" ] }
            "ethernaude"   { return [ list 1 2 ] }
         }
      }
      binningYListScan {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ] }
            "quickaudine"  { return [ list "" ] }
            "oscadine"     { return [ list "" ] }
            "ethernaude"   { return [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 \
                                           15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 \
                                           35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 \
                                           55 56 57 58 59 60 61 62 63 64 ] }
         }
      }
      dynamic          { return [ list 32767 -32768 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return 1 }
            "quickaudine"  { return 0 }
            "oscadine"     { return 0 }
            "ethernaude"   { return 1 }
         }
      }
      hasShutter       { return 1 }
      hasTempSensor         {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "ethernaude" { return 1 }
            default      { return 0 }
         }
      }
      hasSetTemp            {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "ethernaude" { return 1 }
            default      { return 0 }
         }
      }
      hasVideo         {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "ethernaude" { return 2 }
            default      { return 0 }
         }
      }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      name             {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) name ]
         } else {
            return ""
         }
      }
      product          {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) product ]
         } else {
            return ""
         }
      }
      shutterList      {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" {
               #--- O + F + S
               return [ list $::caption(audine,obtu_ouvert) $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
            "quickaudine" {
               #--- F + S
               return [ list $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
            "oscadine" {
               #--- O + F + S
               return [ list $::caption(audine,obtu_ouvert) $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
            "ethernaude" {
               #--- F + S
               return [ list $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
         }
      }
   }
}

