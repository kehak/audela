#
# Fichier : pretrfcSetup.tcl
# Description : Configuration de certains parametres de l'outil Pretraitement
# Auteur : Robert DELMAS
# Mise à jour $Id: pretrfcSetup.tcl 12617 2016-01-12 18:20:12Z robertdelmas $
#

namespace eval ::pretrfcSetup {

   #
   # pretrfcSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool pretrfc pretrfcSetup.cap ]
   }

   #
   # pretrfcSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { } {
      global conf_pt_fc

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists conf_pt_fc(messages) ] }      { set conf_pt_fc(messages)      "1" }
      if { ! [ info exists conf_pt_fc(save_file_log) ] } { set conf_pt_fc(save_file_log) "1" }
   }

   #
   # pretrfcSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { } {
      global conf_pt_fc panneau

      #--- confToWidget
      set panneau(pretrfc,messages)      $conf_pt_fc(messages)
      set panneau(pretrfc,save_file_log) $conf_pt_fc(save_file_log)
   }

   #
   # pretrfcSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf_pt_fc panneau

      set conf_pt_fc(messages)      $panneau(pretrfc,messages)
      set conf_pt_fc(save_file_log) $panneau(pretrfc,save_file_log)
   }

   #
   # pretrfcSetup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
      variable This

      set This $this
      ::confGenerique::run $visuNo "$This" "::pretrfcSetup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $::pretrfc::This ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::pretrfc::This ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_config + 0 ]+[ expr $posy_config + 340 ]
   }

   #
   # pretrfcSetup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::pretrfcSetup::widgetToConf
      #--- Sauvegarde des parametres dans le fichier de config
      ::pretrfc::SauvegardeParametres
   }

   #
   # pretrfcSetup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::pretrfc::getPluginType ] ] \
         [ ::pretrfc::getPluginDirectory ] pretrfcSetup.htm
   }

   #
   # pretrfcSetup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { visuNo } {
   }

   #
   # pretrfcSetup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(pretrfcSetup,titre)"
   }

   #
   # pretrfcSetup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      variable This
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::pretrfcSetup::confToWidget

      #--- Frame pour les commentaires
      frame $This.frame3 -borderwidth 1 -relief raise

         #--- Frame pour le commentaire 1
         frame $This.frame3.frame4 -borderwidth 0

            #--- Cree le label pour le commentaire 1
            frame $This.frame3.frame4.frame6
               label $This.frame3.frame4.frame6.lab1 -text "$caption(pretrfcSetup,texte1)"
               pack $This.frame3.frame4.frame6.lab1 -side left -fill both -expand 0 -padx 5 -pady 5
            pack $This.frame3.frame4.frame6 -side left -fill both -expand 1

            #--- Cree le checkbutton pour le commentaire 1
            frame $This.frame3.frame4.frame7 -borderwidth 0
               checkbutton $This.frame3.frame4.frame7.check1 -highlightthickness 0 \
                  -variable panneau(pretrfc,messages)
               pack $This.frame3.frame4.frame7.check1 -side right -padx 5 -pady 0
            pack $This.frame3.frame4.frame7 -side right -fill both -expand 1

         pack $This.frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $This.frame3.frame5 -borderwidth 0

            #--- Cree le label pour le commentaire 2
            frame $This.frame3.frame5.frame8 -borderwidth 0
               label $This.frame3.frame5.frame8.lab2 -text "$caption(pretrfcSetup,texte2)"
               pack $This.frame3.frame5.frame8.lab2 -side left -fill both -expand 0 -padx 5 -pady 5
            pack $This.frame3.frame5.frame8 -side left -fill both -expand 1

            #--- Cree le checkbutton pour le commentaire 2
            frame $This.frame3.frame5.frame9 -borderwidth 0
               checkbutton $This.frame3.frame5.frame9.check2 -highlightthickness 0 \
                  -variable panneau(pretrfc,save_file_log)
               pack $This.frame3.frame5.frame9.check2 -side right -padx 5 -pady 0
            pack $This.frame3.frame5.frame9 -side right -fill both -expand 1

         pack $This.frame3.frame5 -side top -fill both -expand 1

      pack $This.frame3 -side top -fill both -expand 1

   }

}

#--- Initialisation au demarrage
::pretrfcSetup::init

