#
## @file viseur_polaire_go.tcl
#  @brief Outil proposant 2 types de viseurs polaires :
#  - Type Takahashi
#  - Type EQ6
#  @author Robert DELMAS
#  $Id: viseur_polaire_go.tcl 13710 2016-04-15 15:14:02Z robertdelmas $
#

#============================================================
# Declaration du namespace viseur_polaire
#    initialise le namespace
#============================================================

## @namespace viseur_polaire
#  @brief Outil proposant 2 types de viseurs polaires :
#  - Type Takahashi
#  - Type EQ6
namespace eval ::viseur_polaire {
   package provide viseur_polaire 2.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] viseur_polaire.cap ]
}

#------------------------------------------------------------
## @brief  Retourne le titre du plugin dans la langue de l'utilisateur
#  @return Titre du plugin
#
proc ::viseur_polaire::getPluginTitle { } {
   return $::caption(viseur_polaire,titre)
}

#------------------------------------------------------------
## @brief  Retourne le nom du fichier d'aide principal
#  @return Nom du fichier d'aide principal : "viseur_polaire.htm"
#
proc ::viseur_polaire::getPluginHelp { } {
   return "viseur_polaire.htm"
}

#------------------------------------------------------------
## @brief  Retourne le type de plugin
#  @return Type de plugin : "tool"
#
proc ::viseur_polaire::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
## @brief  Retourne le nom du répertoire du plugin
#  @return Nom du répertoire du plugin : "viseur_polaire"
#
proc ::viseur_polaire::getPluginDirectory { } {
   return "viseur_polaire"
}

#------------------------------------------------------------
## @brief  Retourne le ou les OS de fonctionnement du plugin
#  @return Liste des OS : "Windows Linux Darwin"
#
proc ::viseur_polaire::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief  Retourne les propriétés de l'outil
#
#          Cet outil s'ouvre à partir du menu Télescope
#  @param  propertyName Nom de la propriété
#  @return Valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::viseur_polaire::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "" }
      display      { return "panel" }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief  Crée une nouvelle instance de l'outil
#  @param  base   Base Tk
#  @param  visuNo Numéro de la visu
#  @return Chemin de la fenêtre
#
proc ::viseur_polaire::createPluginInstance { base { visuNo 1 } } {
   ::viseur_polaire::createPanel $base.viseur_polaire
   return $base.viseur_polaire
}

#------------------------------------------------------------
## @brief Suppprime l'instance du plugin
#  @param visuNo Numéro de la visu
#
proc ::viseur_polaire::deletePluginInstance { visuNo } {
}

#------------------------------------------------------------
## @brief Prépare la création de l'interface graphique
#
proc ::viseur_polaire::createPanel { this } {
   variable This
   variable widget

   #--- Initialisation du nom de la fenetre
   set This $this

   #--- Initialisation des captions
   set widget(viseur_polaire_go,titre) $::caption(viseur_polaire,titre)
   set widget(viseur_polaire_go,aide)  $::caption(viseur_polaire,help_titre)
   set widget(viseur_polaire_go,aide1) $::caption(viseur_polaire,help_titre1)
   set widget(viseur_polaire_go,taka)  $::caption(viseur_polaire,taka)
   set widget(viseur_polaire_go,eq6)   $::caption(viseur_polaire,eq6)
   #--- Construction de l'interface graphique
   viseur_polaireBuildIF $This
}

#------------------------------------------------------------
## @brief Crée l'interface graphique
#
proc ::viseur_polaire::viseur_polaireBuildIF { This } {
   variable widget

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$widget(viseur_polaire_go,aide1)\n$widget(viseur_polaire_go,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::viseur_polaire::getPluginType ] ] \
               [ ::viseur_polaire::getPluginDirectory ] [ ::viseur_polaire::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $widget(viseur_polaire_go,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du viseur polaire de type Takahashi
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type Takahashi
         button $This.fra2.but1 -borderwidth 2 -text $widget(viseur_polaire_go,taka) \
            -command ::viseur_polaire::goViseurPolaireTaka
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame du viseur polaire de type EQ6
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type EQ6
         button $This.fra3.but1 -borderwidth 2 -text $widget(viseur_polaire_go,eq6) \
            -command ::viseur_polaire::goViseurPolaireEQ6
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#------------------------------------------------------------
## @brief Crée la fenêtre de l'outil "Viseur polaire de type Takahashi"
#
proc ::viseur_polaire::goViseurPolaireTaka { } {
   variable This

   source [ file join $::audace(rep_plugin) tool viseur_polaire viseur_polaire_taka.tcl ]
   ::viseur_polaire::runTaka $This.viseurPolaireTaka
}

#------------------------------------------------------------
## @brief Crée la fenêtre de l'outil "Viseur polaire de type EQ6"
#
proc ::viseur_polaire::goViseurPolaireEQ6 { } {
   variable This

   source [ file join $::audace(rep_plugin) tool viseur_polaire viseur_polaire_eq6.tcl ]
   ::viseur_polaire::runEQ6 $This.viseurPolaireEQ6
}

