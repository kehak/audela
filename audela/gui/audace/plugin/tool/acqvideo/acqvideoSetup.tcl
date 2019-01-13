#
# Fichier : acqvideoSetup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition video
# Auteur : Robert DELMAS
# Mise à jour $Id: acqvideoSetup.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

namespace eval ::acqvideoSetup {

   #
   # acqvideoSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqvideo acqvideoSetup.cap ]
   }

   #
   # acqvideoSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::acqvideo::parametres(acqvideo,$visuNo,messages) ] }      { set ::acqvideo::parametres(acqvideo,$visuNo,messages)      "1" }
      if { ! [ info exists ::acqvideo::parametres(acqvideo,$visuNo,save_file_log) ] } { set ::acqvideo::parametres(acqvideo,$visuNo,save_file_log) "1" }
   }

   #
   # acqvideoSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(acqvideo,$visuNo,messages)      $::acqvideo::parametres(acqvideo,$visuNo,messages)
      set panneau(acqvideo,$visuNo,save_file_log) $::acqvideo::parametres(acqvideo,$visuNo,save_file_log)
   }

   #
   # acqvideoSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::acqvideo::parametres(acqvideo,$visuNo,messages)      $panneau(acqvideo,$visuNo,messages)
      set ::acqvideo::parametres(acqvideo,$visuNo,save_file_log) $panneau(acqvideo,$visuNo,save_file_log)
   }

   #
   # acqvideoSetup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #---
      set panneau(acqvideo,$visuNo,acqvideoSetup) $this
      ::confGenerique::run $visuNo "$panneau(acqvideo,$visuNo,acqvideoSetup)" "::acqvideoSetup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(acqvideo,$visuNo,acqvideoSetup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # acqvideoSetup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::acqvideoSetup::widgetToConf $visuNo
   }

   #
   # acqvideoSetup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqvideo::getPluginType ] ] \
         [ ::acqvideo::getPluginDirectory ] acqvideoSetup.htm
   }

   #
   # acqvideoSetup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { visuNo } {
   }

   #
   # acqvideoSetup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(acqvideoSetup,titre)"
   }

   #
   # acqvideoSetup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::acqvideoSetup::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]

      #--- Frame pour les commentaires
      frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3 -borderwidth 1 -relief raise

         #--- Frame pour le commentaire 1
         frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4 -borderwidth 0

            #--- Cree le label pour le commentaire 1
            frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame6
               label $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame6.lab1 -text "$caption(acqvideoSetup,texte1)"
               pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame6.lab1 -side left -fill both \
                  -expand 0 -padx 5 -pady 5
            pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame6 -side left -fill both -expand 1

            #--- Cree le checkbutton pour le commentaire 1
            frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame7 -borderwidth 0
               checkbutton $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame7.check1 -highlightthickness 0 \
                  -variable panneau(acqvideo,$visuNo,messages)
               pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame7.check1 -side right -padx 5 -pady 0
            pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4.frame7 -side right -fill both -expand 1

         pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5 -borderwidth 0

            #--- Cree le label pour le commentaire 2
            frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame8 -borderwidth 0
               label $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame8.lab2 -text "$caption(acqvideoSetup,texte2)"
               pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame8.lab2 -side left -fill both \
                  -expand 0 -padx 5 -pady 5
            pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame8 -side left -fill both -expand 1

            #--- Cree le checkbutton pour le commentaire 2
            frame $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame9 -borderwidth 0
               checkbutton $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame9.check2 -highlightthickness 0 \
                  -variable panneau(acqvideo,$visuNo,save_file_log)
               pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame9.check2 -side right -padx 5 -pady 0
            pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5.frame9 -side right -fill both -expand 1

         pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3.frame5 -side top -fill both -expand 1

      pack $panneau(acqvideo,$visuNo,acqvideoSetup).frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::acqvideoSetup::init

