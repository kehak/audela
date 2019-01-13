#
## @file animate.tcl
#  @brief Outil pour le contrôle des animations d'images
#  @author  Alain KLOTZ
#  $Id: animate.tcl 13710 2016-04-15 15:14:02Z robertdelmas $
#

#============================================================
# Declaration du namespace animate
#    initialise le namespace
#============================================================

## @namespace animate
#  @brief Outil pour le contrôle des animations d'images
namespace eval ::animate {
   package provide animate 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] animate.cap ]
}

#------------------------------------------------------------
## @brief  Retourne le titre du plugin dans la langue de l'utilisateur
#  @return Titre du plugin
#
proc ::animate::getPluginTitle { } {
   return "$::caption(animate,animation)"
}

#------------------------------------------------------------
## @brief  Retourne le nom du fichier d'aide principal
#  @return Nom du fichier d'aide principal : "animate.htm"
#
proc ::animate::getPluginHelp { } {
   return "animate.htm"
}

#------------------------------------------------------------
## @brief  Retourne le type de plugin
#  @return Type de plugin : "tool"
#
proc ::animate::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
## @brief  Retourne le nom du répertoire du plugin
#  @return Nom du répertoire du plugin : "animate"
#
proc ::animate::getPluginDirectory { } {
   return "animate"
}

#------------------------------------------------------------
## @brief  Retourne le ou les OS de fonctionnement du plugin
#  @return Liste des OS : "Windows Linux Darwin"
#
proc ::animate::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief  Retourne les propriétés de l'outil
#          Cet outil s'ouvre dans une fenêtre indépendante à partir du menu Fichier
#  @param  propertyName Nom de la propriété
#  @return Valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::animate::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "animate" }
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
proc ::animate::createPluginInstance { base { visuNo 1 } } {
   variable This

   set This $base.animate

   #--- Prepare la creation de la fenetre de l'outil
   ::animate::createPanel

   return $This
}

#------------------------------------------------------------
## @brief Suppprime l'instance du plugin
#  @param visuNo Numéro de la visu
#
proc ::animate::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
## @brief Prépare la création de la fenêtre de l'outil
#
proc ::animate::createPanel { } {
   #--- Initialisation des captions
   set ::panneau(animate,titre)           $::caption(animate,animation)
   set ::panneau(animate,aide)            $::caption(animate,help_titre)
   set ::panneau(animate,aide1)           $::caption(animate,help_titre1)
   set ::panneau(animate,parcourir)       $::caption(animate,parcourir)
   set ::panneau(animate,genericfilename) $::caption(animate,nom_generique)
   set ::panneau(animate,nbimages)        $::caption(animate,nb_images)
   set ::panneau(animate,delayms)         $::caption(animate,delai_ms)
   set ::panneau(animate,nbloops)         $::caption(animate,nb_boucles)
   set ::panneau(animate,go)              $::caption(animate,go_animation)

   #--- Initialisation de variables
   if { [info exists ::panneau(animate,filename)] == "0" } { set ::panneau(animate,filename) "" }
   if { [info exists ::panneau(animate,nbi)] == "0" }      { set ::panneau(animate,nbi)      "3" }
   if { [info exists ::panneau(animate,ms)] == "0" }       { set ::panneau(animate,ms)       "300" }
   if { [info exists ::panneau(animate,nbl)] == "0" }      { set ::panneau(animate,nbl)      "5" }

   #--- Construction de l'interface
   ::animate::animBuildIF
}

#------------------------------------------------------------
## @brief Masque la fenêtre de l'outil
#  @param visuNo Numéro de la visu
#
proc ::animate::stopTool { visuNo } {
   set ::panneau(animate,filename) ""
   set ::panneau(animate,nbi)      "3"
}

#------------------------------------------------------------
## @brief Lance l'animation
#
proc ::animate::cmdGo { } {
   variable This

   #--- Nettoyage de la visualisation
   visu$::audace(visuNo) clear
   ::confVisu::setFileName $::audace(visuNo) ""
   #--- Lancement de l'animation
   if { $::panneau(animate,filename) != "" } {
      #--- Verifie que le nombre d'images est un entier non nul
      if { $::panneau(animate,nbi) == "0" } {
         tk_messageBox -title $::caption(animate,attention) -icon error \
            -message "$::caption(animate,nb_images1) $::caption(animate,nbre_entier)"
         set ::panneau(animate,nbi) ""
         return
      }
      #--- Verifie que le nombre de ms est un entier non nul
      if { $::panneau(animate,ms) == "0" } {
         tk_messageBox -title $::caption(animate,attention) -icon error \
            -message "$::caption(animate,delai) $::caption(animate,nbre_entier)"
         set ::panneau(animate,ms) "300"
         return
      }
      #--- Verifie que le nombre de boucles est un entier non nul
      if { $::panneau(animate,nbl) == "0" } {
         tk_messageBox -title $::caption(animate,attention) -icon error \
            -message "$::caption(animate,nb_boucles1) $::caption(animate,nbre_entier)"
         set ::panneau(animate,nbl) "5"
         return
      }
      #--- Verifie que le fichier selectionne appartient au repertoire des images
      if { [ file dirname $::panneau(animate,folder+filname) ] != $::audace(rep_images) } {
         tk_messageBox -title $::caption(animate,attention) -icon error \
            -message $::caption(animate,rep-images)
         set ::panneau(animate,filename) ""
         set ::panneau(animate,nbi)      ""
         return
      }
      #--- Gestion du bouton Go Animation
      $This.fra6.but1 configure -relief groove -state disabled
      #--- Animation avec gestion des erreurs (absence d'images, images dans un autre repertoire, etc.)
      #--- supportee par la variable error retournee par la procedure animate du script aud1.tcl
      set error [ animate $::panneau(animate,filename) $::panneau(animate,nbi) $::panneau(animate,ms) \
         $::panneau(animate,nbl) $::panneau(animate,liste_index) ]
      if { $error == "1" } {
         ::animate::erreurAnimate
         }
      #--- Gestion du bouton Go Animation
      $This.fra6.but1 configure -relief raised -state normal
   }
}

