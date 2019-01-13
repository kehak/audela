# @file : modpoi2.tcl
# @brief Assistant à création et à la mise à jour d'un modele de pointage (voir le menu: Modèle de pointage V2)
# @author : Michel Pujol
# $Id: modpoi2.tcl 13696 2016-04-13 20:28:43Z michelpujol $


# @brief Assistant à création et à la mise à jour d'un modele de pointage (voir le menu: Modèle de pointage V2)
# 
#  @detail  aide au pointage des étoiles et calcule les coefficients du modele de pointage 
#
#  Symboles des coefficients calculés : 
#     - IH         : Décalage du codeur H
#     - ID         : Décalage du codeur D
#     - NP         : Non perpendicularité H/D
#     - CH         : Erreur de collimation
#     - ME         : Désalignement N/S de l'axe polaire
#     - MA         : Désalignement E/O de l'axe polaire
#     - FO         : Flexion de la fourche ; Fork Flexure
#     - MT  (=HF?) : Flexion de la monture ; Mount Flexure
#     - DAF        : Flexion de l'axe delta ; Delta Axis Flexure
#     - TF         : Flexion du tube optique ; Tube Flexure
#
#  
namespace eval ::modpoi2 {
   package provide modpoi2 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] modpoi2.cap ]

}

#------------------------------------------------------------
# getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::modpoi2::getPluginTitle { } {
   global caption

   return "$::caption(modpoi2,title)"
}

#------------------------------------------------------------
# getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::modpoi2::getPluginHelp { } {
   return "modpoi2.htm"
}

#------------------------------------------------------------
# getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::modpoi2::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::modpoi2::getPluginDirectory { } {
   return "modpoi2"
}

#------------------------------------------------------------
# getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::modpoi2::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#
# getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#   propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::modpoi2::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "" }
      display      { return "window" }
      default      { return "" }
   }
}

#------------------------------------------------------------
# createPluginInstance
#     cree une instance l'outil
#
#------------------------------------------------------------
proc ::modpoi2::createPluginInstance { base { visuNo 1 } } {
   variable private

   #--- je charge les fichier TCL supplementaires
   set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
   source [ file join $dir modpoi_main.tcl ]
   source [ file join $dir modpoi_process.tcl ]
   source [ file join $dir modpoi_wizard.tcl ]
   source [ file join $dir horizon.tcl ]

   set rep [file join $::audace(rep_home) modpoi horizon]
   if {![file exists $rep]} {
      #--   cree le repertoire horizon
      file mkdir "$rep"
   }

   #--- j'affiche la fenetre principale
   set This [::modpoi2::main::run $base $visuNo]

   return $This
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::modpoi2::deletePluginInstance { visuNo } {
   #--- je ferme la fenetre
   ::confGenerique::cmdClose $visuNo ::modpoi2::main
}

