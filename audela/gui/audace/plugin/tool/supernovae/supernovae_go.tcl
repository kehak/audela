#
# Fichier : supernovae_go.tcl
# Description : Outil pour l'observation des SnAudes
# Auteur : Alain KLOTZ
# Mise à jour $Id: supernovae_go.tcl 12688 2016-01-16 18:53:20Z robertdelmas $
#

#============================================================
# Declaration du namespace supernovae
#    initialise le namespace
#============================================================
namespace eval ::supernovae {
   package provide supernovae 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] supernovae_go.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::supernovae::getPluginTitle { } {
   global caption

   return "$caption(supernovae_go,supernovae)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::supernovae::getPluginHelp { } {
   return "supernovae.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::supernovae::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#------------------------------------------------------------
proc ::supernovae::getPluginDirectory { } {
   return "supernovae"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::supernovae::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::supernovae::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::supernovae::createPluginInstance { base { visuNo 1 } } {
   ::supernovae::createPanel $base.supernovae
   return $base.supernovae
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::supernovae::deletePluginInstance { visuNo } {
   global audace

   if { [ winfo exists $audace(base).snvisu ] } {
      snDelete
   }
}

#------------------------------------------------------------
# createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::createPanel { this } {
   variable This
   global caption panneau

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Initialisation des captions
   set panneau(supernovae,titre)     "$caption(supernovae_go,supernovae1)"
   set panneau(supernovae,aide)      "$caption(supernovae_go,help,titre)"
   set panneau(supernovae,aide1)     "$caption(supernovae_go,help,titre1)"
   set panneau(supernovae,recherche) "$caption(supernovae_go,recherche_sn)"
   set panneau(supernovae,snacq)     "$caption(supernovae_go,sn_acq)"
   set panneau(supernovae,snvisu)    "$caption(supernovae_go,sn_visu)"
   #--- Construction de l'interface
   supernovaeBuildIF $This
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::startTool { visuNo } {
   variable This

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(supernovae,keywordConfigName) ] } { set ::conf(supernovae,keywordConfigName) "default" }

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::supernovae::configToolKeywords $visuNo
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::stopTool { visuNo } {
   variable This

   #--- Je verifie si une operation est en cours
   if { [info exists ::sn(exit_visu)] } {
      if { $::sn(exit_visu) == 1 } {
         return -1
      }
   }

   #--- Je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(supernovae,keywordConfigName) [ list ]
}

#------------------------------------------------------------
# getNameKeywords
#    definit le nom de la configuration des mots cles FITS de l'outil
#    uniquement pour les outils qui configurent les mots cles selon des
#    exigences propres a eux
#------------------------------------------------------------
proc ::supernovae::getNameKeywords { visuNo configName } {
   #--- Je definis le nom
   set ::conf(supernovae,keywordConfigName) $configName
}

#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#------------------------------------------------------------
proc ::supernovae::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(supernovae,keywordConfigName)
   }

   #--- Je selectionne les mots cles optionnels a ajouter dans les images
   #--- Les mots cles RA, DEC, XPIXSZ et YPIXSZ sont obligatoires pour "snPrism" de snmacro.tcl
   #--- OBJNAME a ete rajoute car il caracterise le nom de l'objet pointe
   ::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 OBJNAME RA DEC XPIXSZ YPIXSZ ]

   #--- Je selectionne la liste des mots cles non modifiables
   ::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 OBJNAME RA DEC XPIXSZ YPIXSZ ]

   #--- Je force la capture des mots cles OBJNAME, RA et DEC en automatique
   ::keyword::setKeywordsObjRaDecAuto $visuNo
}

#------------------------------------------------------------
# supernovaeBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::supernovae::supernovaeBuildIF { This } {
   global audace panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(supernovae,aide1)\n$panneau(supernovae,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::supernovae::getPluginType ] ] \
               [ ::supernovae::getPluginDirectory ] [ ::supernovae::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(supernovae,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du frame
         label $This.fra2.lab1 -borderwidth 0 -text $panneau(supernovae,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton Sn Acq
         button $This.fra2.but1 -borderwidth 2 -text $panneau(supernovae,snacq) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snacq.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton Sn Visu
         button $This.fra2.but2 -borderwidth 2 -text $panneau(supernovae,snvisu) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snvisu.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

