## @file vo_tools_go.tcl
# @brief Outil d'appel des fonctionnalites de l'observatoire virtuel
# @author Robert DELMAS & J. Berthier
# @version 1.0
# @par Ressource
# @code source [file join $audace(rep_install) gui audace plugin tool vo_tools vo_tools_go.tcl]
# @endcode

# $Id: vo_tools_go.tcl 13892 2016-05-23 17:09:28Z rzachantke $

#------------------------------------------------------------
##
# @namespace vo_tools
# @brief definition du namespace vo_tools
# @pre Requiert le fichier d'internationalisation \c vo_tools_go.cap .
#
namespace eval ::vo_tools {
   package provide vo_tools 2.0
   global audace

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] vo_tools_go.cap ]

}

#------------------------------------------------------------
## @brief retourne le titre du plugin dans la langue de l'utilisateur
# @return titre de l'outil
#
proc ::vo_tools::getPluginTitle { } {
   global caption
   return "$caption(vo_tools_go,titre)"
}

#------------------------------------------------------------
## @brief retourne le nom du fichier d'aide principal
# @return nom du fichier HTML de la documentation de l'outil
#
proc ::vo_tools::getPluginHelp { } {
   return "vo_tools.htm"
}

#------------------------------------------------------------
## @brief retourne le type de plugin
# @return type du plugin (tool)
#
proc ::vo_tools::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
## @brief retourne le nom du repertoire du plugin
# @return Nom du repertoire du plugin (vo_tools)
#
proc ::vo_tools::getPluginDirectory { } {
   return "vo_tools"
}

#------------------------------------------------------------
## @brief retourne le ou les OS de fonctionnement du plugin
# @return liste des OS
#
proc ::vo_tools::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief retourne la valeur de la propriete
# @param propertyName string nom de la propriete
# @return valeur de la propriete ou une chaine vide si la propriete n'existe pas
#
proc ::vo_tools::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "solar system" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
## @brief cree une nouvelle instance de l'outil
# @param base pathName du widget parent
# @param visuNo int Numero de la visu (defaut: 1)
# @return pathName du widget
#
proc ::vo_tools::createPluginInstance { base { visuNo 1 } } {
   global audace

   #--- Chargement du package Tablelist
   package require Tablelist
   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_resolver.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_search.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools skybot_statut.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""
   #--- Definie la variable de listerner pour le statut de connexion
   set ::vo_tools::interop($::audace(visuNo),interopListener) ""
   #--- Mise en place de l'interface graphique
   ::vo_tools::createPanel $base.vo_tools
   #---
   return $base.vo_tools
}

#------------------------------------------------------------
## @brief suppprime l'instance du plugin
# @param visuNo int Numero de la visu (defaut: 1)
#
proc ::vo_tools::deletePluginInstance { visuNo } {
   ::Samp::destroy
}

#------------------------------------------------------------
## @brief prepare la creation de la fenetre de l'outil
# @param this pathName du widget
#
proc ::vo_tools::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(vo_tools,titre)  "$caption(vo_tools_go,vo_tools)"
   set panneau(vo_tools,aide)   "$caption(vo_tools_go,help_titre)"
   set panneau(vo_tools,aide1)  "$caption(vo_tools_go,help_titre1)"
   set panneau(vo_tools,titre1) "$caption(vo_tools_go,aladin)"
   set panneau(vo_tools,titre2) "$caption(vo_tools_go,cone-search)"
   set panneau(vo_tools,titre3) "$caption(vo_tools_go,resolver)"
   set panneau(vo_tools,titre4) "$caption(vo_tools_go,statut)"
   set panneau(vo_tools,titre5) "$caption(vo_tools_go,samp_menu_interop)"
   #--- Construction de l'interface
   ::vo_tools::vo_toolsBuildIF $This
}

