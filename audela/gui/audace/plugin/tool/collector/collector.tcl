#
## @file collector.tcl
#  @brief Outil de collecte d'informations sur l'environnement
#  @author Raymond Zachantke
#  $Id: collector.tcl 13610 2016-04-04 14:37:59Z rzachantke $
#

#============================================================
# Declaration du namespace collector
#    initialise le namespace
#============================================================

## @namespace collector
#  @brief Outil de collecte d'informations sur l'environnement
namespace eval ::collector {
   package provide collector 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] collector.cap ]

}

#------------------------------------------------------------
# brief    retourne le titre du plugin dans la langue de l'utilisateur
# return   titre du plugin
#
proc ::collector::getPluginTitle { } {
   global caption

   return "$caption(collector,title)"
}

#------------------------------------------------------------
# brief    retourne le nom du fichier d'aide principal
# return   nom du fichier d'aide principal
#
proc ::collector::getPluginHelp { } {
   return "collector.htm"
}

#------------------------------------------------------------
# brief    retourne le type de plugin
# return   type de plugin
#
proc ::collector::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief    retourne le nom du répertoire du plugin
# return   nom du répertoire du plugin : "collector"
#
proc ::collector::getPluginDirectory { } {
   return "collector"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux Darwin"
#
proc ::collector::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::collector::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "collector" }
      display      { return "window" }
      multivisu    { return 0 }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin de la fenêtre
#
proc ::collector::createPluginInstance { base { visuNo 1 } } {
   variable This

   package require http
   package require struct::list

   set dirname [file join $::audace(rep_plugin) tool]
   source [ file join $dirname collector collector_cam.tcl ]
   source [ file join $dirname collector collector_dss.tcl ]
   source [ file join $dirname collector collector_dyn.tcl ]
   source [ file join $dirname collector collector_german.tcl ]
   source [ file join $dirname collector collector_get.tcl ]
   source [ file join $dirname collector collector_gui.tcl ]
   source [ file join $dirname collector collector_init.tcl ]
   source [ file join $dirname collector collector_simul.tcl ]
   source [ file join $dirname collector collector_utils.tcl ]

   set This "$base.collector"

   #-- prepare et cree le notebook
   ::collector::initCollector $visuNo

   return "$This"
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin
#  @param   visuNo numéro de la visu
#
proc ::collector::deletePluginInstance { {visuNo 1} } {
   variable This

   if {[ winfo exists $This ] ==1} {
      ::collector::cmdClose $visuNo
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Collector"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(collector,position)    définit la position de la fenêtre
#  - conf(collector,kwdgeometry) définit les dimensions et la position de la fenêtre d'édition des mots clés
#  - conf(collector,catname)     définit le nom du catalogue utilisé
#  - conf(collector,cam)         définit les caméras ne figurant pas dans etc_tools.tcl
#  - conf(collector,colors)      définit la liste des couleurs du canvas du télescope
#  - conf(collector,butees)      définit la position des butées du télescope
#
proc ::collector::initConf { } {
   global conf

   set listConf [list position kwdgeometry catname cam]
   set listDefault [list "+800+500" "400x115+100+100" "MICROCAT" " "]
   foreach topic $listConf value $listDefault {
      if {![info exists conf(collector,$topic)]} { set conf(collector,$topic) $value }
   }

   #--   variables liees à l'onglet "Equatoriale"
   if {![info exists conf(collector,colors)]} { set conf(collector,colors) [list blue azure yellow red gray] }
   if {![info exists conf(collector,butees)]} { set conf(collector,butees) [list +7 -7] }
}

#------------------------------------------------------------
#  brief   charge les variables de configuration dans des variables locales
#
proc ::collector::confToWidget {} {
   variable private
   global conf color

   ::collector::initConf

   foreach topic [list position catname cam] {
      set private($topic) $conf(collector,$topic)
   }

   lassign $conf(collector,colors) private(colFond) private(colReticule) \
      private(colTel) private(colButee) private(colSector)
   lassign $conf(collector,butees) private(buteeWest) private(buteeEast)

   #::collector::editCamerasArray
}

#------------------------------------------------------------
#  brief   charge les variables locales dans des variables de configuration
#
proc ::collector::widgetToConf { } {
   variable private
   variable This
   global conf

   set conf(collector,catname) $private(catname)
   regsub {([0-9]+x[0-9]+)} [wm geometry $This] "" conf(collector,position)

   set conf(collector,colors) [list $private(colFond) $private(colReticule) \
      $private(colTel) $private(colButee) $private(colSector)]
   set conf(collector,butees) [list $private(buteeWest) $private(buteeEast)]

   #--  Actualise la variable conf(collector,cam)
   ::collector::setConfCam
}

#---  Note : les commandes équivalentes à cmdApply sont réparties dans divers fichiers

#------------------------------------------------------------
## @brief   commande du bouton "Fermer"
#
proc ::collector::cmdClose { visuNo } {
   variable This
   variable private
   global audace conf

   #--   arrete la mise a jour
   #--   pas d'importance si pas active
   after cancel ::collector::refreshMeteo

   #--   supprime les icones
   foreach icon {baguette chaudron greenLed redLed} {
     if {[info exists $private($icon)]} {
        image delete $private($icon)
     }
   }

   ::collector::configTraceSuivi 0
   ::collector::configTraceRaDec 0
   ::collector::configAddRemoveListener $visuNo remove
   ::collector::widgetToConf

   destroy $This
}

