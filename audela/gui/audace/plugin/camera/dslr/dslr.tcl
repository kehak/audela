#
# Fichier : dslr.tcl
# Description : Gestion du telechargement des images d'un APN (DSLR)
# Auteur : Robert DELMAS
# Mise à jour $Id: dslr.tcl 13629 2016-04-06 18:17:43Z robertdelmas $
#

namespace eval ::dslr {
   package provide dslr 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] dslr.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::dslr::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libdigicam.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libdigicam.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libgphoto2.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_canon.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libgphoto2_canon.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_port.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libgphoto2_port.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_port_ptpip.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libgphoto2_port_ptpip.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_port_usb.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libgphoto2_port_usb.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_ptp2.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "libgphoto2_ptp2.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace regex2.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::dslr::getPluginType]] "dslr" "regex2.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(dslr,installNewVersion) $sourceFileName [package version dslr] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::dslr::getPluginTitle { } {
   global caption

   return "$caption(dslr,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::dslr::getPluginHelp { } {
   return "dslr.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::dslr::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::dslr::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::dslr::getPluginDirectory { } {
   return "dslr"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::dslr::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::dslr::isReady { camItem } {
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
#    Initialise les variables conf(dslr,...)
#
proc ::dslr::initPlugin { } {
   variable private
   global conf

   #--- Initialise les variables de la camera APN (DSLR)
   ###if { ! [ info exists conf(dslr,liaison) ] }              { set conf(dslr,liaison)              "gphoto2" }
   if { ! [ info exists conf(dslr,longuepose) ] }           { set conf(dslr,longuepose)           "0" }
   if { ! [ info exists conf(dslr,longueposeport) ] }       { set conf(dslr,longueposeport)       "LPT1:" }
   if { ! [ info exists conf(dslr,longueposelinkbit) ] }    { set conf(dslr,longueposelinkbit)    "0" }
   if { ! [ info exists conf(dslr,longueposestartvalue) ] } { set conf(dslr,longueposestartvalue) "1" }
   if { ! [ info exists conf(dslr,longueposestopvalue) ] }  { set conf(dslr,longueposestopvalue)  "0" }
   if { ! [ info exists conf(dslr,statut_service) ] }       { set conf(dslr,statut_service)       "1" }
   if { ! [ info exists conf(dslr,mirh) ] }                 { set conf(dslr,mirh)                 "0" }
   if { ! [ info exists conf(dslr,mirv) ] }                 { set conf(dslr,mirv)                 "0" }
   ###if { ! [ info exists conf(dslr,telecharge_mode) ] }      { set conf(dslr,telecharge_mode)      "2" }
   ###if { ! [ info exists conf(dslr,utiliser_cf) ] }          { set conf(dslr,utiliser_cf)          "1" }
   if { ! [ info exists conf(dslr,supprimer_image) ] }      { set conf(dslr,supprimer_image)      "0" }
   ###if { ! [ info exists conf(dslr,debug) ] }                { set conf(dslr,debug)                "1" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::dslr::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera APN (DSLR) dans le tableau private(...)
   ###set private(liaison)              $conf(dslr,liaison)
   set private(longuepose)           $conf(dslr,longuepose)
   set private(longueposeport)       $conf(dslr,longueposeport)
   set private(longueposelinkbit)    $conf(dslr,longueposelinkbit)
   set private(longueposestartvalue) $conf(dslr,longueposestartvalue)
   set private(longueposestopvalue)  $conf(dslr,longueposestopvalue)
   set private(statut_service)       $conf(dslr,statut_service)
   set private(mirh)                 $conf(dslr,mirh)
   set private(mirv)                 $conf(dslr,mirv)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::dslr::widgetToConf { camItem } {
   variable private
   global conf

   #--- Memorise la configuration de la camera APN (DSLR) dans le tableau conf(dslr,...)
   ###set conf(dslr,liaison)              $private(liaison)
   set conf(dslr,longuepose)           $private(longuepose)
   set conf(dslr,longueposeport)       $private(longueposeport)
   set conf(dslr,longueposelinkbit)    $private(longueposelinkbit)
   set conf(dslr,longueposestartvalue) $private(longueposestartvalue)
   set conf(dslr,longueposestopvalue)  [ expr { 1- $private(longueposestartvalue) } ]
   set conf(dslr,statut_service)       $private(statut_service)
   set conf(dslr,mirh)                 $private(mirh)
   set conf(dslr,mirv)                 $private(mirv)
}

#
# fillConfigPage
#    Interface de configuration de la camera APN (DSLR)
#
proc ::dslr::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::dslr::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   ####--- Je constitue la liste des liaisons pour les APN
   ###set list_combobox1 [ ::confLink::getLinkLabels { "gphoto2" } ]
   ###
   ####--- Je verifie le contenu de la liste
   ###if { [ llength $list_combobox1 ] > 0 } {
   ###   #--- si la liste n'est pas vide,
   ###   #--- je verifie que la valeur par defaut existe dans la liste
   ###   if { [lsearch -exact $list_combobox1 $::dslr::private(liaison) ] == -1 } {
   ###      #--- si la valeur par defaut n'existe pas dans la liste,
   ###      #--- je la remplace par le premier item de la liste
   ###      set ::dslr::private(liaison) [lindex $list_combobox1 0]
   ###   }
   ###} else {
   ###   #--- si la liste est vide, on continue quand meme
   ###}

   #--- Je constitue la liste des liaisons pour la longuepose
   set list_combobox2 [ ::confLink::getLinkLabels { "parallelport" "quickremote" "serialport" "external" } ]

   #--- Je verifie le contenu de la liste
   if { [ llength $list_combobox2 ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox2 $::dslr::private(longueposeport) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set ::dslr::private(longueposeport) [lindex $list_combobox2 0]
      }
   } else {
      #--- Si la liste est vide
      #--- Je desactive l'option longue pose
      set ::dslr::private(longueposeport) ""
      set ::dslr::private(longuepose) 0
      #--- J'empeche de selectionner l'option longue pose
      $frm.longuepose configure -state disable
   }

   #--- Frame des miroirs en x et en y et de la configuration de la longue pose
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame de la configuration de la liaison et des miroirs en x et en y
      frame $frm.frame1.frame6 -borderwidth 0 -relief raised

         ####--- Frame de la configuration de la liaison
         ###frame $frm.frame1.frame6.frame13 -borderwidth 0 -relief raised
         ###
         ###   #--- Definition de la liaison
         ###   label $frm.frame1.frame6.frame13.lab1 -text "$caption(dslr,liaison)"
         ###   pack $frm.frame1.frame6.frame13.lab1 -anchor center -side left -padx 10
         ###
         ###   #--- Choix de la liaison
         ###   ComboBox $frm.frame1.frame6.frame13.port \
         ###      -width [ ::tkutil::lgEntryComboBox $list_combobox1 ] \
         ###      -height [ llength $list_combobox1 ] \
         ###      -relief sunken \
         ###      -borderwidth 1 \
         ###      -editable 0    \
         ###      -textvariable ::dslr::private(liaison) \
         ###      -values $list_combobox1
         ###   pack $frm.frame1.frame6.frame13.port -anchor center -side right -padx 10
         ###
         ###   #--- Bouton de configuration de la liaison
         ###   button $frm.frame1.frame6.frame13.configure -text "$caption(dslr,configurer)" -relief raised \
         ###      -command {
         ###         ::confLink::run ::dslr::private(liaison) { "gphoto2" } ""
         ###      }
         ###   pack $frm.frame1.frame6.frame13.configure -side right -pady 10 -ipadx 10 -ipady 1 -expand true
         ###
         ###pack $frm.frame1.frame6.frame13 -side top -fill both -expand 1

         #--- Miroir en x et en y
         checkbutton $frm.frame1.frame6.mirx -text "$caption(dslr,miroir_x)" -highlightthickness 0 \
            -variable ::dslr::private(mirh)
         pack $frm.frame1.frame6.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame6.miry -text "$caption(dslr,miroir_y)" -highlightthickness 0 \
            -variable ::dslr::private(mirv)
         pack $frm.frame1.frame6.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame6 -anchor n -side left -fill x

      #--- Frame de la configuration de la longue pose
      frame $frm.frame1.frame7 -borderwidth 1 -relief solid

         #--- Frame de la configuration de la longue pose
         frame $frm.frame1.frame7.frame8 -borderwidth 0 -relief raised

            #--- Selection de la longue pose
            checkbutton $frm.frame1.frame7.frame8.longuepose -text "$caption(dslr,longuepose)" -highlightthickness 0 \
               -variable ::dslr::private(longuepose) -command "::dslr::confDSLR $camItem"
            pack $frm.frame1.frame7.frame8.longuepose -anchor w -side left -padx 10 -pady 10

            #--- Bouton de configuration des ports et liaisons
            button $frm.frame1.frame7.frame8.configure_longuepose -text "$caption(dslr,configurer)" -relief raised \
               -command {
                  ::dslr::configureAPNLinkLonguePose
                  ::confLink::run ::dslr::private(longueposeport) { parallelport quickremote serialport external } \
                     "- $caption(dslr,longuepose) - $caption(dslr,camera)"
               }
            pack $frm.frame1.frame7.frame8.configure_longuepose -side left -pady 10 -ipadx 10 -ipady 1

            #--- Choix du port ou de la liaison
            ComboBox $frm.frame1.frame7.frame8.moyen_longuepose \
               -width [ ::tkutil::lgEntryComboBox $list_combobox2 ] \
               -height [ llength $list_combobox2 ] \
               -relief sunken \
               -borderwidth 1 \
               -editable 0    \
               -textvariable ::dslr::private(longueposeport) \
               -values $list_combobox2 \
               -modifycmd {
                  ::dslr::configureAPNLinkLonguePose
               }
            pack $frm.frame1.frame7.frame8.moyen_longuepose -anchor center -side left -padx 20

         pack $frm.frame1.frame7.frame8 -anchor n -side top -fill x

         #--- Frame pour le choix du numero du bit pour la commande de la longue pose
         frame $frm.frame1.frame7.frame9 -borderwidth 0 -relief raised

            #--- Choix du numero du bit pour la commande de la longue pose
            label $frm.frame1.frame7.frame9.lab4 -text "$caption(dslr,longueposebit)"
            pack $frm.frame1.frame7.frame9.lab4 -anchor center -side left -padx 3 -pady 5

            set bitList [ ::confLink::getPluginProperty $private(longueposeport) "bitList" ]
            ComboBox $frm.frame1.frame7.frame9.longueposelinkbit \
               -width [ ::tkutil::lgEntryComboBox $bitList ] \
               -height [ llength $bitList ] \
               -relief sunken \
               -borderwidth 1 \
               -textvariable ::dslr::private(longueposelinkbit) \
               -editable 0    \
               -values $bitList
            if { [lsearch $bitList $private(longueposelinkbit)] == -1 } {
               #--- si le bit n'existe pas dans la liste, je selectionne le premier element de la liste
               set private(longueposelinkbit) [lindex $bitList 0 ]
            }

            pack $frm.frame1.frame7.frame9.longueposelinkbit -anchor center -side right -padx 20 -pady 5

         pack $frm.frame1.frame7.frame9 -anchor n -side top -fill x

         #--- Frame pour le choix du niveau de depart pour la commande de la longue pose
         frame $frm.frame1.frame7.frame10 -borderwidth 0 -relief raised

            #--- Choix du niveau de depart pour la commande de la longue pose
            label $frm.frame1.frame7.frame10.lab5 -text "$caption(dslr,longueposestart)"
            pack $frm.frame1.frame7.frame10.lab5 -anchor center -side left -padx 3 -pady 5

            entry $frm.frame1.frame7.frame10.longueposestartvalue -width 4 -textvariable ::dslr::private(longueposestartvalue) -justify center
            pack $frm.frame1.frame7.frame10.longueposestartvalue -anchor center -side right -padx 20 -pady 5

         pack $frm.frame1.frame7.frame10 -anchor n -side top -fill x

      pack $frm.frame1.frame7 -anchor n -side right -fill x

   pack $frm.frame1 -side top -fill x

   #--- Frame pour la gestion du Service Windows de detection automatique des APN (DSLR)
   frame $frm.frame4 -borderwidth 0 -relief raised

      #--- Frame pour la gestion du Service Windows de detection automatique des APN (DSLR)
      frame $frm.frame4.frame5 -borderwidth 0 -relief raised

         #--- Gestion du Service Windows de detection automatique des APN (DSLR)
         if { $::tcl_platform(platform) == "windows" } {
            checkbutton $frm.frame4.frame5.detect_service -text "$caption(dslr,detect_service)" -highlightthickness 0 \
               -variable ::dslr::private(statut_service)
            pack $frm.frame4.frame5.detect_service -anchor w -side top -padx 20 -pady 10
         }

      pack $frm.frame4.frame5 -anchor n -side top -fill x

   pack $frm.frame4 -side top -fill x

   ####--- Frame pour le choix du telechargement de l'image
   ###frame $frm.frame11 -borderwidth 0 -relief raised
   ###
   ###   #--- Bouton du choix du telechargement de l'image
   ###   button $frm.frame11.config_telechargement -text $caption(dslr,telecharger) -state normal \
   ###      -command " ::dslr::setLoadParameters $camItem"
   ###   pack $frm.frame11.config_telechargement -side top -pady 10 -ipadx 10 -ipady 5 -expand true
   ###
   ###pack $frm.frame11 -anchor n -side top -fill both -expand true

   #--- Frame du site web officiel de la CB245
   frame $frm.frame12 -borderwidth 0 -relief raised

      label $frm.frame12.lab104 -text "$caption(dslr,titre_site_web)"
      pack $frm.frame12.lab104 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame12 "$caption(dslr,site_web_ref)" \
         "$caption(dslr,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame12 -side bottom -fill x -pady 2

   #--- Gestion du bouton de telechargement actif/inactif
   ::dslr::confDSLR $camItem

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera APN (DSLR) en fonction des donnees contenues dans les variables conf(dslr,...)
#
proc ::dslr::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la liaison longue pose
      if { $conf(dslr,longuepose) == "1" } {
         set linkNo [ ::confLink::create $conf(dslr,longueposeport) "temp" "" "" ]
         link$linkNo bit $conf(dslr,longueposelinkbit) $conf(dslr,longueposestopvalue)
      }
      #--- Je mets audela_start_dir entre guillemets pour le cas ou le nom du repertoire contient des espaces
      #--- Je cree la camera
      set camNo [ cam::create digicam USB -name DSLR \
         -gphoto2_win_dll_dir $::audela_start_dir \
         -log_file [::confCam::getLogFileName $camItem] \
         -log_level [::confCam::getLogLevel $camItem]
      ]
      ::console::affiche_entete "$caption(dslr,name) $caption(dslr,2points) [ cam$camNo name ]\n"
      ::console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(dslr,mirh)
      cam$camNo mirrorv $conf(dslr,mirv)
      #--- J'arrete le service WIA de Windows
      cam$camNo systemservice 0
      #--- Je fais le parametrage des longues poses
      if { $conf(dslr,longuepose) == "1" } {
         switch [ ::confLink::getLinkNamespace $conf(dslr,longueposeport) ] {
            parallelport -
            serialport -
            quickremote {
               #--- Je cree la liaison longue pose
              ### set linkNo [ ::confLink::create $conf(dslr,longueposeport) "cam$camNo" "longuepose" "bit $conf(dslr,longueposelinkbit)" ]
               link$linkNo use remove "temp" ""
               link$linkNo use add "cam$camNo" "longuepose" "bit $conf(dslr,longueposelinkbit)"
               #---
               cam$camNo longuepose 1
               cam$camNo longueposelinkno $linkNo
               cam$camNo longueposelinkbit $conf(dslr,longueposelinkbit)
               cam$camNo longueposestartvalue $conf(dslr,longueposestartvalue)
               cam$camNo longueposestopvalue  $conf(dslr,longueposestopvalue)
            }
            external {
               cam$camNo longuepose 2
            }
            default {
               error "$conf(dslr,longueposeport) long exposure driver not found."
            }
         }
      } else {
         #--- Pas de liaison longue pose
         cam$camNo longuepose 0
      }
      ####--- Je fais le parametrage du telechargement des images
      ###set resultUsecf [ catch { cam$camNo usecf $conf(dslr,utiliser_cf) } messageUseCf ]
      ###if { $resultUsecf == 1 } {
      ###   #--- Si l'appareil n'a pas de carte memoire,
      ###   #--- je desactive l'utilisation de la carte memoire de l'appareil
      ###   ::console::affiche_entete "$messageUseCf.\nMemory card has been unset.\n\n"
      ###   set conf(dslr,utiliser_cf) 0
      ###   cam$camNo usecf $conf(dslr,utiliser_cf)
      ###}
      ###switch -exact -- $conf(dslr,telecharge_mode) {
      ###  1  {
      ###      #--- Ne pas telecharger
      ###      cam$camNo autoload 0
      ###   }
      ###   2  {
      ###      #--- Telechargement immediat
      ###      cam$camNo autoload 1
      ###   }
      ###   3  {
      ###      #--- Telechargement pendant la pose suivante
      ###      cam$camNo autoload 0
      ###   }
      ###}
      #--- Gestion du bouton de telechargement actif/inactif
      ::dslr::confDSLR $camItem
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::dslr::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera APN (DSLR)
#
proc ::dslr::stop { camItem } {
   variable private
   global audace conf

   #--- Gestion du bouton de telechargement actif/inactif
   ::dslr::confDSLRInactif $camItem

   #--- Si la fenetre Telechargement d'images est affichee, je la ferme
   if { [ winfo exists $audace(base).telecharge_image ] } {
      destroy $audace(base).telecharge_image
   }

   #--- Je ferme la liaison longuepose de la camera
   if { $conf(dslr,longuepose) == 1 } {
      ::confLink::delete $conf(dslr,longueposeport) "cam$private($camItem,camNo)" "longuepose"
   }

   if { $private($camItem,camNo) != 0 } {
      #--- Je restitue si necessaire l'etat du service WIA sous Windows
      if { $::tcl_platform(platform) == "windows" } {
          if { [ cam$private($camItem,camNo) systemservice ] != $conf(dslr,statut_service) } {
             cam$private($camItem,camNo) systemservice $conf(dslr,statut_service)
          }
      }

      #--- J'arrete la camera
      if { $private($camItem,camNo) != 0 } {
        cam::delete $private($camItem,camNo)
        set private($camItem,camNo) 0
      }
   }
}

#
# confDSLR
# Permet d'activer ou de desactiver le bouton de telechargement des images des APN (DSLR)
#
proc ::dslr::confDSLR { camItem } {
   variable private
   global audace

   #--- Si la fenetre Telecharger l'image pour la fabrication de la camera est affichee, je la ferme
   if { [ winfo exists $audace(base).telecharge_image ] } {
      destroy $audace(base).telecharge_image
   }

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      ###if { [ winfo exists $frm.frame11.config_telechargement ] } {
      ###   if { [ ::dslr::isReady $camItem ] == 1 } {
      ###      #--- Bouton de configuration de la camera APN (DSLR)
      ###      $frm.frame11.config_telechargement configure -state normal
      ###      $frm.frame11.config_telechargement configure -command "::dslr::setLoadParameters $camItem"
      ###      $frm.frame1.frame7.frame8.longuepose configure -command "::dslr::confDSLR $camItem"
      ###   } else {
      ###      #--- Bouton de configuration de la camera APN (DSLR)
      ###      $frm.frame11.config_telechargement configure -state disabled
      ###   }
      ###}
      if { $private(longuepose) == "1" } {
         #--- Widgets de configuration de la longue pose actifs
         $frm.frame1.frame7.frame8.configure_longuepose configure -state normal
         $frm.frame1.frame7.frame8.moyen_longuepose configure -state normal
         $frm.frame1.frame7.frame9.longueposelinkbit configure -state normal
         $frm.frame1.frame7.frame10.longueposestartvalue configure -state normal
      } else {
         #--- Widgets de configuration de la longue pose inactifs
         $frm.frame1.frame7.frame8.configure_longuepose configure -state disabled
         $frm.frame1.frame7.frame8.moyen_longuepose configure -state disabled
         $frm.frame1.frame7.frame9.longueposelinkbit configure -state disabled
         $frm.frame1.frame7.frame10.longueposestartvalue configure -state disabled
      }
   }
}

#
# confDSLRInactif
#    Permet de desactiver le bouton de telechargement des images a l'arret de la camera APN (DSLR)
#
proc ::dslr::confDSLRInactif { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::dslr::isReady $camItem ] == 1 } {
            #--- Bouton de configuration de la camera APN (DSLR)
            ###$frm.frame11.config_telechargement configure -state disabled
         }
      }
   }
}