#------------------------------------------------------------
## @brief Affiche un message d'erreur
#
proc ::animate::erreurAnimate { } {
   tk_messageBox -title $::caption(animate,attention) -icon error \
      -message $::caption(animate,erreur)
   set ::panneau(animate,nbi) ""
   return
}

#------------------------------------------------------------
## @brief Edite le nom générique du fichier
#
proc ::animate::editNomGenerique { } {
   #--- Fenetre parent
   set fenetre $::audace(base)
   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_load $fenetre $::audace(rep_images) $::audace(bufNo) "1" ]
   set ::panneau(animate,folder+filname) "$filename"
   #--- Il faut un fichier
   if { $filename == "" } {
      return
   }
   #--- Le fichier selectionne doit imperativement etre dans le repertoire des images
   if { [ file dirname $filename ] != $::audace(rep_images) } {
      tk_messageBox -title $::caption(animate,attention) -icon error \
         -message $::caption(animate,rep-images)
      set ::panneau(animate,filename) ""
      set ::panneau(animate,nbi)      ""
      return
   }
   #--- Extraction du nom generique
   set filenameAnimation              [ ::tkutil::afficherNomGenerique [ file tail $filename ] 1 ]
   set ::panneau(animate,filename)    [ lindex $filenameAnimation 0 ]
   set ::panneau(animate,nbi)         [ lindex $filenameAnimation 1 ]
   set ::panneau(animate,liste_index) [ lindex $filenameAnimation 3 ]
}

#------------------------------------------------------------
## @brief Crée l'interface graphique
#
proc ::animate::animBuildIF { } {
   variable This

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$::panneau(animate,aide1)\n$::panneau(animate,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::animate::getPluginType ] ] \
               [ ::animate::getPluginDirectory ] [ ::animate::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $::panneau(animate,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du nom generique
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour le nom generique
         label $This.fra2.lab1 -text $::panneau(animate,genericfilename) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Entry pour le nom generique
         entry $This.fra2.ent1 -textvariable ::panneau(animate,filename) -width 14 -relief groove -state disabled
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 1 -side left

         #--- Bouton parcourir
         button $This.fra2.but1 -borderwidth 2 -text $::panneau(animate,parcourir) \
            -command ::animate::editNomGenerique
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side left

      pack $This.fra2 -side top -fill x

      #--- Frame pour le nombre d'images
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour le nombre d'images
         label $This.fra3.lab1 -text $::panneau(animate,nbimages) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

         #--- Entry pour le nombre d'images
         entry $This.fra3.ent1 -textvariable ::panneau(animate,nbi) -relief groove -width 4 -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
         pack $This.fra3.ent1 -in $This.fra3 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

      pack $This.fra3 -side top -fill x

      #--- Frame pour le delai
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Label pour le delai
         label $This.fra4.lab1 -text $::panneau(animate,delayms) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

         #--- Entry pour le delai
         entry $This.fra4.ent1 -textvariable ::panneau(animate,ms) -relief groove -width 5 -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
         pack $This.fra4.ent1 -in $This.fra4 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

      pack $This.fra4 -side top -fill x

      #--- Frame pour le nb de boucles
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour le nb de boucles
         label $This.fra5.lab1 -text $::panneau(animate,nbloops) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

         #--- Entry pour le nb de boucles
         entry $This.fra5.ent1 -textvariable ::panneau(animate,nbl) -relief groove -width 4 -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
        pack $This.fra5.ent1 -in $This.fra5 -anchor center -expand true -fill none -padx 2 -pady 5 -side left

      pack $This.fra5 -side top -fill x

      #--- Lancement de l'animation
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Bouton GO Animation
         button $This.fra6.but1 -borderwidth 2 -text $::panneau(animate,go) \
            -command ::animate::cmdGo
         pack $This.fra6.but1 -in $This.fra6 -anchor center -fill x -padx 5 -pady 5 -ipadx 5 -ipady 8

      pack $This.fra6 -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

