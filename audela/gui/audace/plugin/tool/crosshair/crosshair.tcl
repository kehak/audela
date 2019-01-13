#
## @file crosshair.tcl
#  @brief Affiche un réticule sur l'image
#  @author Michel PUJOL
#  $Id: crosshair.tcl 13608 2016-04-04 14:08:51Z rzachantke $
#

#============================================================
# Declaration du namespace Crosshair
#    initialise le namespace
#============================================================

## @namespace Crosshair
#  @brief Affiche un réticule sur l'image
namespace eval ::Crosshair {
   package provide Crosshair 1.0

   array set widget { }

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] crosshair.cap ]

   #------------------------------------------------------------
   # brief     retourne le titre du plugin dans la langue de l'utilisateur
   # return    titre du plugin
   #
   proc getPluginTitle { } {
      global caption

      return "$caption(crosshair,titre)"
   }

   #------------------------------------------------------------
   # brief     retourne le nom du fichier d'aide principal
   # return    nom du fichier d'aide principal
   #
   proc getPluginHelp { } {
      return "crosshair.htm"
   }

   #------------------------------------------------------------
   # brief     retourne le type de plugin
   # return    type de plugin
   #
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # brief     retourne le nom du répertoire du plugin
   # return    nom du répertoire du plugin : "crosshair"
   #
   proc getPluginDirectory { } {
      return "crosshair"
   }

   #------------------------------------------------------------
   ## @brief    retourne le ou les OS de fonctionnement du plugin
   #  @return   liste des OS : "Windows Linux Darwin"
   #
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   ## @brief    retourne les propriétés de l'outil
   #
   #            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
   #  @param    propertyName nom de la propriété
   #  @return   valeur de la propriété ou "" si la propriété n'existe pas
   #
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "display" }
         subfunction1 { return "crosshair" }
         display      { return "window" }
         multivisu    { return 1 }
         default      { return "" }
      }
   }

   #------------------------------------------------------------
   ## @brief   créé une nouvelle instance de l'outil
   #  @param   base   base tk
   #  @param   visuNo numéro de la visu
   #  @return  chemin de la fenêtre
   #
   proc createPluginInstance { base { visuNo 1 } } {
      variable private

      #--- j'initialise une variable locale
      set private(imageSize) " "

      #--- j'ouvre la fenetre
      ::confGenerique::run $visuNo [confVisu::getBase $visuNo].confCrossHair ::Crosshair -modal 0

      return [confVisu::getBase $visuNo].confCrossHair
   }

   #------------------------------------------------------------
   ## @brief   suppprime l'instance du plugin
   #  @param   visuNo numéro de la visu
   #
   proc deletePluginInstance { visuNo } {
      if { [ winfo exists [ confVisu::getBase $visuNo ].confCrossHair ] } {
         #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
         ::Crosshair::cmdClose $visuNo
      }
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Réticule"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(visu,crosshair,defaultstate) définit si le réticule est actif ou non à l'ouverture d'une image
   #  - conf(visu,crosshair,color)        définit la couleur du réticule
   #  @remarks ces variables conf(...) sont initialisées dans la procédure "::confVisu::create" de "confvisu.tcl"
   #
   proc initConf { } {
   }

   #------------------------------------------------------------
   #  brief retourne le nom et le label du réticule
   #
   #  fonction liée à \::confGenerique
   #
   proc getLabel { } {
      return [ ::Crosshair::getPluginTitle ]
   }

   #------------------------------------------------------------
   ## @brief  commande du bouton "Appliquer"
   #
   #          copie les variable des widgets dans le tableau conf()
   #  @param  visuNo numéro de la visu
   #
   proc cmdApply { visuNo } {
      variable widget
      global conf

      set conf(visu,crosshair,color)        $widget(color)
      set conf(visu,crosshair,defaultstate) $widget(defaultstate)

      ::confVisu::setCrosshair $visuNo $widget($visuNo,currentstate)
   }

   #------------------------------------------------------------
   ## @brief  commande du bouton "Fermer"
   #
   proc cmdClose { visuNo } {
      variable wbase

      #--- Detruit la fenetre
      destroy [confVisu::getBase $visuNo].confCrossHair
   }

   #------------------------------------------------------------
   #  brief   créé l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      variable widget
      global caption conf

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      #--- j'initialise les valeurs
      set widget(color)                $conf(visu,crosshair,color)
      set widget(defaultstate)         $conf(visu,crosshair,defaultstate)
      set widget($visuNo,currentstate) [::confVisu::getCrosshair $visuNo]

      #--- creation des differents frames
      frame $frm.frameState -borderwidth 1 -relief raised
      pack $frm.frameState -side top -fill both -expand 1

      frame $frm.frameColor -borderwidth 1 -relief raised
      pack $frm.frameColor -side top -fill both -expand 1

      #--- current state
      checkbutton $frm.frameState.currentstate -text "$caption(crosshair,current_state_label)" \
         -highlightthickness 0 -variable ::Crosshair::widget($visuNo,currentstate)
      pack $frm.frameState.currentstate -in $frm.frameState -anchor center -side left -padx 10 -pady 5

      #--- default state
      checkbutton $frm.frameState.defaultstate -text "$caption(crosshair,default_state_label)" \
         -highlightthickness 0 -variable ::Crosshair::widget(defaultstate)
      pack $frm.frameState.defaultstate -in $frm.frameState -anchor center -side left -padx 10 -pady 5

      #--- color
      label $frm.frameColor.labColor -text "$caption(crosshair,color_label)" -relief flat
      pack $frm.frameColor.labColor -in $frm.frameColor -anchor center -side left -padx 10 -pady 10

      button $frm.frameColor.butColor_color_invariant -relief raised -width 6 -bg $widget(color) \
         -activebackground $widget(color) -command "::Crosshair::changeColor $frm"
      pack $frm.frameColor.butColor_color_invariant -in $frm.frameColor -anchor center -side left -padx 10 -pady 5 -ipady 5
   }

   #==============================================================
   # Fonctions specifiques
   #==============================================================

   #------------------------------------------------------------
   #  brief   affiche l'aide de ce plugin
   #
   #  fonction liée à \::confGenerique
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::Crosshair::getPluginType ] ] \
         [ ::Crosshair::getPluginDirectory ] [ ::Crosshair::getPluginHelp ]
   }

   #------------------------------------------------------------
   #  brief   change la couleur du réticule
   #  param   chemin de la frame
   #
   proc changeColor { frm } {
      variable widget
      global caption

      set temp [tk_chooseColor -initialcolor $::Crosshair::widget(color) -parent ${Crosshair::widget(frm)} \
         -title ${caption(crosshair,color_crosshair)} ]
      if  { "$temp" != "" } {
         set Crosshair::widget(color) "$temp"
         ${Crosshair::widget(frm)}.frameColor.butColor_color_invariant configure \
            -bg $::Crosshair::widget(color) -activebackground $::Crosshair::widget(color)
      }
   }

}