#
# configureAPNLinkLonguePose
#    Positionne la liaison sur celle qui vient d'etre selectionnee pour
#    la longue pose de la camera APN (DSLR)
#
proc ::dslr::configureAPNLinkLonguePose { } {
   variable private

   set frm $private(frm)

   #--- je rafraichis la liste des bits disponibles pour la command de la longue pose
   set bitList [ ::confLink::getPluginProperty $private(longueposeport) "bitList" ]
   $frm.frame1.frame7.frame9.longueposelinkbit configure -values $bitList -height [ llength $bitList ] -width [::tkutil::lgEntryComboBox $bitList]
   if { [lsearch $bitList $private(longueposelinkbit)] == -1 } {
      #--- si le bit n'existe pas dans la liste, je selectionne le premier element de la liste
      set private(longueposelinkbit) [lindex $bitList 0 ]
   }

   #--- Je positionne startvalue par defaut en fonction du type de liaison
   switch [ ::confLink::getLinkNamespace $private(longueposeport) ] {
      "parallelport" {
         set private(longueposestartvalue) "0"
      }
      "quickremote" {
         set private(longueposestartvalue) "1"
      }
      "serialport" {
         set private(longueposestartvalue) "1"
      }
   }
}

####
#### setLoadParameters
####    Cree la boite de telechargement des images
####
###proc ::dslr::setLoadParameters { camItem } {
###   global audace caption conf
###
###   #---
###   if { [ winfo exists $audace(base).telecharge_image ] } {
###      wm withdraw $audace(base).telecharge_image
###      if { [ winfo exists $audace(base).confCam ] } {
###         wm deiconify $audace(base).confCam
###      }
###      wm deiconify $audace(base).telecharge_image
###      focus $audace(base).telecharge_image
###      return
###   }
###
###   #--- Creation de la fenetre
###   toplevel $audace(base).telecharge_image
###   wm resizable $audace(base).telecharge_image 0 0
###   wm title $audace(base).telecharge_image "$caption(dslr,telecharger)"
###   if { [ winfo exists $audace(base).confCam ] } {
###      wm deiconify $audace(base).confCam
###      wm transient $audace(base).telecharge_image $audace(base).confCam
###      set posx_telecharge_image [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 1 ]
###      set posy_telecharge_image [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 2 ]
###      wm geometry $audace(base).telecharge_image +[ expr $posx_telecharge_image + 300 ]+[ expr $posy_telecharge_image + 20 ]
###   } else {
###      wm transient $audace(base).telecharge_image $audace(base)
###      set posx_telecharge_image [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
###      set posy_telecharge_image [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
###      wm geometry $audace(base).telecharge_image +[ expr $posx_telecharge_image + 150 ]+[ expr $posy_telecharge_image + 90 ]
###   }
###
###   ####--- utilise carte memoire CF
###   ###checkbutton $audace(base).telecharge_image.utiliserCF -text "$caption(dslr,utiliser_cf)" \
###   ###   -highlightthickness 0 -variable conf(dslr,utiliser_cf) \
###   ###   -command "::dslr::utiliserCF $camItem"
###   ###pack $audace(base).telecharge_image.utiliserCF -anchor w -side top -padx 20 -pady 10
###
###   ###radiobutton $audace(base).telecharge_image.rad1 -anchor nw -highlightthickness 1 \
###   ###  -padx 0 -pady 0 -state normal \
###   ###  -text "$caption(dslr,pas_telecharger)" -value 1 -variable conf(dslr,telecharge_mode) \
###   ###  -command "::dslr::changerSelectionTelechargementAPN $camItem"
###   ###pack $audace(base).telecharge_image.rad1 -anchor w -expand 1 -fill none \
###   ###  -side top -padx 30 -pady 5
###   ###radiobutton $audace(base).telecharge_image.rad2 -anchor nw -highlightthickness 0 \
###   ###  -padx 0 -pady 0 -state normal \
###   ###  -text "$caption(dslr,immediat)" -value 2 -variable conf(dslr,telecharge_mode)\
###   ###  -command "::dslr::changerSelectionTelechargementAPN $camItem"
###   ###pack $audace(base).telecharge_image.rad2 -anchor w -expand 1 -fill none \
###   ###  -side top -padx 30 -pady 5
###   ###radiobutton $audace(base).telecharge_image.rad3 -anchor nw -highlightthickness 0 \
###   ###  -padx 0 -pady 0 -state normal -disabledforeground #999999 \
###   ###  -text "$caption(dslr,acq_suivante)" -value 3 -variable conf(dslr,telecharge_mode) \
###   ###  -command "::dslr::changerSelectionTelechargementAPN $camItem"
###   ###pack $audace(base).telecharge_image.rad3 -anchor w -expand 1 -fill none \
###   ###   -side top -padx 30 -pady 5
###
###   #--- supprime l'image sur la carte memoire apres le chargement
###   checkbutton $audace(base).telecharge_image.supprime_image -text "$caption(dslr,supprimer_image)" \
###      -highlightthickness 0 -variable conf(dslr,supprimer_image) \
###      -command "::dslr::supprimerImage $camItem"
###   pack $audace(base).telecharge_image.supprime_image -anchor w -side top -padx 20 -pady 10
###
###   #--- New message window is on
###   focus $audace(base).telecharge_image
###
###   #--- Mise a jour dynamique des couleurs
###   ::confColor::applyColor $audace(base).telecharge_image
###
###   #--- Mise a jour des radio boutons en fonction des parametres deja choisis
###   ::dslr::utiliserCF $camItem
###}

