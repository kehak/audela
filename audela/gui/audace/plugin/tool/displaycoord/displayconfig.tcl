#
## @file displayconfig.tcl
#  @brief Configuration des paramètres de session
#  @author Michel PUJOL
# $Id: displayconfig.tcl 13316 2016-03-08 13:50:11Z rzachantke $
#

################################################################
# namespace ::displaycoord::config
#    initialise le namespace
################################################################

## namespace displaycoord::config
#  @brief Configuration des paramètres de session

namespace eval ::displaycoord::config {

}

#------------------------------------------------------------
## @brief affiche la fenêtre du traitement
#  @details utilise les fonctions de la classe parent ::confGenerique
#  @param tkbase nom tk de la fenêtre parent
#  @param visuNo  numéro de la visu parent
#  @public
#
proc ::displaycoord::config::run { tkbase visuNo } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(displaycoord,configWindowPosition) ] } { set ::conf(displaycoord,configWindowPosition) "300x200+20+10" }

   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.config"
   ::confGenerique::run  $visuNo $private($visuNo,This) "::displaycoord::config" -modal 0 -geometry $::conf(displaycoord,configWindowPosition) -resizable 1

}

#------------------------------------------------------------
## @brief ferme la fenêtre
#  @details cette procédure est appelée par ::confGenerique::cmdClose
#  @param visuNo  numéro de la visu
#  @public
#-
proc ::displaycoord::config::cmdClose { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(displaycoord,configWindowPosition) [ wm geometry $private($visuNo,This) ]
}

#------------------------------------------------------------
#  brief affiche l'aide de cet outil
#  details cette procédure est appelée par ::confGenerique::showHelp
#
proc ::displaycoord::config::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::displaycoord::getPluginType]] \
   [::displaycoord::getPluginDirectory] [::displaycoord::getPluginHelp]
}

#------------------------------------------------------------
## @brief enregistre les modifications
#  @details cette procédure est appelée par ::confGenerique::cmdApply
#  @param visuNo  numéro de la visu parent
#  @private
#
proc ::displaycoord::config::cmdApply { visuNo } {
   variable widget

   #--- je copie les autres valeurs dans les variables
   set ::conf(displaycoord,serverHost)  $widget(serverHost)
   set ::conf(displaycoord,serverPort)  $widget(serverPort)

   #--- je relance la connexion au serveur de coordonnees
   ::displaycoord::startConnectionLoop

}

##------------------------------------------------------------
#  brief créé les widgets de la fenêtre de configuration de la session
#  details cette procédure est appelée par ::confGenerique::fillConfigPage à la création de la fenêtre
#  @param frm nom tk de la frame cree par ::confgene::fillConfigPage
#  @param visuNo numéro de la visu
#  @private
#
proc ::displaycoord::config::fillConfigPage { frm visuNo } {
   variable widget
   variable private
   global caption

   set private($visuNo,frm) $frm

   #--- j'initalise les variables temporaires
   set widget(serverHost) $::conf(displaycoord,serverHost)
   set widget(serverPort) $::conf(displaycoord,serverPort)

   label  $frm.serverHostLabel  -text $caption(displaycoord,serverHost) -justify left
   entry  $frm.serverHostEntry  -textvariable ::displaycoord::config::widget(serverHost) -justify left
   label  $frm.serverPortLabel  -text $caption(displaycoord,serverPort) -justify left
   entry  $frm.serverPortEntry  -textvariable ::displaycoord::config::widget(serverPort) -justify left -width 8

   #--- placement dans la grille
   grid $frm.serverHostLabel    -in $frm -row 0 -column 0 -sticky wn  -padx 2
   grid $frm.serverHostEntry    -in $frm -row 0 -column 1 -sticky wen -padx 2
   grid $frm.serverPortLabel    -in $frm -row 1 -column 0 -sticky wn  -padx 2
   grid $frm.serverPortEntry    -in $frm -row 1 -column 1 -sticky wn  -padx 2

   grid columnconfig $frm 1 -weight 1

   pack $frm  -side top -fill x -expand 1
}

#------------------------------------------------------------
## @brief retourne le titre de la fenêtre
#  @details cette procédure est appelée par ::confGenerique::getLabel
#  @return  titre de la fenêtre
#  @private
#
proc ::displaycoord::config::getLabel { } {
   global caption

   return "$caption(displaycoord,title)"
}