#------------------------------------------------------------
## @brief créé la fenêtre de l'outil
# @param This pathName
#
proc ::vo_tools::vo_toolsBuildIF { This } {
   global audace panneau

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove
      set packoptions "-anchor center -expand 1 -fill both -side top -ipadx 5"

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(vo_tools,aide1)\n$panneau(vo_tools,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] \
               [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(vo_tools,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame CDS Aladin Multiview
      set frame $This.fra2
      frame $frame -borderwidth 2 -relief groove

         #--- Bouton d'ouverture de l'outil CDS Aladin Multiview
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre1) -state disabled \
            -command ""
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame des services SkyBoT
      set frame $This.fra3
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de recherche d'objets du Systeme Solaire dans le champ
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre2) \
            -command "::skybot_Search::run $audace(base).skybot_Search"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame du mode de calcul des ephemerides d'objets du Systeme Solaire
      set frame $This.fra4
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de calcul des ephemerides d'objets du Systeme Solaire
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre3) \
            -command "::skybot_Resolver::run $audace(base).skybot_Resolver"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame du mode de verification du statut de la base SkyBoT
      set frame $This.fra5
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton d'ouverture de l'outil de verification du statut de la base SkyBoT
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre4) \
            -command {
               #--- Gestion du bouton
               $::vo_tools::This.fra5.but1 configure -relief groove -state disabled
               #--- Lancement de la commande
               ::skybot_Statut::run "$audace(base).skybot_Statut"
            }
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Frame bouton Interop
      set frame $This.fra7
      frame $frame -borderwidth 1 -relief groove

         #--- Bouton
         button $frame.but1 -borderwidth 1 -text $panneau(vo_tools,titre5) \
            -command "::vo_tools::InstallMenuInterop  $frame"
         eval "pack $frame.but1 -in $frame $packoptions"

      pack $frame -side top -fill x

      #--- Mise a jour dynamique des couleurs et fontes
      ::confColor::applyColor $This
}

#------------------------------------------------------------
## @brief change l'etat des boutons de broadcast
# @param args string parametre transmis par le listener
#
proc ::vo_tools::handleBroadcastBtnState { args } {
   global audace caption menu
   set visuNo $::audace(visuNo)
   set stateImg "disabled"
   set stateTab "disabled"
   set stateSpe "disabled"

   # Determine l'etat
   if { $args ne "disabled" } {
      if {[::Samp::isConnected]} {
         # Test la presence d'une image 1D ou 2D
         if {[file exists [::confVisu::getFileName $visuNo]]} {
            set naxis [lindex [buf$::audace(bufNo) getkwd NAXIS] 1]
            if {$naxis == 1} {
               # C'est un spectre
               set stateImg "disabled"
               set stateSpe "normal"
            } else {
               # C'est une image
               set stateImg "normal"
               set stateSpe "disabled"
            }
         } else {
            set stateImg "disabled"
            set stateSpe "disabled"
         }
         # Test la presence en memoire d'une VOTable
         set err [catch {string length [::votableUtil::getVotable]} length]
         if {$err == 0 && $length > 0} {
            set stateTab "normal"
         } else {
            set stateTab "disabled"
         }
      }
   }
   # Configure le menu
   Menu_Configure $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastImg) "-state" $stateImg
   Menu_Configure $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastTab) "-state" $stateTab
   Menu_Configure $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastSpe) "-state" $stateSpe
}

#------------------------------------------------------------
## @brief change l'etat du menu Interop
# @param args string parametre transmis par le listener
#
proc ::vo_tools::handleInteropBtnState { args } {
   global audace caption menu
   set visuNo $::audace(visuNo)
   set colorBtn "#CC0000"

   # Determine l'etat
   if { $args ne "disabled" } {
      if {[::Samp::isConnected]} {
         set colorBtn "#00CC00"
      } else {
         set colorBtn "#CC0000"
      }
   }
   # Configure menu
   $menu(menubar$visuNo) entryconfigure [$menu(menubar$visuNo) index "Interop"] -foreground $colorBtn
}

#------------------------------------------------------------
## @brief connection au hub Samp
#
proc ::vo_tools::SampConnect {} {
   if { [::SampTools::connect] } {
      ::vo_tools::handleInteropBtnState
      ::vo_tools::handleBroadcastBtnState
      set ::vo_tools::interop($::audace(visuNo),interopListener) ""
   } else {
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState "disabled"
      set ::vo_tools::interop($::audace(visuNo),interopListener) "disabled"
   }
}

#------------------------------------------------------------
## @brief Deconnection du hub Samp
#
proc ::vo_tools::SampDisconnect {} {
   ::Samp::destroy
   ::vo_tools::handleInteropBtnState "disabled"
   ::vo_tools::handleBroadcastBtnState "disabled"
   set ::vo_tools::interop($::audace(visuNo),interopListener) "disabled"
}