####
#### utiliserCF
####    Utilise la carte memoire CF
####
###proc ::dslr::utiliserCF { camItem } {
###   global audace conf
###   variable private
###
###   #--- je configure la camera
###   set camNo $private($camItem,camNo)
###   set resultUsecf [ catch { cam$camNo usecf $conf(dslr,utiliser_cf) } messageUseCf ]
###   if { $resultUsecf == 1 } {
###      tk_messageBox -message "$messageUseCf" -icon error
###      #--- si l'appareil n'a pas de carte memoire
###      #--- je change l'option carte memoire pour l'appareil
###      set conf(dslr,utiliser_cf) 0
###      cam$camNo usecf $conf(dslr,utiliser_cf)
###   }
###
###   #--- je mets a jour les widgets
###   if { $conf(dslr,utiliser_cf) == "0" } {
###      $audace(base).telecharge_image.rad1 configure -state disabled
###      $audace(base).telecharge_image.rad3 configure -state disabled
###      $audace(base).telecharge_image.supprime_image configure -state disabled
###      if { $conf(dslr,telecharge_mode) != "2" } {
###         #--- j'annule les modes 1 et 3 car il n'est pas possible sans CF
###         set conf(dslr,telecharge_mode) "2"
###      }
###   } else {
###      $audace(base).telecharge_image.rad1 configure -state normal
###      $audace(base).telecharge_image.rad3 configure -state normal
###      $audace(base).telecharge_image.supprime_image configure -state normal
###   }
###}

