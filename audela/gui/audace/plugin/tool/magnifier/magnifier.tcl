#
## @file magnifier.tcl
#  @brief Définit les caractéristiques de la loupe image
#  @author Raymond Zachantke
#  $Id: magnifier.tcl 13701 2016-04-14 15:31:42Z robertdelmas $
#

#============================================================
# Declaration du namespace magnifier
#    initialise le namespace
#============================================================

## @namespace  magnifier
#  @brief Définit les caractéristiques de la loupe image
namespace eval ::magnifier {
   package provide magnifier 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] magnifier.cap ]

   #------------------------------------------------------------
   #  brief      retourne le titre du plugin dans la langue de l'utilisateur
   #  return     titre du plugin
   #
   proc getPluginTitle { } {
      global caption

      return "$caption(magnifier,titre)"
   }

   #------------------------------------------------------------
   #  brief      retourne le nom du fichier d'aide principal
   #  return     nom du fichier d'aide principal
   #
   proc getPluginHelp { } {
      return "magnifier.htm"
   }

   #------------------------------------------------------------
   #  brief      retourne le type de plugin
   #  return     type de plugin
   #
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   #  brief      retourne le nom du répertoire du plugin
   #  return     nom du répertoire du plugin : "magnifier"
   #
   proc getPluginDirectory { } {
      return "magnifier"
   }

   #------------------------------------------------------------
   ## @brief     retourne le ou les OS de fonctionnement du plugin
   #  @return    liste des OS : "Windows Linux Darwin"
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
         subfunction1 { return "magnifier" }
         display      { return "window" }
         multivisu    { return 1 }
         default      { return "" }
      }
   }

   #------------------------------------------------------------
   ## @brief   créé une nouvelle instance de l'outil
   #
   #  cet outil apelle \::confGenerique et ses fonctions spécifiques
   #  @param   base   base tk
   #  @param   visuNo numéro de la visu
   #  @return  chemin de la fenêtre
   #
   proc createPluginInstance { base { visuNo 1 } } {
      variable This
      variable widget
      global conf

      set This "$base.confMagnifier"

      #-- NB pas confToWidget ni de widgetToConf

      #--- j'initialise les valeurs
      set widget(color)                $conf(visu,magnifier,color)
      set widget(defaultstate)         $conf(visu,magnifier,defaultstate)
      set widget(nbPixels)             $conf(visu,magnifier,nbPixels)
      set widget($visuNo,currentstate) [::confVisu::getMagnifier $visuNo]

      ::confGenerique::run $visuNo $This ::magnifier -modal 0

      return $This
   }

   #------------------------------------------------------------
   ## @brief   suppprime l'instance du plugin
   #
   proc deletePluginInstance { { visuNo 1 } } {
      variable This

      if { [winfo exists $This] ==1} {
         #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
         ::magnifier::cmdClose $visuNo
      }
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Loupe"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(visu,magnifier,defaultstate) définit si la loupe est active ou non
   #  - conf(visu,magnifier,color)        définit la couleur du réticule interne à la loupe
   #  - conf(visu,magnifier,nbPixels)     définit le nombre de pixels (largeur et hauteur) à afficher à l'intérieur de la loupe
   #  @remarks ces variables conf(...) sont initialisées dans la procédure "::confVisu::create" de "confvisu.tcl"
   #
   proc initConf { } {
   }

   #------------------------------------------------------------
   #  brief    retourne le nom et le label du réticule
   #
   #  fonction liée à \::confGenerique
   #
   proc getLabel { } {
      return [ ::magnifier::getPluginTitle ]
   }

   #------------------------------------------------------------
   #   brief   créé la fenêtre de configuration du réticule
   #   param   frm    chemin de la frame
   #   param   visuNo visuNo numéro de la visu
   #
   proc fillConfigPage { frm visuNo } {
      variable widget
      global caption conf

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      set tbl $frm

      #--- current state
      checkbutton $tbl.currentstate -text "$caption(magnifier,current_state_label)" \
         -highlightthickness 0 -variable ::magnifier::widget($visuNo,currentstate)

      #--- default state
      checkbutton $tbl.defaultstate -text "$caption(magnifier,default_state_label)" \
         -highlightthickness 0 -variable ::magnifier::widget(defaultstate)

      #--- color
      label $tbl.labColor -text "$caption(magnifier,color_crosshair)" -relief flat
      button $tbl.butColor_color_invariant -relief raised -width 6 -bg $widget(color) \
         -activebackground $widget(color) -command "::magnifier::changeColor $tbl"

      #--- grossissement
      label $tbl.labGros -text "$caption(magnifier,nbPixels)"
      ComboBox $tbl.gros -textvariable ::magnifier::widget(nbPixels) \
         -relief sunken -width 4 -height 4 -values [list 5 7 9 11 13 15 19]

      blt::table $tbl \
        $tbl.currentstate 0,0 -anchor w -padx 10 \
        $tbl.defaultstate 0,1 -anchor w -padx 10 \
        $tbl.labColor 1,0 -anchor w -padx 10 \
        $tbl.butColor_color_invariant 1,1 -anchor w -padx 10 -height 30\
        $tbl.labGros 2,0 -anchor w -padx 10 \
        $tbl.gros 2,1 -anchor w -padx 10
      pack $tbl -side top -fill both -expand 1
      blt::table configure $tbl r0 r1 r2 -height 40
   }

   #------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #
   #  copie les variable des widgets dans le tableau conf()
   #  @param   visuNo numéro de la visu
   #
   #   fonction liée à \::confGenerique
   #
   proc cmdApply { visuNo } {
      variable widget
      global conf

      set conf(visu,magnifier,color) $widget(color)
      set conf(visu,magnifier,defaultstate) $widget(defaultstate)
      set conf(visu,magnifier,nbPixels) $widget(nbPixels)

      ::confVisu::setMagnifier $visuNo $widget($visuNo,currentstate)
   }

   #------------------------------------------------------------
   ## @brief   commande du bouton "Fermer"
   #
   #   fonction liée à \::confGenerique
   #
   proc cmdClose { visuNo } {
      variable This

      destroy $This
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
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::magnifier::getPluginType ] ] \
         [ ::magnifier::getPluginDirectory ] [ ::magnifier::getPluginHelp ]
   }

   #------------------------------------------------------------
   #  brief   change la couleur de la loupe
   #  param   chemin de la frame
   #
   proc changeColor { frm } {
      variable widget
      global caption

      set temp [tk_chooseColor -initialcolor $::magnifier::widget(color) -parent ${magnifier::widget(frm)} \
         -title ${caption(magnifier,color_crosshair)} ]

      if  { "$temp" != "" } {
         set ::magnifier::widget(color) "$temp"
         $frm.butColor_color_invariant configure -bg $::magnifier::widget(color) -activebackground $::magnifier::widget(color)
      }
   }

}