#------------------------------------------------------------
## @brief ajoute une procedure a appeler si le statut de la connexion change
# @param cmd string procedure a appeler
#
proc ::vo_tools::addInteropListener { cmd } {
   global audace
   trace add variable ::vo_tools::interop($::audace(visuNo),interopListener) write $cmd
}


#------------------------------------------------------------
## @brief enleve une procedure a appeler si le statut de la connexion change
# @param cmd string procedure a enlever
#
proc ::vo_tools::removeInteropListener { cmd } {
   global audace
   trace remove variable ::vo_tools::interop($::audace(visuNo),interopListener) write $cmd
}

#------------------------------------------------------------
## @brief charge une VOTable locale et affiche les objets dans la visu
#
proc ::vo_tools::LoadVotable { } {
   global audace caption

   # Verifie qu'une image est presente dans le canvas
   set image [::confVisu::getFileName $::audace(visuNo)]
   if { [file exists $image] == 0 } {
      tk_messageBox -title "Error" -type ok -message $caption(vo_tools_go,samp_noimageloaded)
   } else {
      # Ok, charge la VOTable
      if {[::votableUtil::loadVotable ? $::audace(visuNo)]} {
         ::votableUtil::displayVotable [::votableUtil::votable2list] $::audace(visuNo) "orange" "oval"
      }
      Menu_Configure $::audace(visuNo) "Interop" $caption(vo_tools_go,samp_menu_broadcastTab) "-state" "normal"
   }
}

#------------------------------------------------------------
## @brief nettoie les objets affiches dans la visu a partir d'une VOTable
# @param args unused
#
proc ::vo_tools::ClearDisplay { args } {
   ::votableUtil::clearDisplay
}

#------------------------------------------------------------
## @brief broadcast l'image courante
#
proc ::vo_tools::SampBroadcastImage {} {
   if { ! [::SampTools::broadcastImage] } {
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState "disabled"
   }
}

#------------------------------------------------------------
## @brief broadcast la table courante
#
proc ::vo_tools::SampBroadcastTable {} {
   if { ! [::SampTools::broadcastTable] } {
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState "disabled"
   }
}

#------------------------------------------------------------
## @brief broadcast le spectre courant
#
proc ::vo_tools::SampBroadcastSpectrum {} {
   if { ! [::SampTools::broadcastSpectrum] } {
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState "disabled"
   }
}

#------------------------------------------------------------
## @brief ouvre l'aide en ligne
#
proc ::vo_tools::helpInterop { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ] "field_7"
}

#------------------------------------------------------------
## @brief installe le menu Interop dans la barre de menu d'Audace
# @param frame pathName du widget
#
proc ::vo_tools::InstallMenuInterop { frame } {
   global audace caption menu
   set visuNo $::audace(visuNo)

   # Deploiement du menu Interop
   Menu $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_connect) ::vo_tools::SampConnect
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_disconnect) ::vo_tools::SampDisconnect
   Menu_Separator $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_loadvotable) ::vo_tools::LoadVotable
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_cleardisplay) ::vo_tools::ClearDisplay
   Menu_Separator $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastImg) ::vo_tools::SampBroadcastImage
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastSpe) ::vo_tools::SampBroadcastSpectrum
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_broadcastTab) ::vo_tools::SampBroadcastTable
   Menu_Separator $visuNo "Interop"
   Menu_Command $visuNo "Interop" $caption(vo_tools_go,samp_menu_help) ::vo_tools::helpInterop
   #--- Mise a jour dynamique des couleurs et fontes
   ::confColor::applyColor [MenuGet $visuNo "Interop"]
   # Destruction du bouton Interop du panneau VO
   destroy $frame
   # Tentative de connexion au hub Samp
   ::vo_tools::SampConnect
   # Ajoute un binding sur le canvas pour broadcaster les coordonnees cliquees
   bind $::audace(hCanvas) <ButtonPress-1> {catch {::SampTools::broadcastPointAtSky %W %x %y}}
   # Active la mise a jour automatique de l'affichage quand on change d'image
   ::confVisu::addFileNameListener $visuNo "::vo_tools::handleBroadcastBtnState"
   ::confVisu::addFileNameListener $visuNo "::vo_tools::ClearDisplay"

}