#
# supprimerImage
#    transmet la valeur de l'indicateur $conf(dslr,supprimer_image) a la
#    librairie libdigicam.dll afin d'indiquer si l'image doit etre supprimee
#    lors des acquisitions suivantes
# @private
proc ::dslr::supprimerImage { camItem } {
   global conf
   variable private

   cam$private($camItem,camNo) delete $conf(dslr,supprimer_image)
}

####
#### changerSelectionTelechargementAPN
####    Change le mode de telechargement
####
###proc ::dslr::changerSelectionTelechargementAPN { camItem } {
###   global conf
###   variable private
###
###   switch -exact -- $conf(dslr,telecharge_mode) {
###      1 {
###         #--- Ne pas telecharger
###         cam$private($camItem,camNo)  autoload 0
###      }
###      2 {
###         #--- Telechargement immediat
###         cam$private($camItem,camNo)  autoload 1
###      }
###      3 {
###         #--- Telechargement pendant la pose suivante
###         cam$private($camItem,camNo)  autoload 0
###      }
###   }
###   ::console::disp "conf(dslr,telecharge_mode) = $conf(dslr,telecharge_mode) --> cam$private($camItem,camNo) autoload = [ cam$private($camItem,camNo)  autoload ] \n"
###   ::console::affiche_saut "\n"
###}

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
# formatList :       Retourne la liste des formats ou des qualites d'image (fine, normal, raw, ...)
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasQuality :       Retourne l'existence d'une qualite (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasTempSensor      Retourne l'existence du capteur de temperature (1 : Oui, 0 : Non)
# hasSetTemp         Retourne l'existence d'une consigne de temperature (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# loadMode :         Retourne le mode de chargement d'une image (1: pas de chargment, 2:chargement immediat, 3: chargement differe)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
# rawExtension :     Retourne les extensions des images RAW de la camera
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::dslr::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list "" ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 4096 0 ] }
      formatList       {
         return [ cam$private($camItem,camNo) quality list ]
      }
      hasBinning       { return 0 }
      hasFormat        { return 1 }
      hasLongExposure  { return 1 }
      hasQuality       { return 1 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasTempSensor    { return 0 }
      hasSetTemp       { return 0 }
      hasVideo         { return 0 }
      hasWindow        { return 0 }
      loadMode         { return 0 }
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
      rawExtension     { return [ list .crw .cr2 .nef .dng ] }
      shutterList      { return [ list "" ] }
   }
}

#------------------------------------------------------------
# setFormat
#  configure le format (ou la qualite) d'image de la camera
#
# Parametres :
#    camItem : item de la camera
#    format  : format de l'image
# Return
#    rien
#------------------------------------------------------------
proc ::dslr::setFormat { camItem format } {
   variable private

### ::console::disp "::dslr::setFormat stack\n"
   cam$private($camItem,camNo) quality $format
}

